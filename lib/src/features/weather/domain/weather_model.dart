class WeatherModel {
  final double temp;
  final double humidity;
  final double windSpeed;
  final double pressure;
  final String condition; // e.g., 'Clear', 'Clouds', 'Rain'
  final String description;
  final int feelsLike;
  final double visibility;
  final int windDirection;
  final double precipitation;
  final double uvIndexMax;
  final String sunrise;
  final String sunset;
  final double precipitationSum;
  final int weatherCode;
  final List<DailyForecast> dailyForecasts;

  WeatherModel({
    required this.temp,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.condition,
    required this.description,
    required this.weatherCode,
    required this.feelsLike,
    required this.visibility,
    required this.windDirection,
    required this.precipitation,
    required this.uvIndexMax,
    required this.sunrise,
    required this.sunset,
    required this.precipitationSum,
    this.dailyForecasts = const [],
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] ?? {};
    final daily = json['daily'] ?? {};

    final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 0.0;
    final humidity =
        (current['relative_humidity_2m'] as num?)?.toDouble() ?? 0.0;
    final pressure = (current['surface_pressure'] as num?)?.toDouble() ?? 0.0;
    final windSpeed = (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0;
    final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;
    final feelsLike = (current['apparent_temperature'] as num?)?.toInt() ?? 0;
    final visibility = (current['visibility'] as num?)?.toDouble() ?? 0.0;
    final windDirection = (current['wind_direction_10m'] as num?)?.toInt() ?? 0;
    final precipitation = (current['precipitation'] as num?)?.toDouble() ?? 0.0;

    // Daily values (take first element for today)
    final uvIndexMax =
        (daily['uv_index_max'] as List?)?.isNotEmpty == true
            ? (daily['uv_index_max'][0] as num).toDouble()
            : 0.0;
    final sunrise =
        (daily['sunrise'] as List?)?.isNotEmpty == true
            ? daily['sunrise'][0].toString()
            : '';
    final sunset =
        (daily['sunset'] as List?)?.isNotEmpty == true
            ? daily['sunset'][0].toString()
            : '';
    final precipitationSum =
        (daily['precipitation_sum'] as List?)?.isNotEmpty == true
            ? (daily['precipitation_sum'][0] as num).toDouble()
            : 0.0;

    // Parse daily forecast
    List<DailyForecast> forecasts = [];
    if (daily['time'] != null) {
      final times = daily['time'] as List;
      final codes = daily['weather_code'] as List;
      final maxTemps = daily['temperature_2m_max'] as List;
      final minTemps = daily['temperature_2m_min'] as List;

      for (var i = 0; i < times.length; i++) {
        if (i >= 7) break; // Limit to 7 days
        forecasts.add(
          DailyForecast(
            date: times[i].toString(),
            weatherCode: (codes[i] as num).toInt(),
            maxTemp: (maxTemps[i] as num).toDouble(),
            minTemp: (minTemps[i] as num).toDouble(),
          ),
        );
      }
    }

    return WeatherModel(
      temp: temp,
      humidity: humidity,
      windSpeed: windSpeed,
      pressure: pressure,
      condition: getCondition(weatherCode),
      description: getDescription(weatherCode),
      weatherCode: weatherCode,
      feelsLike: feelsLike,
      visibility: visibility,
      windDirection: windDirection,
      precipitation: precipitation,
      uvIndexMax: uvIndexMax,
      sunrise: sunrise,
      sunset: sunset,
      precipitationSum: precipitationSum,
      dailyForecasts: forecasts,
    );
  }

  static String getCondition(int code) {
    if (code == 0) return 'Clear';
    if (code >= 1 && code <= 3) return 'Clouds';
    if (code >= 45 && code <= 48) return 'Clouds'; // Fog
    if (code >= 51 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain';
    if (code >= 85 && code <= 86) return 'Snow';
    if (code >= 95 && code <= 99) return 'Rain'; // Thunderstorm
    return 'Clear';
  }

  static String getDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
        return 'Fog';
      case 48:
        return 'Depositing rime fog';
      case 51:
        return 'Light drizzle';
      case 53:
        return 'Moderate drizzle';
      case 55:
        return 'Dense drizzle';
      case 61:
        return 'Slight rain';
      case 63:
        return 'Moderate rain';
      case 65:
        return 'Heavy rain';
      case 71:
        return 'Slight snow fall';
      case 73:
        return 'Moderate snow fall';
      case 75:
        return 'Heavy snow fall';
      case 95:
        return 'Thunderstorm';
      default:
        return 'Unknown';
    }
  }
}

class DailyForecast {
  final String date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;

  DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
  });

  String get condition => WeatherModel.getCondition(weatherCode);
}
