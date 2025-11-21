import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';

/// Animated AQI circle widget with counting animation
class AnimatedAqiCircle extends StatefulWidget {
  final int targetAqi;
  final String status;
  final Color color;
  final double size;

  const AnimatedAqiCircle({
    super.key,
    required this.targetAqi,
    required this.status,
    required this.color,
    this.size = 320,
  });

  @override
  State<AnimatedAqiCircle> createState() => _AnimatedAqiCircleState();
}

class _AnimatedAqiCircleState extends State<AnimatedAqiCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _aqiAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _aqiAnimation = IntTween(
      begin: 0,
      end: widget.targetAqi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedAqiCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetAqi != widget.targetAqi) {
      _aqiAnimation = IntTween(
        begin: oldWidget.targetAqi,
        end: widget.targetAqi,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
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
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.05),
              border: Border.all(
                color: widget.color.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.1 * _pulseAnimation.value),
                  blurRadius: 40,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_aqiAnimation.value}',
                    style: GoogleFonts.outfit(
                      fontSize: widget.size * 0.375, // 120 for 320
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AQI — ${widget.status}',
                    style: GoogleFonts.outfit(
                      fontSize: widget.size * 0.075, // 24 for 320
                      fontWeight: FontWeight.w500,
                      color: widget.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated number counter widget
class AnimatedCounter extends StatefulWidget {
  final int target;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.target,
    this.style,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = IntTween(
      begin: 0,
      end: widget.target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _animation = IntTween(
        begin: oldWidget.target,
        end: widget.target,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text('${_animation.value}', style: widget.style);
      },
    );
  }
}
