/// 和风天气 API 服务 — §4.5 气温采集
/// 发酵开始时调用一次取当前温度，失败降级为 null
/// API key 从 SharedPreferences 读取，用户可在设置页配置
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherData {
  final double temperature;
  final int? humidity;
  WeatherData({required this.temperature, this.humidity});
}

class WeatherService {
  WeatherService._();
  static final instance = WeatherService._();

  static const _baseUrl = 'https://devapi.qweather.com/v7/weather/now';
  static const _prefsKey = 'qweather_api_key';

  /// 获取 API key（从 SharedPreferences）
  Future<String?> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKey);
  }

  /// 设置 API key — 供设置页调用
  Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, key);
  }

  /// 获取当前配置的 API key
  Future<String?> getApiKey() async {
    return await _getApiKey();
  }

  /// 获取当前位置的实时天气
  /// §4.5: 网络异常或定位失败时返回 null，不阻塞批次记录入库
  Future<WeatherData?> fetchCurrentWeather() async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null || apiKey.isEmpty) return null;

      // 1. 获取定位
      final position = await _getPosition();
      if (position == null) return null;

      // 2. 调用天气 API
      final url = '$_baseUrl?location=${position.longitude},${position.latitude}&key=$apiKey&unit=m';
      final resp = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (resp.statusCode != 200) return null;

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      if (json['code'] != '200') return null;

      final now = json['now'] as Map<String, dynamic>;
      final temp = double.tryParse(now['temp'] as String? ?? '');
      if (temp == null) return null;

      final humidity = int.tryParse(now['humidity'] as String? ?? '');

      return WeatherData(temperature: temp, humidity: humidity);
    } catch (_) {
      // §4.5: 宁缺数据，不丢数据
      return null;
    }
  }

  /// 获取定位（带权限检查和降级处理）
  Future<Position?> _getPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
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
