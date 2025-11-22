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
        '&current=temperature_2m,relative_humidity_2m,surface_pressure,wind_speed_10m,weather_code,apparent_temperature,visibility,wind_direction_10m,precipitation'
        '&daily=temperature_2m_max,temperature_2m_min,weather_code,uv_index_max,sunrise,sunset,precipitation_sum'
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
            'feelsLike': (current['apparent_temperature'] as num).round(),
            'visibility': (current['visibility'] as num).toDouble(),
            'windDirection': (current['wind_direction_10m'] as num).round(),
            'precipitation': (current['precipitation'] as num).toDouble(),
          },
          'daily': {
            'maxTemps': (daily['temperature_2m_max'] as List).cast<num>(),
            'minTemps': (daily['temperature_2m_min'] as List).cast<num>(),
            'weatherCodes': (daily['weather_code'] as List).cast<int>(),
            'dates': (daily['time'] as List).cast<String>(),
            'uvIndexMax': (daily['uv_index_max'] as List).cast<num>(),
            'sunrise': (daily['sunrise'] as List).cast<String>(),
            'sunset': (daily['sunset'] as List).cast<String>(),
            'precipitationSum': (daily['precipitation_sum'] as List).cast<num>(),
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
