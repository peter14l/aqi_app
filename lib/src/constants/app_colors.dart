import 'package:flutter/material.dart';

class AppColors {
  // Futuristic Dark Theme - Base Colors
  static const Color darkBackground = Color(0xFF0A0E27);
  static const Color darkSurface = Color(0xFF1A1F3A);
  static const Color darkCard = Color(0xFF252B48);

  // Neon Accent Colors
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color neonPurple = Color(0xFFBF40BF);
  static const Color neonPink = Color(0xFFFF10F0);
  static const Color neonBlue = Color(0xFF0080FF);
  static const Color neonGreen = Color(0xFF39FF14);

  // Primary Gradient Colors
  static const Color gradientStart = Color(0xFF667EEA);
  static const Color gradientEnd = Color(0xFF764BA2);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8C5D6);
  static const Color textTertiary = Color(0xFF6B7A99);

  // AQI Level Colors (Futuristic)
  static const Color aqiGood = Color(0xFF00FFA3);
  static const Color aqiModerate = Color(0xFFFFD700);
  static const Color aqiUnhealthySensitive = Color(0xFFFF8C00);
  static const Color aqiUnhealthy = Color(0xFFFF4757);
  static const Color aqiVeryUnhealthy = Color(0xFFD946EF);
  static const Color aqiHazardous = Color(0xFFDC143C);

  // Glass Effect Colors
  static const Color glassLight = Color(0x1AFFFFFF);
  static const Color glassMedium = Color(0x33FFFFFF);
  static const Color glassDark = Color(0x0DFFFFFF);

  // Shimmer/Glow Colors
  static const Color shimmerHighlight = Color(0x40FFFFFF);
  static const Color glowCyan = Color(0x6000F5FF);
  static const Color glowPurple = Color(0x60BF40BF);

  // New UI Overhaul Colors
  static const Color aqiGreenBackground = Color(0xFFB1E55C); // Lime Green
  static const Color aqiOrangeBackground = Color(0xFFFF9F69); // Salmon Orange
  static const Color particulatesCardBackground = Colors.white;
  static const Color textPrimaryDark = Color(0xFF1F2937); // Dark Grey/Black
  static const Color iconDark = Color(0xFF1F2937);

  // Legacy compatibility (mapped to new colors)
  static const Color greenBackground = darkBackground;
  static const Color greenText = neonCyan;
  static const Color greenAccent = neonGreen;
  static const Color greenCard = darkCard;
  static const Color orangeBackground = darkSurface;
  static const Color orangeText = textPrimary;
  static const Color orangeCard = darkCard;
  static const Color orangeAccent = neonPink;

  // Utility
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color error = Color(0xFFFF4757);
  static const Color warning = Color(0xFFFFD700);
  static const Color success = Color(0xFF00FFA3);
  static const Color info = Color(0xFF0080FF);

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonCyan, neonPurple],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1F3A), Color(0xFF252B48)],
  );

  // Get AQI color based on value
  static Color getAqiColor(int aqi) {
    if (aqi <= 50) return aqiGood;
    if (aqi <= 100) return aqiModerate;
    if (aqi <= 150) return aqiUnhealthySensitive;
    if (aqi <= 200) return aqiUnhealthy;
    if (aqi <= 300) return aqiVeryUnhealthy;
    return aqiHazardous;
  }

  // Get gradient for AQI
  static LinearGradient getAqiGradient(int aqi) {
    final color = getAqiColor(aqi);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color.withOpacity(0.6), color.withOpacity(0.3)],
    );
  }

  // Get background color based on AQI
  static Color getAqiBackgroundColor(int aqi) {
    if (aqi <= 50) return aqiGreenBackground;
    if (aqi <= 100) return aqiOrangeBackground; // Moderate
    if (aqi <= 150)
      return aqiOrangeBackground; // Unhealthy for Sensitive Groups
    return aqiOrangeBackground; // Default to orange for higher values for now, or add more specific ones
  }

  // Get dark background color based on AQI
  static Color getAqiDarkBackgroundColor(int aqi) {
    if (aqi <= 50) return const Color(0xFF052E16); // Deep Green
    return const Color(0xFF3F1808); // Deep Orange/Brown
  }

  // Get dark card color based on AQI
  static Color getAqiDarkCardColor(int aqi) {
    if (aqi <= 50) return const Color(0xFF0A4523); // Dark Green Card
    return const Color(0xFF5C240D); // Dark Orange Card
  }
}
