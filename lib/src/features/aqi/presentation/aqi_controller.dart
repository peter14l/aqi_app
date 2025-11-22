import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/aqi_service.dart';
import '../data/weather_service.dart';
import '../data/location_state_provider.dart';
import '../domain/home_data.dart';
import '../../weather/domain/weather_model.dart';

final aqiControllerProvider = FutureProvider<HomeData>((ref) async {
  // Watch location changes
  final location = ref.watch(locationProvider);

  // Default to Cracow if no location selected
  final lat = location?.latitude ?? 50.0647;
  final lon = location?.longitude ?? 19.9450;

  // Use new services
  final aqiService = AqiService();
  final weatherService = WeatherService();

  try {
    final results = await Future.wait<dynamic>([
      aqiService.getAqiByCoordinates(lat, lon),
      weatherService.getWeatherByCoordinates(lat, lon),
    ]);

    final aqiData = results[0] as Map<String, dynamic>;
    final weatherData = results[1] as Map<String, dynamic>;
    final current = weatherData['current'] as Map<String, dynamic>;
    final daily = weatherData['daily'] as Map<String, dynamic>;

    // Construct DailyForecast list
    final List<DailyForecast> dailyForecasts = [];
    final dates = daily['dates'] as List;
    final maxTemps = daily['maxTemps'] as List;
    final minTemps = daily['minTemps'] as List;
    final weatherCodes = daily['weatherCodes'] as List;

    for (var i = 0; i < dates.length; i++) {
      if (i >= 7) break;
      dailyForecasts.add(
        DailyForecast(
          date: dates[i] as String,
          weatherCode: weatherCodes[i] as int,
          maxTemp: (maxTemps[i] as num).toDouble(),
          minTemp: (minTemps[i] as num).toDouble(),
        ),
      );
    }

    final currentCode = current['weatherCode'] as int;
    final weather = WeatherModel(
      temp: (current['temp'] as num).toDouble(),
      humidity: (current['humidity'] as num).toDouble(),
      pressure: (current['pressure'] as num).toDouble(),
      windSpeed: (current['windSpeed'] as num).toDouble(),
      condition: WeatherModel.getCondition(currentCode),
      description: WeatherModel.getDescription(currentCode),
      weatherCode: currentCode,
      feelsLike: (current['feelsLike'] as num).toInt(),
      visibility: (current['visibility'] as num).toDouble(),
      windDirection: (current['windDirection'] as num).toInt(),
      precipitation: (current['precipitation'] as num).toDouble(),
      uvIndexMax:
          (daily['uvIndexMax'] != null &&
                  (daily['uvIndexMax'] as List).isNotEmpty)
              ? (daily['uvIndexMax'][0] as num).toDouble()
              : 0.0,
      sunrise:
          (daily['sunrise'] != null && (daily['sunrise'] as List).isNotEmpty)
              ? daily['sunrise'][0].toString()
              : '',
      sunset:
          (daily['sunset'] != null && (daily['sunset'] as List).isNotEmpty)
              ? daily['sunset'][0].toString()
              : '',
      precipitationSum:
          (daily['precipitationSum'] != null &&
                  (daily['precipitationSum'] as List).isNotEmpty)
              ? (daily['precipitationSum'][0] as num).toDouble()
              : 0.0,
      dailyForecasts: dailyForecasts,
    );

    // Map API data to HomeData
    return HomeData(
      aqi: aqiData['aqi'] as int,
      status: _getAqiStatus(aqiData['aqi'] as int),
      pm10: (aqiData['pm10'] as num).toDouble(),
      pm25: (aqiData['pm25'] as num).toDouble(),
      temp: weather.temp,
      humidity: weather.humidity,
      pressure: weather.pressure,
      windSpeed: weather.windSpeed,
      weather: weather,
    );
  } catch (e) {
    // Fallback or rethrow
    throw Exception('Failed to fetch data: $e');
  } finally {
    aqiService.dispose();
    weatherService.dispose();
  }
});

String _getAqiStatus(int aqi) {
  if (aqi <= 50) return 'Good';
  if (aqi <= 100) return 'Moderate';
  if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
  if (aqi <= 200) return 'Unhealthy';
  if (aqi <= 300) return 'Very Unhealthy';
  return 'Hazardous';
}
