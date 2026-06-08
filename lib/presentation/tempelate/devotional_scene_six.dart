import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/presentation/tempelate/scene_design_system.dart';
import 'package:cinematic/presentation/effects/smoke_painter.dart';

/// -----------------------------------------------------------------------
/// DEVOTIONAL TEMPLATE 6 – SACRED FLAMES (Agni / Holy Fire)
/// Deep charcoal with animated fire/ember particles, fiery gradient,
/// and an inspiring power-verse layout.
///
/// Scene mapping:
///   scene.hook        → fire proclamation hook
///   scene.subtitle    → fire theme label (e.g. "HOLY FIRE")
///   scene.title       → power verse / battle-cry headline
///   scene.body        → devotional message
///   scene.keyPoints   → declarations (max 3)
///   scene.closureLine → victory shout / declaration
///   scene.effect      → motion preset
/// -----------------------------------------------------------------------

class DevotionalSceneSix extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const DevotionalSceneSix({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<DevotionalSceneSix> createState() => _DevotionalSceneSixState();
}

class _DevotionalSceneSixState extends State<DevotionalSceneSix>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<Offset> _pan;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _emberProgress;

  static const double _hookEnd = 0.18;

  static const Color _charcoal  = Color(0xFF1A0A00);
  static const Color _fireOrange = Color(0xFFEA580C);
  static const Color _fireYellow = Color(0xFFFBBF24);
  static const Color _ember     = Color(0xFFFF4500);
  static const Color _crimson   = Color(0xFF991B1B);

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

    _emberProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DevotionalSceneSix old) {
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
    final fireTag    = scene.subtitle.isNotEmpty ? scene.subtitle.toUpperCase() : 'HOLY FIRE';
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

            // ── 2. Fire gradient overlay ──────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xEE1A0A00),
                    Color(0xAAEA580C),
                    Color(0x331A0A00),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // ── 2.5 Smoke Atmosphere ──────────────────────────────────────
            const SmokeEffect(color: Color(0x25EA580C)),

            // ── 3. Ember particle system ──────────────────────────────────
            AnimatedBuilder(
              animation: _emberProgress,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _EmberPainter(
                  progress: _emberProgress.value,
                  emberColor: _fireYellow,
                  glowColor: _fireOrange,
                ),
              ),
            ),

            // ── 4. Fire glow at the bottom ────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: size.height * 0.3,
              child: AnimatedBuilder(
                animation: _emberProgress,
                builder: (_, __) {
                  final flicker = (math.sin(_emberProgress.value * math.pi * 12) + 1) / 2;
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          _ember.withValues(alpha: 0.55 + flicker * 0.2),
                          _fireOrange.withValues(alpha: 0.3 + flicker * 0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  );
                },
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

class _EmberPainter extends CustomPainter {
  final double progress;
  final Color emberColor;
  final Color glowColor;

  _EmberPainter({
    required this.progress,
    required this.emberColor,
    required this.glowColor,
  });

  static final List<_Ember> _embers = List.generate(30, (i) {
    final rng = math.Random(i * 41 + 7);
    return _Ember(
      startX: rng.nextDouble(),
      speed:  0.25 + rng.nextDouble() * 0.5,
      size:   2.0 + rng.nextDouble() * 3.5,
      drift:  (rng.nextDouble() - 0.5) * 0.08,
      phase:  rng.nextDouble(),
      opacity: 0.55 + rng.nextDouble() * 0.45,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in _embers) {
      final t = ((progress - e.phase) * e.speed) % 1.0;
      if (t < 0) continue;
      final y = size.height * (1.0 - t * 1.2);
      if (y < -10) continue;
      final x = size.width * (e.startX + e.drift * t);

      final paint = Paint()
        ..color = emberColor.withValues(alpha: e.opacity * (1.0 - t * 0.6))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(Offset(x, y), e.size * (1.0 - t * 0.3), paint);

      // Glow
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: e.opacity * 0.3 * (1.0 - t * 0.8))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(x, y), e.size * 2.5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmberPainter old) => old.progress != progress;
}

class _Ember {
  final double startX, speed, size, drift, phase, opacity;
  _Ember({
    required this.startX, required this.speed, required this.size,
    required this.drift, required this.phase, required this.opacity,
  });
}
