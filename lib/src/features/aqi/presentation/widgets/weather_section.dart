import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/app_colors.dart';
import '../../../theme/theme_provider.dart';
import '../../domain/home_data.dart';

class WeatherSection extends ConsumerWidget {
  final HomeData data;

  const WeatherSection({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final textColor =
        isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark;
    final cardColor =
        isDarkMode
            ? AppColors.getAqiDarkCardColor(data.aqi)
            : Colors.white.withOpacity(0.8);
    final iconColor = isDarkMode ? AppColors.neonCyan : AppColors.iconDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENT WEATHER',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data.temp}°',
                    style: GoogleFonts.outfit(
                      fontSize: 64,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _getWeatherIcon(data.weather.weatherCode),
                        color: iconColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getWeatherDescription(data.weather.weatherCode),
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          color: textColor.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Visual decoration or large icon
              Icon(
                _getWeatherIcon(data.weather.weatherCode),
                size: 80,
                color: iconColor.withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem(
                context,
                Icons.water_drop_outlined,
                'Humidity',
                '${data.humidity}%',
                textColor,
                iconColor,
              ),
              _buildDetailItem(
                context,
                Icons.air,
                'Wind',
                '${data.windSpeed} km/h',
                textColor,
                iconColor,
              ),
              _buildDetailItem(
                context,
                Icons.compress,
                'Pressure',
                '${data.pressure} hPa',
                textColor,
                iconColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color textColor,
    Color iconColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(int code) {
    // WMO Weather interpretation codes (WW)
    if (code == 0) return Icons.wb_sunny_outlined;
    if (code == 1 || code == 2 || code == 3) return Icons.cloud_queue;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 55) return Icons.grain;
    if (code >= 61 && code <= 65) return Icons.water_drop;
    if (code >= 71 && code <= 75) return Icons.ac_unit;
    if (code >= 80 && code <= 82) return Icons.shower;
    if (code >= 95 && code <= 99) return Icons.thunderstorm;
    return Icons.wb_cloudy_outlined;
  }

  String _getWeatherDescription(int code) {
    if (code == 0) return 'Clear sky';
    if (code == 1) return 'Mainly clear';
    if (code == 2) return 'Partly cloudy';
    if (code == 3) return 'Overcast';
    if (code == 45 || code == 48) return 'Foggy';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 61 && code <= 65) return 'Rain';
    if (code >= 71 && code <= 75) return 'Snow';
    if (code >= 80 && code <= 82) return 'Showers';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Cloudy';
  }
}
