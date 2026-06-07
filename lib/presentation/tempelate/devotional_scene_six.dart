import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/presentation/tempelate/scene_design_system.dart';

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

            // ── 5. Top fire badge ─────────────────────────────────────────
            FadeTransition(
              opacity: _contentFade,
              child: Positioned(
                top: safeTop,
                left: 22,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(colors: [
                      _crimson.withValues(alpha: 0.92),
                      _ember.withValues(alpha: 0.78),
                    ]),
                    border: Border.all(color: _fireYellow.withValues(alpha: 0.6), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: _ember.withValues(alpha: 0.5),
                        blurRadius: 14,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(fireTag,
                          style: SceneTypography.subtitle.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          )),
                    ],
                  ),
                ),
              ),
            ),

            // ── 6. Fire-styled content panel ─────────────────────────────
            FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(22, 0, 22, safeBottom + 8),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: SceneLayout.maxContentWidth),
                      child: SceneGlassPanel(
                        backgroundOpacity: 0.85,
                        blurSigma: 20,
                        borderColor: _fireOrange.withValues(alpha: 0.55),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fire gradient accent bar
                            Container(
                              width: 54,
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: const LinearGradient(colors: [
                                  Color(0xFFFBBF24),
                                  Color(0xFFEA580C),
                                  Color(0xFF991B1B),
                                ]),
                              ),
                            ),
                            const SizedBox(height: 10),

                            WordRevealText(
                              text: scene.title,
                              style: SceneTypography.mainTitle.copyWith(
                                color: const Color(0xFFFFF0A0),
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                              controller: _controller,
                              startFraction: _hookEnd,
                              durationFraction: 0.38,
                            ),

                            if (scene.body.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(scene.body,
                                  style: SceneTypography.body.copyWith(
                                    color: Colors.white.withValues(alpha: 0.88),
                                  )),
                            ],

                            if (scene.keyPoints.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              ...scene.keyPoints.take(3).map((kp) => Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: const Text('🔥',
                                          style: TextStyle(fontSize: 11)),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(kp,
                                        style: SceneTypography.keyPoint.copyWith(
                                          color: Colors.white.withValues(alpha: 0.90),
                                        ))),
                                  ],
                                ),
                              )),
                            ],

                            if (scene.closureLine.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Divider(height: 1, color: _fireOrange.withValues(alpha: 0.35)),
                              const SizedBox(height: 8),
                              Text(
                                scene.closureLine,
                                style: SceneTypography.closureLine.copyWith(
                                  color: _fireYellow,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
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
