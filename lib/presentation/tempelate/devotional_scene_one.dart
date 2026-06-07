import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/presentation/tempelate/scene_design_system.dart';

/// -----------------------------------------------------------------------
/// DEVOTIONAL TEMPLATE 1 – SACRED VERSE
/// Deep indigo/violet atmosphere with golden mandala ring, holy glow,
/// and centred scripture verse + word-by-word reveal.
///
/// Scene mapping:
///   scene.hook        → 0-3 s full-screen opening verse hook
///   scene.subtitle    → scripture reference (e.g. "John 3:16")
///   scene.title       → verse / affirmation headline
///   scene.body        → devotional narration
///   scene.keyPoints   → spiritual reflections (max 3)
///   scene.closureLine → closing blessing / amen line
///   scene.effect      → motion preset
/// -----------------------------------------------------------------------

class DevotionalSceneOne extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const DevotionalSceneOne({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<DevotionalSceneOne> createState() => _DevotionalSceneOneState();
}

class _DevotionalSceneOneState extends State<DevotionalSceneOne>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<Offset> _pan;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _glowPulse;
  late Animation<double> _ringRotate;

  static const double _hookEnd = 0.18;

  // Sacred palette
  static const Color _deepIndigo = Color(0xFF1A1035);
  static const Color _violet     = Color(0xFF6D28D9);
  static const Color _gold       = Color(0xFFFFD700);
  static const Color _goldLight  = Color(0xFFFFF0A0);
  static const Color _roseGlow   = Color(0xFFFDA4AF);

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

    _glowPulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _ringRotate = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DevotionalSceneOne old) {
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
    final scene     = widget.scene;
    final hasHook   = scene.hook.isNotEmpty;
    final scripture = scene.subtitle.isNotEmpty ? scene.subtitle : 'HOLY SCRIPTURE';
    final safeBottom = SceneLayout.safeBottom(context);
    final safeTop    = SceneLayout.safeTop(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final hookExit = hasHook
            ? ((_controller.value - _hookEnd) / 0.08).clamp(0.0, 1.0)
            : 1.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. Background image with motion ──────────────────────────
            SceneBackground(
              localImageBytes: scene.localImageBytes,
              imageUrl: scene.imageUrl,
              zoom: _zoom,
              pan: _pan,
            ),

            // ── 2. Deep indigo gradient overlay (sacred darkness) ────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC1A1035),
                    Color(0x881A1035),
                    Color(0xEE1A1035),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),

            // ── 3. Radial holy glow at centre ────────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _glowPulse,
                builder: (_, __) => Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _violet.withValues(alpha: 0.35 * _glowPulse.value),
                        _gold.withValues(alpha: 0.12 * _glowPulse.value),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // ── 4. Rotating golden mandala ring ──────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _ringRotate,
                builder: (_, __) => Transform.rotate(
                  angle: _ringRotate.value,
                  child: CustomPaint(
                    size: const Size(220, 220),
                    painter: _MandalaRingPainter(color: _gold.withValues(alpha: 0.28)),
                  ),
                ),
              ),
            ),

            // ── 5. Scripture reference badge (top) ───────────────────────
            FadeTransition(
              opacity: _contentFade,
              child: Positioned(
                top: safeTop,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(colors: [
                        _gold.withValues(alpha: 0.85),
                        _violet.withValues(alpha: 0.85),
                      ]),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withValues(alpha: 0.4),
                          blurRadius: 14,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_stories_rounded, size: 13, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          scripture.toUpperCase(),
                          style: SceneTypography.subtitle.copyWith(
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── 6. Center content panel (glass) ──────────────────────────
            FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(22, 0, 22, safeBottom + 16),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: SceneLayout.maxContentWidth),
                      child: SceneGlassPanel(
                        backgroundOpacity: 0.82,
                        blurSigma: 22,
                        borderColor: _gold.withValues(alpha: 0.5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Gold accent line centred
                            Center(child: SceneGoldAccent(width: 56, height: 2.5)),
                            const SizedBox(height: 12),

                            // Title — word-by-word reveal
                            WordRevealText(
                              text: scene.title,
                              style: SceneTypography.mainTitle.copyWith(
                                color: _goldLight,
                                fontStyle: FontStyle.italic,
                                fontSize: 28,
                              ),
                              textAlign: TextAlign.center,
                              controller: _controller,
                              startFraction: _hookEnd,
                              durationFraction: 0.35,
                            ),

                            if (scene.body.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                scene.body,
                                textAlign: TextAlign.center,
                                style: SceneTypography.body.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  height: 1.6,
                                ),
                              ),
                            ],

                            if (scene.keyPoints.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              // Show key points with ✦ bullet
                              ...scene.keyPoints.take(3).map((kp) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('✦ ', style: TextStyle(color: _gold, fontSize: 12)),
                                    Expanded(
                                      child: Text(kp,
                                          style: SceneTypography.keyPoint.copyWith(
                                            color: Colors.white.withValues(alpha: 0.88),
                                          )),
                                    ),
                                  ],
                                ),
                              )),
                            ],

                            if (scene.closureLine.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Divider(height: 1, color: _gold.withValues(alpha: 0.3)),
                              const SizedBox(height: 8),
                              Text(
                                scene.closureLine,
                                textAlign: TextAlign.center,
                                style: SceneTypography.closureLine.copyWith(
                                  color: _gold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],

                            const SizedBox(height: 4),
                            Center(child: SceneGoldAccent(width: 56, height: 2.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── 7. Hook frame ────────────────────────────────────────────
            if (hasHook && hookExit < 1.0)
              SceneHookFrame(hookText: scene.hook, exitOpacity: hookExit),
          ],
        );
      },
    );
  }
}

/// Simple mandala-style dashed ring painter
class _MandalaRingPainter extends CustomPainter {
  final Color color;
  _MandalaRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer ring
    canvas.drawCircle(center, radius, paint);
    // Inner ring
    canvas.drawCircle(center, radius * 0.78, paint..color = color.withValues(alpha: 0.5));

    // 12 radial petals
    final petalPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 2 * math.pi) / 12;
      final inner = Offset(
        center.dx + (radius * 0.78) * math.cos(angle),
        center.dy + (radius * 0.78) * math.sin(angle),
      );
      final outer = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(inner, outer, petalPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MandalaRingPainter old) => old.color != color;
}
