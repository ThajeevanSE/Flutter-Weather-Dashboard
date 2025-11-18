class WeatherResult {
  final double latitude;
  final double longitude;
  final double temperature; 
  final double windspeed; 
  final int weathercode;
  final String requestUrl;
  final DateTime fetchedAt;

  WeatherResult({
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.windspeed,
    required this.weathercode,
    required this.requestUrl,
    required this.fetchedAt,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'temperature': temperature,
        'windspeed': windspeed,
        'weathercode': weathercode,
        'requestUrl': requestUrl,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory WeatherResult.fromJson(Map<String, dynamic> json) {
    return WeatherResult(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      windspeed: (json['windspeed'] as num).toDouble(),
      weathercode: (json['weathercode'] as num).toInt(),
      requestUrl: json['requestUrl'] as String,
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }
}
