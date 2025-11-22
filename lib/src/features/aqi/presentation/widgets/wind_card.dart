import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../../constants/app_colors.dart';
import '../../../theme/theme_provider.dart';

class WindCard extends ConsumerWidget {
  final double windSpeed;
  final int windDirection;

  const WindCard({
    super.key,
    required this.windSpeed,
    required this.windDirection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final textColor =
        isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark;
    final cardColor =
        isDarkMode ? AppColors.darkCard : Colors.white.withOpacity(0.8);
    final labelColor = AppColors.textTertiary;

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
            'Wind',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${windSpeed.round()}',
                          style: GoogleFonts.outfit(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'km/h',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: labelColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'From the ${_getDirectionText(windDirection)}',
                      style: GoogleFonts.outfit(fontSize: 14, color: textColor),
                    ),
                    Text(
                      'Force: ${_getBeaufortScale(windSpeed)}',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: labelColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: CompassPainter(
                    direction: windDirection.toDouble(),
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDirectionText(int degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) % 360) ~/ 45;
    return directions[index];
  }

  String _getBeaufortScale(double speed) {
    if (speed < 1) return '0 (Calm)';
    if (speed < 6) return '1 (Light air)';
    if (speed < 12) return '2 (Light breeze)';
    if (speed < 20) return '3 (Gentle breeze)';
    if (speed < 29) return '4 (Moderate breeze)';
    if (speed < 39) return '5 (Fresh breeze)';
    if (speed < 50) return '6 (Strong breeze)';
    return '7+ (High wind)';
  }
}

class CompassPainter extends CustomPainter {
  final double direction;
  final Color color;

  CompassPainter({required this.direction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint =
        Paint()
          ..color = color.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Draw circle
    canvas.drawCircle(center, radius, paint);

    // Draw ticks
    for (var i = 0; i < 4; i++) {
      final angle = i * 90 * math.pi / 180;
      final p1 = Offset(
        center.dx + (radius - 5) * math.cos(angle),
        center.dy + (radius - 5) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(p1, p2, paint..color = color.withOpacity(0.3));
    }

    // Draw letters
    _drawText(canvas, center, radius - 15, 'N', -90);
    _drawText(canvas, center, radius - 15, 'E', 0);
    _drawText(canvas, center, radius - 15, 'S', 90);
    _drawText(canvas, center, radius - 15, 'W', 180);

    // Draw Arrow
    final arrowPaint =
        Paint()
          ..color = Colors.blueAccent
          ..style = PaintingStyle.fill;

    final angle = (direction - 90) * math.pi / 180;
    final arrowPath = Path();
    final tip = Offset(
      center.dx + (radius - 25) * math.cos(angle),
      center.dy + (radius - 25) * math.sin(angle),
    );
    final base1 = Offset(
      center.dx + 10 * math.cos(angle + 2.5),
      center.dy + 10 * math.sin(angle + 2.5),
    );
    final base2 = Offset(
      center.dx + 10 * math.cos(angle - 2.5),
      center.dy + 10 * math.sin(angle - 2.5),
    );

    arrowPath.moveTo(tip.dx, tip.dy);
    arrowPath.lineTo(base1.dx, base1.dy);
    arrowPath.lineTo(base2.dx, base2.dy);
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  void _drawText(
    Canvas canvas,
    Offset center,
    double radius,
    String text,
    double angleDeg,
  ) {
    final angle = angleDeg * math.pi / 180;
    final x = center.dx + radius * math.cos(angle);
    final y = center.dy + radius * math.sin(angle);

    final textSpan = TextSpan(
      text: text,
      style: GoogleFonts.outfit(
        fontSize: 10,
        color: color.withOpacity(0.5),
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
