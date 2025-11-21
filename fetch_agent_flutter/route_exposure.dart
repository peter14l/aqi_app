import 'realtime_aqi.dart';
import 'exceptions.dart';

/// route_points: [{'lat': 22.5, 'lon': 88.3}, ...] OR [{'lat':.., 'lng':..}]
/// Returns:
///   {
///     "avg_aqi": double,
///     "max_aqi": int,
///     "min_aqi": int,
///     "exposure_score": double  // normalized 0-100 (simple scaling)
///   }
Future<Map<String, dynamic>> calculateExposure(
  List<Map<String, dynamic>> routePoints,
) async {
  final aqiValues = <int>[];

  for (final p in routePoints) {
    final lat = p['lat'] ?? p['latitude'];
    final lon = p['lon'] ?? p['lng'] ?? p['longitude'];

    if (lat == null || lon == null) {
      continue;
    }

    final loc = '$lat,$lon';
    try {
      final aqi = await realtimeAqi(loc);
      aqiValues.add(aqi);
    } catch (e) {
      // skip points we can't fetch
      continue;
    }
  }

  if (aqiValues.isEmpty) {
    throw FetchError('No AQI data available for any route points');
  }

  final avg = aqiValues.reduce((a, b) => a + b) / aqiValues.length;
  final mx = aqiValues.reduce((a, b) => a > b ? a : b);
  final mn = aqiValues.reduce((a, b) => a < b ? a : b);

  // simple exposure score: map avg aqi to 0-100 (0..50 => low, 50..100 moderate..)
  final exposureScore = (avg / 500.0 * 100.0).clamp(0.0, 100.0);

  return {
    'avg_aqi': avg,
    'max_aqi': mx,
    'min_aqi': mn,
    'exposure_score': exposureScore,
  };
}
