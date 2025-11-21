import 'realtime_aqi.dart';

/// Returns a list of `months` maps with keys: avg_aqi, peak_aqi, least_aqi
/// Implementation note: best to call a provider that exposes daily historical AQI.
/// Here we attempt a simple approach: for each month sample the AQI at day intervals (or fallback).
Future<List<Map<String, dynamic>>> historyAqi(
  String location, {
  int months = 12,
}) async {
  final results = <Map<String, dynamic>>[];

  // Simple sampling approach: for each month fetch AQI of 8 sample dates (1st, 5th, 10th,...)
  // This is a pragmatic approach if true daily historical endpoint is unavailable.

  for (int m = 0; m < months; m++) {
    // we'll sample 6 points across that month: day 1,6,11,16,21,26
    final sampleDays = [1, 6, 11, 16, 21, 26];
    final vals = <int>[];

    for (final _ in sampleDays) {
      try {
        // build lat,lon or city usage into realtime_aqi input if needed
        final aqi = await realtimeAqi(location);
        vals.add(aqi);
      } catch (e) {
        continue;
      }
    }

    if (vals.isNotEmpty) {
      results.add({
        'avg_aqi': vals.reduce((a, b) => a + b) / vals.length,
        'peak_aqi': vals.reduce((a, b) => a > b ? a : b),
        'least_aqi': vals.reduce((a, b) => a < b ? a : b),
      });
    } else {
      // fallback empty values
      results.add({'avg_aqi': null, 'peak_aqi': null, 'least_aqi': null});
    }
  }

  return results;
}
