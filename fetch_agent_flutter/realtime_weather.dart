import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'exceptions.dart';

final settings = getSettings();

/// Open-Meteo current weather + hourly/daily parameters
/// We'll request current hourly variables for the nearest hour (works without API key).
String _openMeteoCurrentUrl(double lat, double lon) {
  // Open-Meteo current weather + hourly/daily parameters
  // We'll request current hourly variables for the nearest hour (works without API key).
  const base = 'https://api.open-meteo.com/v1/forecast';
  // request hourly pm2_5/pm10 if available via the 'air_quality' parameter and current_weather
  final params =
      '?latitude=$lat&longitude=$lon'
      '&current_weather=true'
      '&hourly=relativehumidity_2m,temperature_2m'
      '&timezone=auto';
  // Open-Meteo offers an air quality API (separate), but availability varies by config.
  // If you want PM variables from Open-Meteo's "air-quality" endpoint, you can call:
  // "&hourly=pm10,pm2_5" if supported for your region or use remote provider.

  return base + params;
}

/// Returns a map:
/// {
///   "temp": double (C),
///   "humidity": double (%),
///   "pm25": double or null,
///   "pm10": double or null,
///   "descriptor": List<String>,
///   "raw": Map  // optional raw response for debugging
/// }
Future<Map<String, dynamic>> realtimeWeather(double lat, double lon) async {
  final url = _openMeteoCurrentUrl(lat, lon);

  try {
    final response = await http
        .get(Uri.parse(url))
        .timeout(
          Duration(milliseconds: (settings.requestTimeout * 1000).toInt()),
        );

    if (response.statusCode != 200) {
      throw FetchError('HTTP ${response.statusCode}');
    }

    final j = json.decode(response.body) as Map<String, dynamic>;

    // Extract current_weather and hourly/relative humidity if present
    double? temp;
    double? humidity;
    double? pm25;
    double? pm10;
    final List<String> descriptor = [];

    // current_weather usually contains temp and wind but not humidity
    final cw = j['current_weather'] as Map<String, dynamic>?;
    if (cw != null) {
      temp =
          cw['temperature']
              as double?; // open-meteo uses 'temperature' in current_weather
    }

    // relative humidity may be present in hourly with timestamps; fallback to null
    final hourly = j['hourly'] as Map<String, dynamic>? ?? {};
    // try to find the last available humidity for current hour
    try {
      final rhVals = hourly['relativehumidity_2m'] as List?;
      final timeVals = hourly['time'] as List?;
      if (rhVals != null && timeVals != null && rhVals.isNotEmpty) {
        // pick the last value
        humidity = (rhVals.last as num).toDouble();
      }
    } catch (e) {
      humidity = null;
    }

    // Attempt to extract pm if present in hourly
    try {
      final pm25Vals =
          hourly['pm2_5'] ?? hourly['pm2_5_ugm3'] ?? hourly['pm25'];
      final pm10Vals = hourly['pm10'];
      if (pm25Vals != null && pm25Vals is List && pm25Vals.isNotEmpty) {
        pm25 = (pm25Vals.last as num).toDouble();
      }
      if (pm10Vals != null && pm10Vals is List && pm10Vals.isNotEmpty) {
        pm10 = (pm10Vals.last as num).toDouble();
      }
    } catch (e) {
      pm25 = null;
      pm10 = null;
    }

    // Basic descriptor creation
    if (temp != null) {
      descriptor.add('${temp}°C');
    }
    if (humidity != null) {
      descriptor.add('RH $humidity%');
    }
    if (pm25 != null) {
      descriptor.add('PM2.5 $pm25');
    }
    if (pm10 != null) {
      descriptor.add('PM10 $pm10');
    }

    return {
      'temp': temp,
      'humidity': humidity,
      'pm25': pm25,
      'pm10': pm10,
      'descriptor': descriptor,
      'raw': j,
    };
  } catch (e) {
    if (e is FetchError) rethrow;
    throw FetchError('Failed to fetch weather from Open-Meteo: $e');
  }
}

/// Helper if user passes a city name: simple geocoding via Nominatim (optional)
/// Simple free geocode using Nominatim. Rate-limited; use with care.
/// Returns (lat, lon)
Future<Map<String, double>> geocodeCityToLatLon(String city) async {
  try {
    final encodedCity = Uri.encodeComponent(city);
    final url =
        'https://nominatim.openstreetmap.org/search'
        '?q=$encodedCity&format=json&limit=1';

    final response = await http
        .get(Uri.parse(url), headers: {'User-Agent': 'fetch-agent/0.1'})
        .timeout(
          Duration(milliseconds: (settings.requestTimeout * 1000).toInt()),
        );

    if (response.statusCode != 200) {
      throw FetchError('HTTP ${response.statusCode}');
    }

    final arr = json.decode(response.body) as List;
    if (arr.isEmpty) {
      throw FetchError('Geocoding returned no results for $city');
    }

    final item = arr[0] as Map<String, dynamic>;
    return {
      'lat': double.parse(item['lat'] as String),
      'lon': double.parse(item['lon'] as String),
    };
  } catch (e) {
    if (e is FetchError) rethrow;
    throw FetchError('Failed geocoding city $city: $e');
  }
}
