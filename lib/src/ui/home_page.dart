import 'dart:async';

import 'package:flutter/material.dart';
import '../models/weather_result.dart';
import '../services/weather_service.dart';
import '../services/cache_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _indexController =
      TextEditingController(text: '194174B');
  WeatherResult? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCached = false;

  double computeLat(String index) {
    final firstTwo = int.tryParse(index.substring(0, 2)) ?? 0;
    return 5 + (firstTwo / 10.0);
  }

  double computeLon(String index) {
    final nextTwo = int.tryParse(index.substring(2, 4)) ?? 0;
    return 79 + (nextTwo / 10.0);
  }

  Future<void> _fetchWeather() async {
    final index = _indexController.text.trim();
    if (index.length < 4) {
      setState(() {
        _errorMessage = 'Index must be at least 4 characters (e.g. 1941...)';
      });
      return;
    }

    final lat = computeLat(index);
    final lon = computeLon(index);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isCached = false;
    });

    try {
      final result = await WeatherService.fetchCurrentWeather(lat, lon);
      await CacheService.save(result);
      setState(() {
        _weather = result;
        _isCached = false;
      });
    } on TimeoutException catch (_) {
      await _loadCacheOnError('Request timed out. Showing cached data if available.');
    } catch (e) {
      await _loadCacheOnError('Failed to fetch weather: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCacheOnError(String errorMsg) async {
    final cached = await CacheService.load();
    if (cached != null) {
      setState(() {
        _weather = cached;
        _isCached = true;
        _errorMessage = errorMsg;
      });
    } else {
      setState(() {
        _errorMessage = errorMsg + '\nNo cached data available.';
        _isCached = false;
        _weather = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStartupCache();
  }

  Future<void> _loadStartupCache() async {
    final cached = await CacheService.load();
    if (cached != null) {
      setState(() {
        _weather = cached;
        _isCached = true;
      });
    }
  }

  @override
  void dispose() {
    _indexController.dispose();
    super.dispose();
  }

  String _getWeatherIcon(int weatherCode) {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 48) return '🌫️';
    if (weatherCode <= 67) return '🌧️';
    if (weatherCode <= 77) return '🌨️';
    if (weatherCode <= 82) return '🌦️';
    return '⛈️';
  }

  String _getWeatherDescription(int weatherCode) {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 3) return 'Partly cloudy';
    if (weatherCode <= 48) return 'Foggy';
    if (weatherCode <= 67) return 'Rainy';
    if (weatherCode <= 77) return 'Snowy';
    if (weatherCode <= 82) return 'Rain showers';
    return 'Thunderstorm';
  }

  @override
  Widget build(BuildContext context) {
    final latStr = (_indexController.text.trim().length >= 4)
        ? computeLat(_indexController.text.trim()).toStringAsFixed(2)
        : '--';
    final lonStr = (_indexController.text.trim().length >= 4)
        ? computeLon(_indexController.text.trim()).toStringAsFixed(2)
        : '--';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Weather Dashboard', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header gradient section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  children: [
                    // Input card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Student Index Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _indexController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[100],
                              hintText: 'e.g. 194174B',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: Icon(Icons.person_outline, color: Colors.blue[700]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _fetchWeather(),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _fetchWeather,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.cloud_outlined, size: 22),
                                        SizedBox(width: 8),
                                        Text('Get Weather', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Location info card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.blue[700], size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Location Details',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildLocationDetail('Latitude', latStr, Icons.public),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildLocationDetail('Longitude', lonStr, Icons.explore),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Weather data card
                  if (_weather != null)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue[400]!, Colors.blue[600]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          if (_isCached)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange[400],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.offline_bolt, color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Cached Data',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            _getWeatherIcon(_weather!.weathercode),
                            style: const TextStyle(fontSize: 72),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getWeatherDescription(_weather!.weathercode),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildWeatherStat(
                                Icons.thermostat,
                                '${_weather!.temperature}°C',
                                'Temperature',
                              ),
                              _buildWeatherStat(
                                Icons.air,
                                '${_weather!.windspeed} km/h',
                                'Wind Speed',
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time, color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Updated: ${_formatTime(_weather!.fetchedAt)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_weather == null && !_isLoading)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No Weather Data',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your student index and tap "Get Weather"',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700], size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red[900], fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Clear cache button
                  OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            await CacheService.clear();
                            setState(() {
                              _weather = null;
                              _isCached = false;
                              _errorMessage = null;
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 12),
                                      Text('Cache cleared successfully'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green[600],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear Cache'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info section
                  if (_weather != null)
                    ExpansionTile(
                      title: const Text(
                        'Technical Details',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      leading: Icon(Icons.info_outline, color: Colors.blue[700]),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTechDetail('Weather Code', _weather!.weathercode.toString()),
                              const SizedBox(height: 8),
                              _buildTechDetail('Request URL', _weather!.requestUrl),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDetail(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue[900]),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildTechDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}