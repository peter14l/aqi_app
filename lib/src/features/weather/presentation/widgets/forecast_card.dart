import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/app_colors.dart';
import '../../../weather/domain/weather_model.dart';

class ForecastCard extends StatelessWidget {
  final List<DailyForecast> forecasts;

  const ForecastCard({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.greenCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '7-DAY FORECAST',
            style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: forecasts.length,
              itemBuilder: (context, index) {
                final forecast = forecasts[index];
                final date = DateTime.parse(forecast.date);
                final dayName =
                    index == 0 ? 'Today' : DateFormat('EEE').format(date);

                return Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _getWeatherIcon(forecast.weatherCode),
                      const SizedBox(height: 4),
                      Text(
                        '${forecast.maxTemp.round()}°',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${forecast.minTemp.round()}°',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.greenText.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getWeatherIcon(int code) {
    IconData iconData;

    if (code == 0) {
      iconData = Icons.wb_sunny;
    } else if (code >= 1 && code <= 3) {
      iconData = Icons.wb_cloudy;
    } else if (code >= 51 && code <= 67) {
      iconData = Icons.grain; // Rain
    } else if (code >= 71 && code <= 77) {
      iconData = Icons.ac_unit; // Snow
    } else if (code >= 95 && code <= 99) {
      iconData = Icons.flash_on; // Thunderstorm
    } else {
      iconData = Icons.wb_sunny;
    }

    return Icon(iconData, size: 32, color: AppColors.greenText);
  }
}
