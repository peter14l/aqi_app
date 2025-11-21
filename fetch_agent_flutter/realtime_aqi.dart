import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'exceptions.dart';

final settings = getSettings();

/// AQICN accepts city names like 'delhi' or geo:lat;lon
/// e.g. https://api.waqi.info/feed/geo:10.3;76.4/?token=TOKEN
String _buildAqicnUrlForLocation(String location) {
  final token = settings.aqicnToken;
  if (token.isEmpty) {
    throw FetchError('AQICN_TOKEN not set in environment');
  }

  if (location.contains(',')) {
    final parts = location.split(',').map((p) => p.trim()).toList();
    final lat = parts[0];
    final lon = parts[1];
    return 'https://api.waqi.info/feed/geo:$lat;$lon/?token=$token';
  } else {
    // city name or station id
    return 'https://api.waqi.info/feed/$location/?token=$token';
  }
}

/// Returns integer AQI for the location.
/// location: "CityName" or "lat,lon" (e.g., "22.5726,88.3639")
/// Raises FetchError on failure.
Future<int> realtimeAqi(String location) async {
  final url = _buildAqicnUrlForLocation(location);

  try {
    final response = await http
        .get(Uri.parse(url))
        .timeout(
          Duration(milliseconds: (settings.requestTimeout * 1000).toInt()),
        );

    if (response.statusCode != 200) {
      throw FetchError('HTTP ${response.statusCode}');
    }

    final j = json.decode(response.body);

    // WAQI JSON usually: {"status":"ok", "data": {...}}
    if (j is! Map<String, dynamic>) {
      throw FetchError('Unexpected response format from AQICN');
    }

    if (j['status'] != 'ok') {
      // Handle some known failure modes gracefully
      final msg = j['data'] ?? j['message'] ?? 'unknown';
      throw FetchError('AQICN status not ok: $msg');
    }

    final data = j['data'] as Map<String, dynamic>? ?? {};
    // AQI number might be in data["aqi"]
    final aqi = data['aqi'];
    if (aqi == null) {
      // try to pick from iaqi fields (pm25 etc.) if present, but prefer aqi if available
      final iaqi = data['iaqi'] as Map<String, dynamic>? ?? {};
      final pm25 = iaqi['pm25']?['v'];
      // fallback heuristic: return pm25 as proxy if present
      if (pm25 != null) {
        try {
          return (pm25 as num).toInt();
        } catch (e) {
          // continue to error
        }
      }
      throw FetchError('AQI value missing in AQICN response');
    }

    try {
      return (aqi as num).toInt();
    } catch (e) {
      throw FetchError('Failed to parse AQI value: $e');
    }
  } catch (e) {
    if (e is FetchError) rethrow;
    throw FetchError('HTTP error fetching AQI: $e');
  }
}
