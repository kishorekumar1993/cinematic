import 'dart:math';
import 'package:flutter/material.dart';

class SmokeEffect extends StatefulWidget {
  final Color color;

  const SmokeEffect({
    super.key,
    this.color = const Color(0x22FFFFFF),
  });

  @override
  State<SmokeEffect> createState() => _SmokeEffectState();
}

class _SmokeEffectState extends State<SmokeEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
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
          painter: _SmokePainter(progress: _controller.value, color: widget.color),
          child: Container(),
        );
      },
    );
  }
}

class _SmokePainter extends CustomPainter {
  final double progress;
  final Color color;

  _SmokePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80)
      ..color = color;

    double x1 = size.width * (0.5 + 0.6 * sin(progress * pi * 2));
    double y1 = size.height * (0.8 + 0.2 * cos(progress * pi * 2));
    canvas.drawCircle(Offset(x1, y1), size.width * 0.8, paint1);

    double x2 = size.width * (0.5 + 0.4 * cos(progress * pi * 2 + pi));
    double y2 = size.height * (0.7 + 0.3 * sin(progress * pi * 2));
    canvas.drawCircle(Offset(x2, y2), size.width * 0.9, paint1);
    
    double x3 = size.width * (0.5 + 0.5 * sin(progress * pi * 4));
    double y3 = size.height * (0.9 + 0.1 * cos(progress * pi * 2));
    canvas.drawCircle(Offset(x3, y3), size.width * 1.0, paint1);
  }

  @override
  bool shouldRepaint(covariant _SmokePainter oldDelegate) => true;
}
