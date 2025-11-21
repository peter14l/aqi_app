import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';

class ParticulatesCard extends StatelessWidget {
  final double pm25;
  final double pm10;

  const ParticulatesCard({super.key, required this.pm25, required this.pm10});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.greenCard,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PARTICULATES', style: AppTextStyles.labelSmall),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildParticulateItem(
                  label: 'PM10',
                  value: pm10,
                  percentage: 20, // Example mock percentage
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildParticulateItem(
                  label: 'PM2.5',
                  value: pm25,
                  percentage: 40, // Example mock percentage
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticulateItem({
    required String label,
    required double value,
    required int percentage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$percentage%', style: AppTextStyles.titleLarge),
        const SizedBox(height: 4),
        Text(
          '$label - ${value.toInt()} µg/m³',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.greenText.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        // Particle visualization
        Container(
          height: percentage * 1.5, // Dynamic height based on percentage
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.transparent),
          child: _AnimatedParticles(density: percentage / 100),
        ),
      ],
    );
  }
}

class _AnimatedParticles extends StatefulWidget {
  final double density;
  const _AnimatedParticles({required this.density});

  @override
  State<_AnimatedParticles> createState() => _AnimatedParticlesState();
}

class _AnimatedParticlesState extends State<_AnimatedParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            density: widget.density,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double density;
  final double progress;

  ParticlePainter({required this.density, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.greenBackground
          ..style = PaintingStyle.fill;

    final count = (density * 50).toInt();
    for (var i = 0; i < count; i++) {
      // Simple deterministic pseudo-random motion
      final initialX = (i * 13.0 * 7.0) % size.width;
      final initialY = (i * 7.0 * 13.0) % size.height;

      // Move particles slightly
      final dx = (i % 2 == 0 ? 1 : -1) * 10 * progress;
      final dy = (i % 3 == 0 ? 1 : -1) * 5 * progress;

      final x = (initialX + dx) % size.width;
      final y = (initialY + dy) % size.height;

      // Wrap around logic adjustment
      final drawX = x < 0 ? x + size.width : x;
      final drawY = y < 0 ? y + size.height : y;

      canvas.drawCircle(Offset(drawX, drawY), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.density != density;
}
