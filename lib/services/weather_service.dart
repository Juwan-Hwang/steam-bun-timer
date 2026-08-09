/// 和风天气 API 服务 — §4.5 气温采集
/// 发酵开始时调用一次取当前温度，失败降级为 null
/// 新版认证: API Host + X-QW-Api-Key header（不再用 devapi.qweather.com / key 查询参数）
/// 后台静默执行，任何失败都不影响 UI
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

/// 天气数据来源
enum WeatherSource {
  /// 原生 LocationManager 定位获取（基站/Wi-Fi/GPS）
  gps,
  /// IP 定位兜底
  ip,
}

class WeatherData {
  final double temperature;
  final int? humidity;
  final WeatherSource source;
  const WeatherData({
    required this.temperature,
    this.humidity,
    this.source = WeatherSource.gps,
  });

  @override
  String toString() => 'WeatherData(temp=$temperature, humidity=$humidity, source=$source)';
}

/// API 测试结果
class WeatherTestResult {
  final bool success;
  final String message;
  final WeatherData? data;
  const WeatherTestResult({required this.success, required this.message, this.data});
}

class WeatherService {
  WeatherService._();
  static final instance = WeatherService._();

  static const _prefsKey = 'qweather_api_key';
  static const _prefsHost = 'qweather_api_host';

  /// v7 实时天气端点
  static const _weatherNowPath = '/v7/weather/now';

  /// 原生定位 MethodChannel
  static const _locationChannel = MethodChannel('com.steambun.steam_bun_timer/location');

  // ─── Key / Host 存取 ───────────────────────────────────────

  Future<String?> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKey);
  }

  Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, key.trim());
  }

  Future<String?> _getApiHost() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsHost);
  }

  /// 保存 API Host，自动去除 `https://` 前缀和末尾斜杠
  Future<void> setApiHost(String host) async {
    final prefs = await SharedPreferences.getInstance();
    final cleaned = host
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/+$'), '');
    await prefs.setString(_prefsHost, cleaned);
  }

  /// 供 UI 显示
  Future<String?> getApiKey() async => _getApiKey();
  Future<String?> getApiHost() async => _getApiHost();

  // ─── 定位权限 ──────────────────────────────────────────────

  /// 主动请求定位权限（供设置页"测试"按钮调用）
  /// 同时请求 ACCESS_FINE_LOCATION + ACCESS_COARSE_LOCATION
  Future<bool> ensureLocationPermission() async {
    try {
      // 先请求精确定位（包含 coarse），再请求 coarse 作为兜底
      final fine = await Permission.location.request();
      if (fine.isGranted) return true;
      final coarse = await Permission.locationWhenInUse.request();
      return coarse.isGranted;
    } catch (_) {
      return false;
    }
  }

  // ─── 测试 ─────────────────────────────────────────────────

  /// 验证 API Key + Host 是否有效，返回详细结果
  Future<WeatherTestResult> testApiKey() async {
    final apiKey = await _getApiKey();
    final apiHost = await _getApiHost();

    if (apiKey == null || apiKey.isEmpty) {
      return const WeatherTestResult(success: false, message: '未配置 API Key');
    }
    if (apiHost == null || apiHost.isEmpty) {
      return const WeatherTestResult(
        success: false,
        message: '未配置 API Host — 请在控制台「设置」页复制',
      );
    }

    final position = await _getPosition();
    // 定位失败时用北京坐标测试（不影响 Key 有效性验证）
    final lng = position?['longitude'] ?? 116.41;
    final lat = position?['latitude'] ?? 39.92;

    return _requestWeather(apiKey, apiHost, lng, lat, isTest: true);
  }

  // ─── 业务调用 ──────────────────────────────────────────────

  /// 获取当前位置实时天气 — 后台静默执行，失败返回 null
  Future<WeatherData?> fetchCurrentWeather() async {
    try {
      final apiKey = await _getApiKey();
      final apiHost = await _getApiHost();
      debugPrint('[Weather] apiKey=${apiKey != null ? "set(${apiKey.length} chars)" : "null"}, apiHost=$apiHost');
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('[Weather] API key not configured');
        return null;
      }
      if (apiHost == null || apiHost.isEmpty) {
        debugPrint('[Weather] API host not configured');
        return null;
      }

      // 1. 原生 LocationManager 定位（基站/Wi-Fi，不依赖 Google Play 服务）
      final position = await _getPosition();
      debugPrint('[Weather] position=$position');
      if (position != null) {
        final result = await _requestWeather(
          apiKey, apiHost,
          position['longitude'] as double,
          position['latitude'] as double,
        );
        debugPrint('[Weather] API result: success=${result.success}, msg=${result.message}');
        return result.success ? result.data : null;
      }

      // 2. 原生定位失败 → IP 定位兜底
      debugPrint('[Weather] native location failed, falling back to IP geolocation');
      final ipResult = await _requestWeatherByIp(apiKey, apiHost);
      debugPrint('[Weather] API result (IP): success=${ipResult.success}, msg=${ipResult.message}');
      return ipResult.success ? ipResult.data : null;
    } catch (e) {
      debugPrint('[Weather] fetchCurrentWeather exception: $e');
      return null;
    }
  }

  // ─── 核心 HTTP 请求 ────────────────────────────────────────

  /// 统一的天气请求方法 — v7 API + X-QW-Api-Key header
  ///
  /// [isTest] 为 true 时返回更详细的错误信息供 UI 展示
  Future<WeatherTestResult> _requestWeather(
    String apiKey, String apiHost,
    double lng, double lat, {
    bool isTest = false,
  }) async {
    try {
      final url = Uri.parse(
        'https://$apiHost$_weatherNowPath?location=$lng,$lat',
      );

      final resp = await http.get(url, headers: {
        'X-QW-Api-Key': apiKey,
      }).timeout(const Duration(seconds: 10));

      if (resp.statusCode != 200) {
        return WeatherTestResult(
          success: false,
          message: 'HTTP ${resp.statusCode} — 请检查 API Host 是否正确',
        );
      }

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final code = json['code'] as String?;

      if (code != '200') {
        final msg = _errorMessage(code);
        return WeatherTestResult(success: false, message: msg);
      }

      final now = json['now'] as Map<String, dynamic>;
      final temp = double.tryParse(now['temp'] as String? ?? '');
      final humidity = int.tryParse(now['humidity'] as String? ?? '');

      if (temp == null) {
        return WeatherTestResult(
          success: false,
          message: isTest ? '响应解析失败: 无法读取温度' : '解析失败',
        );
      }

      final locationNote = isTest
          ? '（坐标 ${lng.toStringAsFixed(2)}, ${lat.toStringAsFixed(2)}）'
          : '';

      return WeatherTestResult(
        success: true,
        message: '连接成功！当前温度 ${temp.toStringAsFixed(1)}°C'
            '${humidity != null ? '，湿度 $humidity%' : ''}'
            ' $locationNote',
        data: WeatherData(temperature: temp, humidity: humidity),
      );
    } catch (e) {
      return WeatherTestResult(
        success: false,
        message: isTest ? '网络请求失败: $e' : '网络异常',
      );
    }
  }

  /// 通过 IP 定位获取天气 — 原生定位失败时的兜底方案
  /// 优先用 ip-api.com（对国内 IP 更准），失败再用 ipinfo.io
  Future<WeatherTestResult> _requestWeatherByIp(
    String apiKey, String apiHost,
  ) async {
    // 尝试多个 IP 定位服务，谁先成功用谁
    final services = <Future<({double lat, double lng, String city})>>[
      _ipApiCom(),
      _ipinfoIo(),
    ];

    for (final future in services) {
      try {
        final loc = await future.timeout(const Duration(seconds: 5));
        debugPrint('[Weather] IP location: ${loc.city} (${loc.lat}, ${loc.lng})');

        final result = await _requestWeather(apiKey, apiHost, loc.lng, loc.lat);
        if (result.success && result.data != null) {
          return WeatherTestResult(
            success: true,
            message: 'IP 定位成功(${loc.city}) ${result.data!.temperature.toStringAsFixed(1)}°C'
                '${result.data!.humidity != null ? "，湿度 ${result.data!.humidity}%" : ""}',
            data: WeatherData(
              temperature: result.data!.temperature,
              humidity: result.data!.humidity,
              source: WeatherSource.ip,
            ),
          );
        }
        // 天气 API 失败就没必要换 IP 服务了，直接返回
        return result;
      } catch (e) {
        debugPrint('[Weather] IP service failed: $e, trying next...');
      }
    }

    return const WeatherTestResult(success: false, message: '所有 IP 定位服务均失败');
  }

  /// ip-api.com — 对国内 IP 精度更高（市级）
  Future<({double lat, double lng, String city})> _ipApiCom() async {
    final resp = await http.get(Uri.parse('http://ip-api.com/json/?lang=zh')).timeout(const Duration(seconds: 5));
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if (json['status'] != 'success') throw Exception('ip-api.com failed');
    final lat = (json['lat'] as num).toDouble();
    final lng = (json['lon'] as num).toDouble();
    final city = json['city'] as String? ?? json['regionName'] as String? ?? '未知';
    return (lat: lat, lng: lng, city: city);
  }

  /// ipinfo.io — 备用
  Future<({double lat, double lng, String city})> _ipinfoIo() async {
    final resp = await http.get(Uri.parse('https://ipinfo.io/json')).timeout(const Duration(seconds: 5));
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final loc = json['loc'] as String?;
    if (loc == null || !loc.contains(',')) throw Exception('ipinfo.io no loc');
    final parts = loc.split(',');
    final lat = double.tryParse(parts[0]);
    final lng = double.tryParse(parts[1]);
    if (lat == null || lng == null) throw Exception('ipinfo.io parse failed');
    final city = json['city'] as String? ?? '未知';
    return (lat: lat, lng: lng, city: city);
  }

  /// 和风天气 v7 错误码 → 人类可读信息
  String _errorMessage(String? code) {
    switch (code) {
      case '400':
        return '请求参数错误 (400)';
      case '401':
        return 'API Key 无效或已过期 (401)';
      case '402':
        return '访问超限，请稍后重试 (402)';
      case '403':
        return '认证失败 — 请检查 API Key 和 API Host 是否匹配 (403)';
      case '404':
        return '位置数据不存在 (404)';
      case '429':
        return '请求频率超限，请稍后重试 (429)';
      default:
        return 'API 返回错误码: $code';
    }
  }

  // ─── 定位 ─────────────────────────────────────────────────

  /// 通过原生 MethodChannel 获取定位
  /// 使用 Android LocationManager.NETWORK_PROVIDER（基站/Wi-Fi 定位）
  /// 不依赖 Google Play 服务，室内可用
  Future<Map<String, dynamic>?> _getPosition() async {
    try {
      // 确保定位权限（fine + coarse）
      final fine = await Permission.location.request();
      if (!fine.isGranted) {
        final coarse = await Permission.locationWhenInUse.request();
        if (!coarse.isGranted) {
          debugPrint('[Weather] location permission denied');
          return null;
        }
      }

      final result = await _locationChannel
          .invokeMethod<Map>('getLocation')
          .timeout(const Duration(seconds: 12));
      debugPrint('[Weather] native location: $result');
      if (result == null) return null;
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      debugPrint('[Weather] native location failed: ${e.code} — ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[Weather] _getPosition exception: $e');
      return null;
    }
  }
}
