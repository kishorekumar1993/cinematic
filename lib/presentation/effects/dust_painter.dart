import 'dart:math';
import 'package:flutter/material.dart';

class DustEffect extends StatefulWidget {
  final Color color;
  final int count;
  final double speedMultiplier;

  const DustEffect({
    super.key,
    this.color = const Color(0xFFFFD700),
    this.count = 40,
    this.speedMultiplier = 1.0,
  });

  @override
  State<DustEffect> createState() => _DustEffectState();
}

class _DustEffectState extends State<DustEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_DustParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    for (int i = 0; i < widget.count; i++) {
      _particles.add(_DustParticle.random(_random));
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
      builder: (context, _) {
        return CustomPaint(
          painter: _DustPainter(
            particles: _particles,
            progress: _controller.value,
            color: widget.color,
            speedMultiplier: widget.speedMultiplier,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _DustParticle {
  double x, y, size, speed, drift;
  _DustParticle({required this.x, required this.y, required this.size, required this.speed, required this.drift});

  factory _DustParticle.random(Random rand) {
    return _DustParticle(
      x: rand.nextDouble(),
      y: rand.nextDouble(),
      size: rand.nextDouble() * 2.5 + 0.5,
      speed: rand.nextDouble() * 0.05 + 0.01,
      drift: rand.nextDouble() * 0.1 - 0.05,
    );
  }
}

class _DustPainter extends CustomPainter {
  final List<_DustParticle> particles;
  final double progress;
  final Color color;
  final double speedMultiplier;

  _DustPainter({required this.particles, required this.progress, required this.color, required this.speedMultiplier});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    for (var p in particles) {
      double currentY = p.y - (progress * p.speed * speedMultiplier);
      if (currentY < 0) currentY = 1.0 + (currentY % 1.0);
      
      double currentX = p.x + (progress * p.drift);
      currentX = currentX % 1.0;
      if (currentX < 0) currentX += 1.0;

      final double opacity = sin(progress * pi * 4 + p.size) * 0.4 + 0.4;
      paint.color = color.withValues(alpha: opacity);

      canvas.drawCircle(Offset(currentX * size.width, currentY * size.height), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter oldDelegate) => true;
}
