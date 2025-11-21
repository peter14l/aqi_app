# Fetch Agent Flutter

This directory contains Dart/Flutter conversions of the Python `fetch_agent` module. All Python code has been converted line-by-line to Dart equivalents.

## Files Converted

1. **exceptions.dart** - Custom exception class for fetch errors
2. **config.dart** - Configuration settings with environment variable support
3. **realtime_aqi.dart** - Real-time AQI fetching from AQICN API
4. **realtime_weather.dart** - Weather data from Open-Meteo API with geocoding support
5. **history_aqi.dart** - Historical AQI data sampling
6. **predict_aqi.dart** - Time-based AQI prediction algorithm
7. **route_exposure.dart** - Route exposure calculation based on multiple coordinates

## Dependencies Required

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
```

## Environment Variables

Set these environment variables before using:

- `WAQI_API_TOKEN` - Your AQICN/WAQI API token from https://aqicn.org/data-platform/token/
- `REQUEST_TIMEOUT` - (Optional) Request timeout in seconds, defaults to 8.0

## Usage Examples

### Real-time AQI
```dart
import 'fetch_agent_flutter/realtime_aqi.dart';

// By coordinates
final aqi = await realtimeAqi('22.5726,88.3639');
print('AQI: $aqi');

// By city name
final aqiCity = await realtimeAqi('delhi');
print('AQI: $aqiCity');
```

### Real-time Weather
```dart
import 'fetch_agent_flutter/realtime_weather.dart';

final weather = await realtimeWeather(22.5726, 88.3639);
print('Temperature: ${weather['temp']}°C');
print('Humidity: ${weather['humidity']}%');
print('Descriptors: ${weather['descriptor']}');
```

### Geocoding
```dart
import 'fetch_agent_flutter/realtime_weather.dart';

final coords = await geocodeCityToLatLon('New York');
print('Lat: ${coords['lat']}, Lon: ${coords['lon']}');
```

### AQI Prediction
```dart
import 'fetch_agent_flutter/predict_aqi.dart';

// Predict AQI for current hour
final predictedAqi = await predictAqi('22.5726,88.3639');

// Predict for specific hour (0-23)
final morningAqi = await predictAqi('22.5726,88.3639', hourOfDay: 8);
print('Predicted morning AQI: $morningAqi');
```

### Historical AQI
```dart
import 'fetch_agent_flutter/history_aqi.dart';

final history = await historyAqi('delhi', months: 12);
for (var month in history) {
  print('Avg: ${month['avg_aqi']}, Peak: ${month['peak_aqi']}');
}
```

### Route Exposure
```dart
import 'fetch_agent_flutter/route_exposure.dart';

final routePoints = [
  {'lat': 22.5, 'lon': 88.3},
  {'lat': 22.6, 'lon': 88.4},
  {'lat': 22.7, 'lon': 88.5},
];

final exposure = await calculateExposure(routePoints);
print('Average AQI: ${exposure['avg_aqi']}');
print('Max AQI: ${exposure['max_aqi']}');
print('Exposure Score: ${exposure['exposure_score']}');
```

## Error Handling

All functions throw `FetchError` exceptions on failure:

```dart
import 'fetch_agent_flutter/exceptions.dart';
import 'fetch_agent_flutter/realtime_aqi.dart';

try {
  final aqi = await realtimeAqi('invalid-location');
} on FetchError catch (e) {
  print('Error: ${e.message}');
}
```

## Notes

- **Not connected to the main app** - These files are standalone and not integrated into the app
- **Line-by-line conversion** - Logic matches the original Python implementation
- **Async/Await** - All network operations use Dart's async/await pattern
- **Type Safety** - Proper Dart type annotations throughout
- **Cross-platform** - Works on all Flutter platforms (iOS, Android, Web, Desktop)

## Differences from Python

1. **Async Operations** - Uses `Future` and `async/await` instead of synchronous calls
2. **Type System** - Explicit type annotations for better IDE support
3. **Null Safety** - Dart's null safety features used throughout
4. **Error Handling** - Uses Dart exceptions instead of Python exceptions
5. **Environment Variables** - Uses `Platform.environment` instead of `os.getenv`
6. **HTTP Client** - Uses `http` package instead of `requests`

## Integration Guide

When ready to integrate into your app:

1. Copy the files to `lib/src/features/aqi/data/fetch_agent/`
2. Update imports in your existing services
3. Replace direct API calls with these functions
4. Add error handling for `FetchError` exceptions
5. Consider caching results to reduce API calls
