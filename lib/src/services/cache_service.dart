import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_result.dart';

class CacheService {
  static const String _cacheKey = 'cached_weather';

  static Future<void> save(WeatherResult result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, json.encode(result.toJson()));
  }

  static Future<WeatherResult?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_cacheKey);
    if (jsonStr == null) return null;
    try {
      final Map<String, dynamic> data = json.decode(jsonStr);
      return WeatherResult.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
