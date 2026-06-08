import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/presentation/tempelate/scene_design_system.dart';
import 'package:cinematic/presentation/effects/dust_painter.dart';
import 'package:cinematic/presentation/effects/light_ray_painter.dart';
import 'package:cinematic/presentation/effects/smoke_painter.dart';

/// -----------------------------------------------------------------------
/// DEVOTIONAL TEMPLATE 7 – PEACEFUL GARDEN (Nature / Meditation)
/// Soft sage green and lavender forest-light atmosphere with animated
/// floating particles (pollen/light dust) and serene verse layout.
///
/// Scene mapping:
///   scene.hook        → serene opening
///   scene.subtitle    → nature tag (e.g. "PEACEFUL REFLECTION")
///   scene.title       → meditation verse / affirmation
///   scene.body        → reflection
///   scene.keyPoints   → gifts of peace / teachings (max 3)
///   scene.closureLine → final peaceful line
///   scene.effect      → motion preset
/// -----------------------------------------------------------------------

class DevotionalSceneSeven extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const DevotionalSceneSeven({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<DevotionalSceneSeven> createState() => _DevotionalSceneSevenState();
}

class _DevotionalSceneSevenState extends State<DevotionalSceneSeven>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<Offset> _pan;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _pollenProgress;
  late Animation<double> _leafSway;

  static const double _hookEnd = 0.18;

  static const Color _sage      = Color(0xFF1A3325);
  static const Color _forest    = Color(0xFF14532D);
  static const Color _mint      = Color(0xFF6EE7B7);
  static const Color _lavender  = Color(0xFFC4B5FD);
  static const Color _cream     = Color(0xFFFFFBEB);
  static const Color _softGold  = Color(0xFFFDE68A);

  @override
  void initState() {
    super.initState();
    final duration = Duration(seconds: widget.scene.durationSeconds.clamp(5, 90));
    _controller = AnimationController(vsync: this, duration: duration);

    final motionStr = widget.scene.effect.isEmpty ? 'ken_burns' : widget.scene.effect;
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

    _pollenProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _leafSway = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DevotionalSceneSeven old) {
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
    final peaceTag   = scene.subtitle.isNotEmpty ? scene.subtitle.toUpperCase() : 'PEACEFUL REFLECTION';
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

            // ── 2. Forest/garden gradient overlay ─────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC0D1F15),
                    Color(0x661A3325),
                    Color(0xEE0D1F15),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),

            // ── 3. Forest-light dapple (radial warm patch) ────────────────
            Positioned(
              top: size.height * 0.12,
              left: size.width * 0.15,
              child: AnimatedBuilder(
                animation: _leafSway,
                builder: (_, __) => Transform.translate(
                  offset: Offset(_leafSway.value * 40, 0),
                  child: Container(
                    width: size.width * 0.6,
                    height: size.height * 0.35,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          _softGold.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── 3.5 Forest Atmosphere ─────────────────────────────────────
            const SmokeEffect(color: Color(0x156EE7B7)),
            const LightRayEffect(color: Color(0x11FDE68A)),
            const DustEffect(color: Color(0xFFFDE68A), count: 25, speedMultiplier: 0.4),

            // ── 4. Floating pollen/light dust ─────────────────────────────
            AnimatedBuilder(
              animation: _pollenProgress,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _PollenPainter(
                  progress: _pollenProgress.value,
                  dotColor: _softGold,
                  glowColor: _mint,
                ),
              ),
            ),



            // ── 7. Hook frame ─────────────────────────────────────────────
            if (hasHook && hookExit < 1.0)
              SceneHookFrame(hookText: scene.hook, exitOpacity: hookExit),
          ],
        );
      },
    );
  }
}

class _PollenPainter extends CustomPainter {
  final double progress;
  final Color dotColor;
  final Color glowColor;

  _PollenPainter({required this.progress, required this.dotColor, required this.glowColor});

  static final List<_PollenDot> _dots = List.generate(25, (i) {
    final rng = math.Random(i * 53 + 11);
    return _PollenDot(
      startX: rng.nextDouble(),
      speed: 0.15 + rng.nextDouble() * 0.25,
      size: 1.5 + rng.nextDouble() * 3.0,
      swayAmp: 0.03 + rng.nextDouble() * 0.05,
      swayFreq: 0.5 + rng.nextDouble() * 1.5,
      phase: rng.nextDouble(),
      opacity: 0.4 + rng.nextDouble() * 0.5,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final d in _dots) {
      final t = ((progress - d.phase) * d.speed) % 1.0;
      if (t < 0) continue;
      // Float upward
      final y = size.height * (0.85 - t * 0.9);
      if (y < 0) continue;
      final x = size.width * (d.startX + math.sin(t * math.pi * 2 * d.swayFreq) * d.swayAmp);

      final alpha = d.opacity * (1.0 - math.max(0, (t - 0.7) / 0.3));

      final paint = Paint()
        ..color = dotColor.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), d.size, paint);

      // Soft glow
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: alpha * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(x, y), d.size * 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PollenPainter old) => old.progress != progress;
}

class _PollenDot {
  final double startX, speed, size, swayAmp, swayFreq, phase, opacity;
  _PollenDot({
    required this.startX, required this.speed, required this.size,
    required this.swayAmp, required this.swayFreq, required this.phase,
    required this.opacity,
  });
}
