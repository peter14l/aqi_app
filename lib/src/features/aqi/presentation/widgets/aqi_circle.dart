import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_theme.dart';

class AqiCircle extends StatefulWidget {
  final int aqiValue;
  final String status;

  const AqiCircle({super.key, required this.aqiValue, required this.status});

  @override
  State<AqiCircle> createState() => _AqiCircleState();
}

class _AqiCircleState extends State<AqiCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getAqiColor() {
    return AppColors.getAqiColor(widget.aqiValue);
  }

  @override
  Widget build(BuildContext context) {
    final aqiColor = _getAqiColor();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration(
        borderColor: aqiColor.withOpacity(0.3),
      ),
      child: Column(
        children: [
          // Animated AQI Circle
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: aqiColor.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: aqiColor.withOpacity(0.2),
                        blurRadius: 80,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating outer ring
                      Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: CustomPaint(
                          size: const Size(220, 220),
                          painter: NeonRingPainter(
                            color: aqiColor,
                            progress: widget.aqiValue / 500,
                          ),
                        ),
                      ),
                      // Inner circle with glass effect
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.glassLight, AppColors.glassDark],
                          ),
                          border: Border.all(
                            color: aqiColor.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // AQI Value
                            ShaderMask(
                              shaderCallback:
                                  (bounds) => LinearGradient(
                                    colors: [
                                      aqiColor,
                                      aqiColor.withOpacity(0.7),
                                    ],
                                  ).createShader(bounds),
                              child: Text(
                                '${widget.aqiValue}',
                                style: GoogleFonts.orbitron(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // AQI Label
                            Text(
                              'AQI',
                              style: GoogleFonts.orbitron(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [aqiColor.withOpacity(0.3), aqiColor.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: aqiColor.withOpacity(0.5), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: aqiColor,
                    boxShadow: [
                      BoxShadow(
                        color: aqiColor.withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.status.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: aqiColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for neon ring
class NeonRingPainter extends CustomPainter {
  final Color color;
  final double progress;

  NeonRingPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer glow
    final glowPaint =
        Paint()
          ..color = color.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(center, radius - 4, glowPaint);

    // Main ring
    final ringPaint =
        Paint()
          ..shader = SweepGradient(
            colors: [color, color.withOpacity(0.5), color],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      ringPaint,
    );

    // Inner dots (decorative)
    for (int i = 0; i < 8; i++) {
      final angle = (2 * math.pi / 8) * i;
      final dotX = center.dx + (radius - 10) * math.cos(angle);
      final dotY = center.dy + (radius - 10) * math.sin(angle);

      final dotPaint =
          Paint()
            ..color = color.withOpacity(0.3)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, dotY), 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
