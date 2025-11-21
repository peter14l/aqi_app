import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_colors.dart';
import '../../theme/theme_provider.dart';
import 'aqi_controller.dart';

class PredictionScreen extends ConsumerWidget {
  const PredictionScreen({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(aqiControllerProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final textColor =
        isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark;
    final cardColor =
        isDarkMode ? AppColors.darkCard : AppColors.particulatesCardBackground;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Weekly Forecast',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: homeDataAsync.when(
        data: (data) {
          final forecasts = data.weather.dailyForecasts;
          final currentAqi = data.aqi;

          if (forecasts.isEmpty) {
            return Center(
              child: Text(
                'No forecast data available',
                style: GoogleFonts.outfit(color: textColor),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: forecasts.length,
            itemBuilder: (context, index) {
              final forecast = forecasts[index];
              final date = DateTime.parse(forecast.date);

              // Simulate AQI based on weather and current AQI
              final simulatedAqi = _calculateForecastAqi(
                currentAqi,
                forecast.weatherCode,
                index,
              );
              final status = _getStatus(simulatedAqi);
              final bgColor = _getAqiColor(simulatedAqi);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: bgColor.withOpacity(0.3), width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: bgColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getDayName(date.weekday),
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} • ${forecast.condition}',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$simulatedAqi',
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  int _calculateForecastAqi(int currentAqi, int weatherCode, int dayIndex) {
    // Base calculation on current AQI
    double modifier = 1.0;

    // Weather code adjustments (WMO codes)
    if (weatherCode >= 51) {
      // Rain/Snow/Drizzle -> Better AQI
      modifier = 0.7;
    } else if (weatherCode <= 3) {
      // Clear/Cloudy -> Similar or slightly worse if stagnant
      modifier = 1.1;
    }

    // Add some randomness based on day index to simulate fluctuation
    // Using sin wave to make it look natural
    final fluctuation = (dayIndex % 2 == 0) ? 1.05 : 0.95;

    return (currentAqi * modifier * fluctuation).round().clamp(0, 500);
  }

  String _getStatus(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for SG';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return AppColors.aqiGood;
    if (aqi <= 100) return AppColors.aqiModerate;
    if (aqi <= 150) return AppColors.aqiUnhealthySensitive;
    if (aqi <= 200) return AppColors.aqiUnhealthy;
    if (aqi <= 300) return AppColors.aqiVeryUnhealthy;
    return AppColors.aqiHazardous;
  }
}
