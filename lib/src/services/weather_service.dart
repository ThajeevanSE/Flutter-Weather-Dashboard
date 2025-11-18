import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_result.dart';

class WeatherService {
  // Build the exact request URL
  static String buildUrl(double lat, double lon) {
    // Use double with sufficient precision
    final latStr = lat.toStringAsFixed(6);
    final lonStr = lon.toStringAsFixed(6);
    return 'https://api.open-meteo.com/v1/forecast?latitude=$latStr&longitude=$lonStr&current_weather=true';
  }

  // Fetch weather from Open-Meteo
  static Future<WeatherResult> fetchCurrentWeather(double lat, double lon) async {
    final url = buildUrl(lat, lon);
    final uri = Uri.parse(url);

    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch weather: ${response.statusCode}');
    }

    final Map<String, dynamic> jsonBody = json.decode(response.body);

    if (!jsonBody.containsKey('current_weather')) {
      throw Exception('Unexpected response: missing current_weather');
    }

    final current = jsonBody['current_weather'] as Map<String, dynamic>;
    final temp = (current['temperature'] as num).toDouble();
    final wind = (current['windspeed'] as num).toDouble();
    final code = (current['weathercode'] as num).toInt();

    return WeatherResult(
      latitude: lat,
      longitude: lon,
      temperature: temp,
      windspeed: wind,
      weathercode: code,
      requestUrl: url,
      fetchedAt: DateTime.now(),
    );
  }
}
