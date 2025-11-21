import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/api_config.dart';

/// Service for fetching weather data from Open-Meteo API
class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch current weather and 7-day forecast by coordinates
  Future<Map<String, dynamic>> getWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.openMeteoWeatherUrl}/forecast?'
        'latitude=$latitude&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,surface_pressure,wind_speed_10m,weather_code'
        '&daily=temperature_2m_max,temperature_2m_min,weather_code'
        '&timezone=auto',
      );

      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final current = data['current'] as Map<String, dynamic>;
        final daily = data['daily'] as Map<String, dynamic>;

        return {
          'current': {
            'temp': (current['temperature_2m'] as num).round(),
            'humidity': (current['relative_humidity_2m'] as num).round(),
            'pressure': (current['surface_pressure'] as num).round(),
            'windSpeed': (current['wind_speed_10m'] as num).round(),
            'weatherCode': current['weather_code'] as int,
          },
          'daily': {
            'maxTemps': (daily['temperature_2m_max'] as List).cast<num>(),
            'minTemps': (daily['temperature_2m_min'] as List).cast<num>(),
            'weatherCodes': (daily['weather_code'] as List).cast<int>(),
            'dates': (daily['time'] as List).cast<String>(),
          },
        };
      } else {
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
