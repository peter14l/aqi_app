import 'package:flutter/material.dart';

class FloatingCloud extends StatefulWidget {
  final Duration duration;
  final double startX;
  final double endX;
  final double top;
  final double scale;
  final double opacity;

  const FloatingCloud({
    super.key,
    required this.duration,
    required this.startX,
    required this.endX,
    required this.top,
    this.scale = 1.0,
    this.opacity = 0.8,
  });

  @override
  State<FloatingCloud> createState() => _FloatingCloudState();
}

class _FloatingCloudState extends State<FloatingCloud>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = Tween<double>(
      begin: widget.startX,
      end: widget.endX,
    ).animate(_controller);

    _controller.repeat();
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
        return Positioned(
          top: widget.top,
          left: _animation.value,
          child: Opacity(
            opacity: widget.opacity,
            child: Transform.scale(
              scale: widget.scale,
              child: const Icon(Icons.cloud, size: 100, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
