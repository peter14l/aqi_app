import 'realtime_aqi.dart';

/// Simple rule-based predictor:
///   - base = current aqi
///   - morning/evening traffic bump
///   - apply weather-based multiplier optionally (not included here)
/// latOrLoc: either a "lat,lon" string or a city name. If lon provided then latOrLoc is lat.
Future<int> predictAqi(dynamic latOrLoc, {double? lon, int? hourOfDay}) async {
  // determine location input for realtime_aqi
  String location;
  if (lon != null) {
    location = '$latOrLoc,$lon';
  } else {
    location = latOrLoc.toString();
  }

  final base = await realtimeAqi(location);
  final hour =
      hourOfDay ??
      DateTime.now()
          .toUtc()
          .hour; // naive UTC hour; adjust for timezone if needed

  // rules (tweak to taste)
  int pred;
  if (hour >= 5 && hour < 9) {
    // morning rush: +15%
    pred = (base * 1.15).toInt();
  } else if (hour >= 17 && hour < 21) {
    // evening rush: +25%
    pred = (base * 1.25).toInt();
  } else if (hour >= 0 && hour < 5) {
    pred = (base * 0.8).toInt(); // lower at night
  } else {
    pred = base;
  }

  // clamp
  if (pred < 0) {
    pred = 0;
  }

  return pred;
}
