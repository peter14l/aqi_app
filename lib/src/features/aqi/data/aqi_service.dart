import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/api_config.dart';

/// Service for fetching AQI data from AQICN API
class AqiService {
  final http.Client _client;

  AqiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch AQI data by coordinates
  Future<Map<String, dynamic>> getAqiByCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.aqicnBaseUrl}/feed/geo:$latitude;$longitude/?token=${ApiConfig.aqicnApiKey}',
      );

      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'ok') {
          final aqiData = data['data'] as Map<String, dynamic>;
          return {
            'aqi': aqiData['aqi'] ?? 0,
            'pm25': aqiData['iaqi']?['pm25']?['v'] ?? 0,
            'pm10': aqiData['iaqi']?['pm10']?['v'] ?? 0,
            'city': aqiData['city']?['name'] ?? 'Unknown',
            'time': aqiData['time']?['s'] ?? '',
          };
        } else {
          throw Exception('AQICN API returned error status');
        }
      } else {
        throw Exception('Failed to fetch AQI data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching AQI data: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
