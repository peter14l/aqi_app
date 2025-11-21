import 'package:flutter/material.dart';
import 'floating_cloud.dart';
import 'sun_widget.dart';
import 'moon_widget.dart';

class WeatherBackground extends StatelessWidget {
  final String condition; // 'Clear', 'Clouds', 'Rain', 'Snow', etc.
  final bool isNight;
  final Widget child;

  const WeatherBackground({
    super.key,
    required this.condition,
    required this.isNight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Background Gradient (optional, can be handled by Scaffold)

        // Celestial Bodies (Sun/Moon)
        if (isNight)
          const Positioned(top: 60, right: 40, child: MoonWidget())
        else if (condition == 'Clear' ||
            condition == 'Clouds' ||
            condition == 'Snow')
          const Positioned(top: 60, right: 40, child: SunWidget()),

        // Clouds
        if (condition == 'Clouds' ||
            condition == 'Rain' ||
            condition == 'Snow') ...[
          FloatingCloud(
            duration: const Duration(seconds: 25),
            startX: -100,
            endX: screenWidth + 100,
            top: 100,
            scale: 1.2,
            opacity: 0.7,
          ),
          FloatingCloud(
            duration: const Duration(seconds: 35),
            startX: -150,
            endX: screenWidth + 150,
            top: 180,
            scale: 0.8,
            opacity: 0.5,
          ),
          FloatingCloud(
            duration: const Duration(seconds: 45),
            startX: -200,
            endX: screenWidth + 200,
            top: 50,
            scale: 0.6,
            opacity: 0.4,
          ),
        ],

        // Content
        child,
      ],
    );
  }
}
