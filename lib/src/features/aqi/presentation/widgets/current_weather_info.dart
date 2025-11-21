import 'package:flutter/material.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../weather/domain/weather_model.dart';

class CurrentWeatherInfo extends StatelessWidget {
  final WeatherModel weather;

  const CurrentWeatherInfo({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${weather.temp.round()}°',
          style: AppTextStyles.displayLarge.copyWith(fontSize: 80),
        ),
        Text(
          weather.description.toUpperCase(),
          style: AppTextStyles.titleMedium.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
