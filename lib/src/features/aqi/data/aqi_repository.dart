import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AqiRepository {
  final http.Client client;

  AqiRepository({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> fetchAqi({
    required double lat,
    required double lon,
  }) async {
    final token = dotenv.env['WAQI_API_TOKEN'];
    if (token == null || token.isEmpty) {
      throw Exception('WAQI_API_TOKEN not found in .env');
    }

    final url = Uri.parse(
      'https://api.waqi.info/feed/geo:$lat;$lon/?token=$token',
    );

    final response = await client.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'ok') {
        return data['data'];
      } else {
        throw Exception('WAQI API Error: ${data['data']}');
      }
    } else {
      throw Exception('Failed to load AQI data: ${response.statusCode}');
    }
  }
}

final aqiRepositoryProvider = Provider<AqiRepository>((ref) {
  return AqiRepository();
});
