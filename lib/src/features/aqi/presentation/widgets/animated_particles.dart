import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedParticles extends StatefulWidget {
  final Color color;
  final int particleCount;
  final double minSize;
  final double maxSize;

  const AnimatedParticles({
    super.key,
    required this.color,
    this.particleCount = 30,
    this.minSize = 2.0,
    this.maxSize = 6.0,
  });

  @override
  State<AnimatedParticles> createState() => _AnimatedParticlesState();
}

class _AnimatedParticlesState extends State<AnimatedParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (index) => Particle(minSize: widget.minSize, maxSize: widget.maxSize),
    );
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
          painter: ParticlesPainter(
            particles: _particles,
            color: widget.color,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double size;
  late double speedX;
  late double speedY;
  late double opacity;

  Particle({required double minSize, required double maxSize}) {
    final random = Random();
    x = random.nextDouble();
    y = random.nextDouble();
    size = minSize + random.nextDouble() * (maxSize - minSize);
    speedX = (random.nextDouble() - 0.5) * 0.02;
    speedY = (random.nextDouble() - 0.5) * 0.02;
    opacity = 0.3 + random.nextDouble() * 0.4;
  }

  void update() {
    x += speedX;
    y += speedY;

    // Wrap around edges
    if (x < 0) x = 1;
    if (x > 1) x = 0;
    if (y < 0) y = 1;
    if (y > 1) y = 0;
  }
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;
  final double progress;

  ParticlesPainter({
    required this.particles,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();

      final paint =
          Paint()
            ..color = color.withOpacity(particle.opacity)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => true;
}
