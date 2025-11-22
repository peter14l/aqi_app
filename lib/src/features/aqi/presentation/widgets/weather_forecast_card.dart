import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/app_colors.dart';
import '../../../weather/domain/weather_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/theme_provider.dart';

class WeatherForecastCard extends ConsumerWidget {
  final List<DailyForecast> dailyForecasts;
  final int aqi;

  const WeatherForecastCard({
    super.key,
    required this.dailyForecasts,
    required this.aqi,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final textColor =
        isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark;
    final cardColor =
        isDarkMode
            ? AppColors.getAqiDarkCardColor(aqi)
            : Colors.white.withOpacity(0.8);
    final dayCardColor =
        isDarkMode
            ? Colors.white.withOpacity(0.05)
            : AppColors.textPrimaryDark.withOpacity(0.03);

    // If no data, show empty or loading
    if (dailyForecasts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '7-DAY FORECAST',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: dailyForecasts.length,
              itemBuilder: (context, index) {
                return _buildDayForecast(
                  dailyForecasts[index],
                  index,
                  textColor,
                  dayCardColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayForecast(
    DailyForecast forecast,
    int index,
    Color textColor,
    Color cardColor,
  ) {
    // Parse date to get day name
    // Date format from API is usually YYYY-MM-DD
    DateTime date;
    try {
      date = DateTime.parse(forecast.date);
    } catch (e) {
      date = DateTime.now().add(Duration(days: index));
    }

    final dayName = _getDayName(date.weekday);
    final isToday = index == 0;

    // Map weather code to icon
    final iconData = _getIconForCode(forecast.weatherCode);
    final iconColor = _getColorForCode(forecast.weatherCode);

    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isToday ? 'Today' : dayName,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Icon(iconData, color: iconColor, size: 28),
          const SizedBox(height: 4),
          Column(
            children: [
              Text(
                '${forecast.maxTemp.round()}°',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                '${forecast.minTemp.round()}°',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  IconData _getIconForCode(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code >= 1 && code <= 3) return Icons.wb_cloudy;
    if (code >= 45 && code <= 48) return Icons.cloud;
    if (code >= 51 && code <= 67) return Icons.grain;
    if (code >= 71 && code <= 77) return Icons.ac_unit;
    if (code >= 80 && code <= 82) return Icons.grain;
    if (code >= 85 && code <= 86) return Icons.ac_unit;
    if (code >= 95 && code <= 99) return Icons.thunderstorm;
    return Icons.wb_sunny;
  }

  Color _getColorForCode(int code) {
    if (code == 0) return const Color(0xFFFFA500); // Sunny
    if (code >= 1 && code <= 3) return const Color(0xFF9E9E9E); // Cloudy
    if (code >= 45 && code <= 48) return const Color(0xFF757575); // Fog
    if (code >= 51 && code <= 67) return const Color(0xFF4FC3F7); // Rain
    if (code >= 71 && code <= 77) return const Color(0xFF81D4FA); // Snow
    if (code >= 95 && code <= 99)
      return const Color(0xFF5C6BC0); // Thunderstorm
    return const Color(0xFFFFA500);
  }
}
