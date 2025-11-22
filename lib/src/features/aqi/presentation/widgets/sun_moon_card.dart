import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../../constants/app_colors.dart';
import '../../../theme/theme_provider.dart';

class SunMoonCard extends ConsumerWidget {
  final String sunrise;
  final String sunset;
  final bool isSun; // true for Sun, false for Moon

  const SunMoonCard({
    super.key,
    required this.sunrise,
    required this.sunset,
    this.isSun = true,
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
            isSun ? 'Sun' : 'Moon',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                // Arc Painter
                CustomPaint(
                  size: const Size(double.infinity, 100),
                  painter: ArcPainter(
                    color: isSun ? Colors.orange : Colors.purpleAccent,
                    trackColor: textColor.withOpacity(0.1),
                  ),
                ),
                // Times
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatTime(sunrise),
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        isSun ? 'Sunrise' : 'Moonrise',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: labelColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(sunset),
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        isSun ? 'Sunset' : 'Moonset',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: labelColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isSun) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '5 dec', // Mock for now as API doesn't give next full moon easily
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'Next full moon',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: labelColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Waxing crescent', // Mock
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'Moon phase',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: labelColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime);
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (e) {
      return '--:--';
    }
  }
}

class ArcPainter extends CustomPainter {
  final Color color;
  final Color trackColor;

  ArcPainter({required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      -size.height / 2,
      size.width,
      size.height,
    );
    canvas.drawPath(path, paint);

    // Draw progress (mocked to 50% for now)
    final progressPaint =
        Paint()
          ..color = color.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;

    // Simple line for now, complex bezier slicing is hard without path metrics
    // Just drawing a dot at top for visual effect
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.25),
      6,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.25),
      10,
      Paint()..color = color.withOpacity(0.3),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
