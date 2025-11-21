import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../../constants/app_colors.dart';
import '../../theme/theme_toggle_button.dart';
import '../../theme/theme_provider.dart';
import 'aqi_controller.dart';
import '../domain/home_data.dart';
import 'widgets/animated_particles.dart';
import 'widgets/weather_forecast_card.dart';
import 'widgets/weather_section.dart';
import 'widgets/location_search_dialog.dart';
import 'widgets/slide_to_refresh_button.dart';
import '../data/location_state_provider.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../share/share_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(aqiControllerProvider);
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final isDarkMode = ref.watch(isDarkModeProvider);

    return homeDataAsync.when(
      data: (data) {
        // Determine colors based on theme mode
        final backgroundColor =
            isDarkMode
                ? AppColors.darkBackground
                : AppColors.getAqiBackgroundColor(data.aqi);

        return Scaffold(
          backgroundColor: backgroundColor,
          body:
              isDesktop
                  ? _buildDesktopLayout(context, ref, data, isDarkMode)
                  : _buildMobileLayout(
                    context,
                    ref,
                    data,
                    backgroundColor,
                    isDarkMode,
                  ),
        );
      },
      loading:
          () => const Scaffold(
            backgroundColor: AppColors.darkBackground,
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const SkeletonCard(height: 200),
                  const SizedBox(height: 24),
                  const SkeletonCard(height: 150),
                  const SizedBox(height: 24),
                  Expanded(
                    child: const SkeletonList(itemCount: 3, itemHeight: 80),
                  ),
                ],
              ),
            ),
          ),
      error:
          (err, stack) => Scaffold(
            backgroundColor: AppColors.darkBackground,
            body: Center(
              child: Text(
                'Error: $err',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    HomeData data,
    Color backgroundColor,
    bool isDarkMode,
  ) {
    final textColor =
        isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark;
    final cardColor =
        isDarkMode ? AppColors.darkCard : AppColors.particulatesCardBackground;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header
            Row(
              children: [
                // // Back Button (Visual only for now as it's home)
                // Container(
                //   padding: const EdgeInsets.all(8),
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     border: Border.all(color: textColor.withOpacity(0.3)),
                //   ),
                //   child: Icon(Icons.arrow_back, color: textColor),
                // ),
                // const SizedBox(width: 16),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final location = ref.watch(locationProvider);
                      return Text(
                        location?.name ?? 'Unknown',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const ThemeToggleButton(),
                const SizedBox(width: 8),
                // Share Button
                InkWell(
                  onTap: () async {
                    await ShareService.shareAqiText(
                      aqi: data.aqi,
                      status: data.status,
                      location: ref.read(locationProvider)?.name ?? 'Unknown',
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: textColor.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.share, color: textColor),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const LocationSearchDialog(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: textColor.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.search, color: textColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 2. AQI Big Number
            // 2. AQI Big Number
            AnimatedAqiCircle(
              targetAqi: data.aqi,
              status: data.status,
              color: textColor,
              size: 120,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AQI — ${data.status}',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    color: textColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.cloud_outlined, color: textColor),
                    const SizedBox(width: 16),
                    Icon(Icons.share_outlined, color: textColor),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 3. Particulates Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 16),
              constraints: const BoxConstraints(minHeight: 150, maxHeight: 270),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Animated Particles Background
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: AnimatedParticles(
                      color:
                          isDarkMode
                              ? AppColors.neonCyan.withOpacity(0.2)
                              : (data.aqi <= 50
                                  ? AppColors.aqiGreenBackground.withOpacity(
                                    0.6,
                                  )
                                  : AppColors.aqiOrangeBackground.withOpacity(
                                    0.6,
                                  )),
                      particleCount: 40,
                      minSize: 3.0,
                      maxSize: 8.0,
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PARTICULATES',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${data.pm10}%',
                                  style: GoogleFonts.outfit(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  'PM10 - ${data.pm10} µg/m³',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${data.pm25}%',
                                  style: GoogleFonts.outfit(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  'PM2.5 - ${data.pm25} µg/m³',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const SizedBox(
                          height: 16,
                        ), // Extra spacing at the bottom
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 4. Weather Section
            WeatherSection(data: data),

            // 5. Weather Forecast Card
            const SizedBox(height: 16),
            WeatherForecastCard(dailyForecasts: data.weather.dailyForecasts),

            // 6. Refresh Button
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              child: ElevatedButton(
                onPressed: () => ref.refresh(aqiControllerProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDarkMode
                          ? AppColors.neonCyan
                          : AppColors.textPrimaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: Text(
                  'Refresh >>>',
                  style: GoogleFonts.outfit(
                    color: isDarkMode ? AppColors.darkBackground : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    HomeData data,
    bool isDarkMode,
  ) {
    final textColor =
        isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark;
    final cardColor =
        isDarkMode ? AppColors.darkCard : AppColors.particulatesCardBackground;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: AQI + Particulates
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      // AQI Circle
                      AnimatedAqiCircle(
                        targetAqi: data.aqi,
                        status: data.status,
                        color: AppColors.getAqiColor(data.aqi),
                        size: 280, // Reduced size to prevent overflow
                      ),
                      const SizedBox(height: 40),

                      // Particulates Card
                      Container(
                        height: 280,
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Stack(
                          children: [
                            // Animated Particles Background
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: AnimatedParticles(
                                  color:
                                      isDarkMode
                                          ? AppColors.neonCyan.withOpacity(0.2)
                                          : (data.aqi <= 50
                                              ? AppColors.aqiGreenBackground
                                                  .withOpacity(0.6)
                                              : AppColors.aqiOrangeBackground
                                                  .withOpacity(0.6)),
                                  particleCount: 40,
                                  minSize: 3.0,
                                  maxSize: 8.0,
                                ),
                              ),
                            ),
                            // Content
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PARTICULATES',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: AppColors.textTertiary,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildParticulateItem(
                                        'PM10',
                                        data.pm10.round(),
                                        'µg/m³',
                                        textColor,
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 50,
                                      color: textColor.withOpacity(0.1),
                                    ),
                                    Expanded(
                                      child: _buildParticulateItem(
                                        'PM2.5',
                                        data.pm25.round(),
                                        'µg/m³',
                                        textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Refresh Button
                      SizedBox(
                        width: double.infinity,
                        child: SlideToRefreshButton(
                          onRefresh: () async {
                            await Future.delayed(const Duration(seconds: 1));
                            return ref.refresh(aqiControllerProvider.future);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 40),

                // Right Column: Weather + Forecast
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      // Weather Section
                      WeatherSection(data: data),

                      const SizedBox(height: 24),

                      // Weather Forecast Card
                      WeatherForecastCard(
                        dailyForecasts: data.weather.dailyForecasts,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParticulateItem(
    String label,
    int value,
    String unit,
    Color textColor,
  ) {
    return Column(
      children: [
        Text(
          '$value',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(
          '$label - $unit',
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
