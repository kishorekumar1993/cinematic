import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/presentation/tempelate/scene_design_system.dart';

/// -----------------------------------------------------------------------
/// DEVOTIONAL TEMPLATE 4 – CELESTIAL PRAYER
/// Midnight blue / starfield with animated star particles, a glowing
/// cross/star of David/crescent emblem, and prayer text.
///
/// Scene mapping:
///   scene.hook        → opening prayer call
///   scene.subtitle    → faith tag (e.g. "EVENING PRAYER")
///   scene.title       → prayer headline
///   scene.body        → prayer body text
///   scene.keyPoints   → prayer intercessions (max 3)
///   scene.closureLine → "Amen" / "Ameen" / "Amen, Amen"
///   scene.effect      → motion preset
/// -----------------------------------------------------------------------

class DevotionalSceneFour extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const DevotionalSceneFour({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<DevotionalSceneFour> createState() => _DevotionalSceneFourState();
}

class _DevotionalSceneFourState extends State<DevotionalSceneFour>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<Offset> _pan;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _starTwinkle;
  late Animation<double> _emblemGlow;

  static const double _hookEnd = 0.18;

  static const Color _midnight  = Color(0xFF0B0F2E);
  static const Color _navy      = Color(0xFF1E2A6B);
  static const Color _celestial = Color(0xFF6366F1);
  static const Color _starWhite = Color(0xFFF0F4FF);
  static const Color _gold      = Color(0xFFFFD700);
  static const Color _prayerBlue = Color(0xFF93C5FD);

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

    _starTwinkle = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _emblemGlow = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DevotionalSceneFour old) {
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
    final prayerTag  = scene.subtitle.isNotEmpty ? scene.subtitle.toUpperCase() : 'EVENING PRAYER';
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

            // ── 2. Midnight starfield overlay ─────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xEE0B0F2E),
                    Color(0x771E2A6B),
                    Color(0xF00B0F2E),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // ── 3. Animated star particles ────────────────────────────────
            AnimatedBuilder(
              animation: _starTwinkle,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _StarfieldPainter(
                  phase: _starTwinkle.value,
                  starColor: _starWhite,
                ),
              ),
            ),

            // ── 4. Celestial emblem glow in upper centre ──────────────────
            Positioned(
              top: size.height * 0.18,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _emblemGlow,
                  builder: (_, __) => Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _gold.withValues(alpha: 0.9 * _emblemGlow.value),
                          _celestial.withValues(alpha: 0.5 * _emblemGlow.value),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withValues(alpha: 0.6 * _emblemGlow.value),
                          blurRadius: 35,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '✦',
                        style: TextStyle(
                          fontSize: 40,
                          color: _gold.withValues(alpha: _emblemGlow.value),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── 5. Top prayer badge ───────────────────────────────────────
            FadeTransition(
              opacity: _contentFade,
              child: Positioned(
                top: safeTop,
                left: 22,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: _navy.withValues(alpha: 0.90),
                    border: Border.all(color: _prayerBlue.withValues(alpha: 0.6), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: _celestial.withValues(alpha: 0.35),
                        blurRadius: 12,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.nights_stay_rounded, size: 13, color: _prayerBlue),
                      const SizedBox(width: 6),
                      Text(prayerTag,
                          style: SceneTypography.subtitle.copyWith(
                            color: _prayerBlue,
                            fontSize: 10,
                          )),
                    ],
                  ),
                ),
              ),
            ),

            // ── 6. Bottom prayer panel ────────────────────────────────────
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
                        backgroundOpacity: 0.82,
                        blurSigma: 22,
                        borderColor: _celestial.withValues(alpha: 0.45),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Celestial blue accent bar
                            Container(
                              width: 50,
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: LinearGradient(colors: [
                                  _prayerBlue,
                                  _celestial,
                                ]),
                              ),
                            ),
                            const SizedBox(height: 10),

                            WordRevealText(
                              text: scene.title,
                              style: SceneTypography.mainTitle.copyWith(
                                color: _starWhite,
                                fontSize: 28,
                              ),
                              controller: _controller,
                              startFraction: _hookEnd,
                              durationFraction: 0.38,
                            ),

                            if (scene.body.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(scene.body,
                                  style: SceneTypography.body.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontStyle: FontStyle.italic,
                                    height: 1.7,
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
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Container(
                                        width: 5, height: 5,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _prayerBlue,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(kp,
                                        style: SceneTypography.keyPoint.copyWith(
                                          color: Colors.white.withValues(alpha: 0.88),
                                        ))),
                                  ],
                                ),
                              )),
                            ],

                            if (scene.closureLine.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Divider(height: 1, color: _celestial.withValues(alpha: 0.3)),
                              const SizedBox(height: 8),
                              Text(
                                scene.closureLine,
                                style: SceneTypography.closureLine.copyWith(
                                  color: _gold,
                                  fontSize: 15,
                                  letterSpacing: 1.2,
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

class _StarfieldPainter extends CustomPainter {
  final double phase;
  final Color starColor;

  _StarfieldPainter({required this.phase, required this.starColor});

  static final List<_Star> _stars = List.generate(60, (i) {
    final rng = math.Random(i * 17 + 3);
    return _Star(
      x: rng.nextDouble(),
      y: rng.nextDouble() * 0.7,
      size: 0.8 + rng.nextDouble() * 2.0,
      phase: rng.nextDouble() * math.pi * 2,
      speed: 0.5 + rng.nextDouble() * 1.5,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _stars) {
      final twinkle = (math.sin(phase * s.speed + s.phase) + 1) / 2;
      final paint = Paint()
        ..color = starColor.withValues(alpha: 0.3 + twinkle * 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size * (0.6 + twinkle * 0.4),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter old) => old.phase != phase;
}

class _Star {
  final double x, y, size, phase, speed;
  _Star({required this.x, required this.y, required this.size,
    required this.phase, required this.speed});
}
