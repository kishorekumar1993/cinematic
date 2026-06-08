import 'dart:math';
import 'package:flutter/material.dart';

class LightRayEffect extends StatefulWidget {
  final Color color;
  final BlendMode blendMode;

  const LightRayEffect({
    super.key,
    this.color = const Color(0x33FFFFFF),
    this.blendMode = BlendMode.screen,
  });

  @override
  State<LightRayEffect> createState() => _LightRayEffectState();
}

class _LightRayEffectState extends State<LightRayEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat(reverse: true);
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
          painter: _LightRayPainter(progress: _controller.value, color: widget.color, blendMode: widget.blendMode),
          child: Container(),
        );
      },
    );
  }
}

class _LightRayPainter extends CustomPainter {
  final double progress;
  final Color color;
  final BlendMode blendMode;

  _LightRayPainter({required this.progress, required this.color, required this.blendMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..blendMode = blendMode
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, color.withValues(alpha: 0.0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    double offset = sin(progress * pi) * (size.width * 0.4);

    path.moveTo(size.width * 0.2 + offset, -size.height * 0.2);
    path.lineTo(size.width * 0.8 + offset, -size.height * 0.2);
    path.lineTo(size.width + offset, size.height * 1.2);
    path.lineTo(-size.width * 0.2 + offset, size.height * 1.2);
    path.close();

    canvas.drawPath(path, paint);
    
    final path2 = Path();
    double offset2 = cos(progress * pi) * (size.width * 0.3);
    path2.moveTo(size.width * 0.5 + offset2, -size.height * 0.1);
    path2.lineTo(size.width * 0.9 + offset2, -size.height * 0.1);
    path2.lineTo(size.width * 0.4 + offset2, size.height);
    path2.lineTo(size.width * 0.1 + offset2, size.height);
    path2.close();
    
    // We recreate shader for the second ray just to be safe, or draw direct with color
    final paint2 = Paint()
      ..blendMode = blendMode
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: color.a * 0.5), color.withValues(alpha: 0.0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _LightRayPainter oldDelegate) => true;
}
