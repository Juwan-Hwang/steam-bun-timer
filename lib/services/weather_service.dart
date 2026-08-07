/// 和风天气 API 服务 — §4.5 气温采集
/// 发酵开始时调用一次取当前温度，失败降级为 null
/// 新版认证: API Host + X-QW-Api-Key header（不再用 devapi.qweather.com / key 查询参数）
/// 后台静默执行，任何失败都不影响 UI
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class WeatherData {
  final double temperature;
  final int? humidity;
  WeatherData({required this.temperature, this.humidity});
}

/// API 测试结果
class WeatherTestResult {
  final bool success;
  final String message;
  final WeatherData? data;
  WeatherTestResult({required this.success, required this.message, this.data});
}

class WeatherService {
  WeatherService._();
  static final instance = WeatherService._();

  static const _prefsKey = 'qweather_api_key';
  static const _prefsHost = 'qweather_api_host';

  /// v7 实时天气端点
  static const _weatherNowPath = '/v7/weather/now';

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
  Future<bool> ensureLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final status = await Permission.locationWhenInUse.request();
        if (status.isGranted) return true;
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }
      if (permission == LocationPermission.deniedForever) return false;
      return true;
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
    final lng = position?.longitude ?? 116.41;
    final lat = position?.latitude ?? 39.92;

    return _requestWeather(apiKey, apiHost, lng, lat, isTest: true);
  }

  // ─── 业务调用 ──────────────────────────────────────────────

  /// 获取当前位置实时天气 — 后台静默执行，失败返回 null
  Future<WeatherData?> fetchCurrentWeather() async {
    try {
      final apiKey = await _getApiKey();
      final apiHost = await _getApiHost();
      if (apiKey == null || apiKey.isEmpty) return null;
      if (apiHost == null || apiHost.isEmpty) return null;

      final position = await _getPosition();
      if (position == null) return null;

      final result = await _requestWeather(
        apiKey, apiHost, position.longitude, position.latitude,
      );
      return result.success ? result.data : null;
    } catch (_) {
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

  /// 获取定位（带权限检查和降级处理）
  Future<Position?> _getPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final status = await Permission.locationWhenInUse.request();
        if (status.isGranted) {
          permission = LocationPermission.whileInUse;
        } else {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) return null;
        }
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
