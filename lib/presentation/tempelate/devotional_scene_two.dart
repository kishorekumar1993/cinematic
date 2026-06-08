import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/presentation/tempelate/scene_design_system.dart';
import 'package:cinematic/presentation/effects/dust_painter.dart';
import 'package:cinematic/presentation/effects/smoke_painter.dart';

/// -----------------------------------------------------------------------
/// DEVOTIONAL TEMPLATE 2 – SUNRISE PRAISE
/// Warm sunrise gradient (amber → rose → deep crimson) with animated
/// light-rays and a bottom devotional panel.
///
/// Scene mapping:
///   scene.hook        → 0-3 s sunrise hook
///   scene.subtitle    → praise tag (e.g. "MORNING DEVOTION")
///   scene.title       → praise/worship headline
///   scene.body        → devotional message
///   scene.keyPoints   → praise affirmations (max 3)
///   scene.closureLine → benediction line
///   scene.effect      → motion preset
/// -----------------------------------------------------------------------

class DevotionalSceneTwo extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const DevotionalSceneTwo({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<DevotionalSceneTwo> createState() => _DevotionalSceneTwoState();
}

class _DevotionalSceneTwoState extends State<DevotionalSceneTwo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<Offset> _pan;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _rayOpacity;
  late Animation<double> _sunRise;

  static const double _hookEnd = 0.18;

  static const Color _sunrise   = Color(0xFFFF6B2C);
  static const Color _amber     = Color(0xFFFBBF24);
  static const Color _roseWarm  = Color(0xFFFDA4AF);
  static const Color _crimson   = Color(0xFF7F1D1D);
  static const Color _goldHalo  = Color(0xFFFFE566);

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

    _rayOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _sunRise = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.35, curve: Curves.easeOut)),
    );

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DevotionalSceneTwo old) {
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
    final praiseTag  = scene.subtitle.isNotEmpty ? scene.subtitle.toUpperCase() : 'MORNING DEVOTION';
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

            // ── 2. Sunrise warm gradient overlay ─────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xBB7F1D1D),
                    Color(0x55FF6B2C),
                    Color(0xDDFBBF24),
                    Color(0xFF7F1D1D),
                  ],
                  stops: [0.0, 0.3, 0.65, 1.0],
                ),
              ),
            ),

            // ── 2.5 Atmosphere (Clouds/Mist & Flying Dust) ───────────────
            const SmokeEffect(color: Color(0x15FFFFFF)),
            const DustEffect(color: Color(0xFFFFD700), count: 50, speedMultiplier: 1.5),

            // ── 3. Animated light rays from bottom ───────────────────────
            AnimatedBuilder(
              animation: _rayOpacity,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _SunrayPainter(
                  opacity: _rayOpacity.value * 0.38,
                  originY: size.height * (0.55 + _sunRise.value * 0.2),
                  color: _goldHalo,
                ),
              ),
            ),

            // ── 4. Halo circle behind sun ────────────────────────────────
            Positioned(
              bottom: size.height * (0.25 + _sunRise.value * 0.2),
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _rayOpacity,
                  builder: (_, __) => Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _goldHalo.withValues(alpha: 0.9 * _rayOpacity.value),
                          _amber.withValues(alpha: 0.6 * _rayOpacity.value),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _goldHalo.withValues(alpha: 0.55 * _rayOpacity.value),
                          blurRadius: 40,
                          spreadRadius: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── 5. Top praise badge ───────────────────────────────────────
            Positioned(
              top: safeTop,
              left: 22,
              child: FadeTransition(
                opacity: _contentFade,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: _crimson.withValues(alpha: 0.85),
                    border: Border.all(color: _amber.withValues(alpha: 0.7), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: _amber.withValues(alpha: 0.4),
                        blurRadius: 12,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wb_sunny_rounded, size: 13, color: Color(0xFFFFE566)),
                      const SizedBox(width: 6),
                      Text(
                        praiseTag,
                        style: SceneTypography.subtitle.copyWith(
                          color: _goldHalo,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── 6. Bottom devotional panel ────────────────────────────────
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
                        backgroundOpacity: 0.80,
                        blurSigma: 20,
                        borderColor: _amber.withValues(alpha: 0.55),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sunrise gradient accent bar
                            Container(
                              width: 54,
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: const LinearGradient(colors: [
                                  Color(0xFFFFE566),
                                  Color(0xFFFF6B2C),
                                ]),
                              ),
                            ),
                            const SizedBox(height: 10),

                            WordRevealText(
                              text: scene.title,
                              style: SceneTypography.mainTitle.copyWith(
                                color: _goldHalo,
                                fontSize: screenWidth * 0.05,
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
                                    fontSize: screenWidth * 0.035,
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
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Icon(Icons.flare_rounded,
                                          size: 11, color: _amber),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                        child: Text(kp,
                                            style: SceneTypography.keyPoint.copyWith(
                                              color: Colors.white.withValues(alpha: 0.88),
                                              fontSize: screenWidth * 0.035,
                                            ))),
                                  ],
                                ),
                              )),
                            ],

                            if (scene.closureLine.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Divider(height: 1, color: _amber.withValues(alpha: 0.3)),
                              const SizedBox(height: 8),
                              Text(scene.closureLine,
                                  style: SceneTypography.closureLine.copyWith(
                                    color: _goldHalo,
                                    fontSize: screenWidth * 0.038,
                                  )),
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

/// Animated sun-ray painter radiating from a point
class _SunrayPainter extends CustomPainter {
  final double opacity;
  final double originY;
  final Color color;

  _SunrayPainter({
    required this.opacity,
    required this.originY,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final origin = Offset(size.width / 2, originY);
    const rayCount = 18;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi) / rayCount - math.pi / 2;
      final end = Offset(
        origin.dx + 600 * math.cos(angle),
        origin.dy + 600 * math.sin(angle),
      );
      paint.color = color.withValues(alpha: opacity * (i.isEven ? 1.0 : 0.5));
      canvas.drawLine(origin, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunrayPainter old) =>
      old.opacity != opacity || old.originY != originY;
}
