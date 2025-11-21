import '../../weather/domain/weather_model.dart';

class HomeData {
  final int aqi;
  final String status;
  final double pm25;
  final double pm10;
  final double temp;
  final double humidity;
  final double pressure;
  final double windSpeed;
  final WeatherModel weather;

  HomeData({
    required this.aqi,
    required this.status,
    required this.pm25,
    required this.pm10,
    required this.temp,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.weather,
  });

  factory HomeData.from(Map<String, dynamic> aqiData, WeatherModel weather) {
    final iaqi = aqiData['iaqi'] ?? {};
    final pm25Val = (iaqi['pm25']?['v'] as num?)?.toDouble() ?? 0.0;
    final pm10Val = (iaqi['pm10']?['v'] as num?)?.toDouble() ?? 0.0;
    final aqiVal = (aqiData['aqi'] as num?)?.toInt() ?? 0;

    return HomeData(
      aqi: aqiVal,
      status: _getStatus(aqiVal),
      pm25: pm25Val,
      pm10: pm10Val,
      temp: weather.temp,
      humidity: weather.humidity,
      pressure: weather.pressure,
      windSpeed: weather.windSpeed,
      weather: weather,
    );
  }

  static String _getStatus(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }
}
