import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/presentation/tempelate/scene_design_system.dart';
import 'package:cinematic/presentation/effects/dust_painter.dart';
import 'package:cinematic/presentation/effects/smoke_painter.dart';
import 'package:cinematic/presentation/effects/light_ray_painter.dart';

/// -----------------------------------------------------------------------
/// DEVOTIONAL TEMPLATE 5 – DIVINE LIGHT (Full-screen Holy Glow)
/// Pure white / ivory with a blazing holy-light column and minimal
/// centered text. Great for "Word of God" / scripture verse reels.
///
/// Scene mapping:
///   scene.hook        → divine proclamation hook
///   scene.subtitle    → label (e.g. "THE WORD OF GOD")
///   scene.title       → scripture verse headline
///   scene.body        → reflection / commentary
///   scene.keyPoints   → revelations (max 3)
///   scene.closureLine → final blessing
///   scene.effect      → motion preset
/// -----------------------------------------------------------------------

class DevotionalSceneFive extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const DevotionalSceneFive({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<DevotionalSceneFive> createState() => _DevotionalSceneFiveState();
}

class _DevotionalSceneFiveState extends State<DevotionalSceneFive>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<Offset> _pan;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _lightBeam;
  late Animation<double> _lightPulse;

  static const double _hookEnd = 0.18;

  static const Color _ivory    = Color(0xFFFFFDF5);
  static const Color _holy     = Color(0xFFFFF8DC);
  static const Color _amber    = Color(0xFFF59E0B);
  static const Color _warmGold = Color(0xFFFFD700);
  static const Color _brown    = Color(0xFF78350F);

  @override
  void initState() {
    super.initState();
    final duration = Duration(seconds: widget.scene.durationSeconds.clamp(5, 90));
    _controller = AnimationController(vsync: this, duration: duration);

    final motionStr = widget.scene.effect.isEmpty ? 'zoom_in' : widget.scene.effect;
    final motion = SceneMotionPreset.fromString(motionStr);
    _zoom = SceneMotionPreset.buildZoom(_controller, motion);
    _pan  = SceneMotionPreset.buildPan(_controller, motion);

    final contentCurve = CurvedAnimation(
      parent: _controller,
      curve: Interval(_hookEnd, _hookEnd + 0.5, curve: Curves.easeOut),
    );
    _contentFade  = Tween<double>(begin: 0.0, end: 1.0).animate(contentCurve);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(contentCurve);

    _lightBeam = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _lightPulse = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DevotionalSceneFive old) {
    super.didUpdateWidget(old);
    if (old.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _controller.isCompleted || _controller.isDismissed
            ? _controller.forward(from: 0)
            : _controller.forward();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene      = widget.scene;
    final hasHook    = scene.hook.isNotEmpty;
    final wordTag    = scene.subtitle.isNotEmpty ? scene.subtitle.toUpperCase() : 'THE WORD OF GOD';
    final safeBottom = SceneLayout.safeBottom(context);
    final safeTop    = SceneLayout.safeTop(context);
    final size       = MediaQuery.sizeOf(context);
    final screenWidth = size.width;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final hookExit = hasHook
            ? ((_controller.value - _hookEnd) / 0.08).clamp(0.0, 1.0)
            : 1.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. Background ─────────────────────────────────────────────
            SceneBackground(
              localImageBytes: scene.localImageBytes,
              imageUrl: scene.imageUrl,
              zoom: _zoom,
              pan: _pan,
            ),

            // ── 2. Holy white-bright overlay ──────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xDDFFFDF5),
                    Color(0x55FFF8DC),
                    Color(0xEE78350F),
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // ── 2.5 Cloud Layer & Floating Dust ──────────────────────────
            const SmokeEffect(color: Color(0x15FFFFFF)),
            const LightRayEffect(color: Color(0x1AFFF8DC)),
            const DustEffect(color: Color(0xFFFFF8DC), count: 50, speedMultiplier: 0.7),

            // ── 3. Divine light column ────────────────────────────────────
            AnimatedBuilder(
              animation: _lightBeam,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _HolyLightPainter(
                  intensity: _lightBeam.value,
                  pulse: _lightPulse.value,
                  color: _holy,
                ),
              ),
            ),



            // ── 6. Hook frame ─────────────────────────────────────────────
            if (hasHook && hookExit < 1.0)
              SceneHookFrame(hookText: scene.hook, exitOpacity: hookExit),
          ],
        );
      },
    );
  }
}

class _HolyLightPainter extends CustomPainter {
  final double intensity;
  final double pulse;
  final Color color;

  _HolyLightPainter({
    required this.intensity,
    required this.pulse,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, 0),
      width: size.width * 0.6 * pulse,
      height: size.height * 1.4,
    );

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.6 * intensity),
          color.withValues(alpha: 0.2 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Primary beam
    final path = Path()
      ..moveTo(size.width / 2 - 40, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2 + 40, 0)
      ..close();
    canvas.drawPath(path, paint);

    // Wide soft halo
    final haloPaint = Paint()
      ..color = color.withValues(alpha: 0.12 * intensity * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.3),
          width: size.width * 0.8, height: size.height * 0.6),
      haloPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HolyLightPainter old) =>
      old.intensity != intensity || old.pulse != pulse;
}
