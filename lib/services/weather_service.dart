/// 和风天气 API 服务 — §4.5 气温采集
/// 发酵开始时调用一次取当前温度，失败降级为 null
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherData {
  final double temperature;
  final int? humidity;
  WeatherData({required this.temperature, this.humidity});
}

class WeatherService {
  WeatherService._();
  static final instance = WeatherService._();

  /// 和风天气 API key — 需替换为实际 key
  static const _apiKey = 'YOUR_QWEATHER_API_KEY';
  static const _baseUrl = 'https://devapi.qweather.com/v7/weather/now';

  /// 获取当前位置的实时天气
  /// §4.5: 网络异常或定位失败时返回 null，不阻塞批次记录入库
  Future<WeatherData?> fetchCurrentWeather() async {
    try {
      // 1. 获取定位
      final position = await _getPosition();
      if (position == null) return null;

      // 2. 调用天气 API
      final url = '$_baseUrl?location=${position.longitude},${position.latitude}&key=$_apiKey&unit=m';
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
