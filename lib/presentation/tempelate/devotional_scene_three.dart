import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/presentation/tempelate/scene_design_system.dart';

/// -----------------------------------------------------------------------
/// DEVOTIONAL TEMPLATE 3 – LOTUS SERENITY (Spiritual / Hindu / Buddhist)
/// Deep teal/emerald with animated floating lotus petals and a serene
/// centred meditation verse.
///
/// Scene mapping:
///   scene.hook        → 0-3 s mantral opening
///   scene.subtitle    → tradition tag (e.g. "OM SHANTI")
///   scene.title       → main shloka / mantra headline
///   scene.body        → explanation / commentary
///   scene.keyPoints   → spiritual teachings (max 3)
///   scene.closureLine → closing mantra / namaste
///   scene.effect      → motion preset
/// -----------------------------------------------------------------------

class DevotionalSceneThree extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const DevotionalSceneThree({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<DevotionalSceneThree> createState() => _DevotionalSceneThreeState();
}

class _DevotionalSceneThreeState extends State<DevotionalSceneThree>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<Offset> _pan;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _petalFloat;

  static const double _hookEnd = 0.18;

  static const Color _teal     = Color(0xFF0D4F4F);
  static const Color _emerald  = Color(0xFF10B981);
  static const Color _lotus    = Color(0xFFF9A8D4);
  static const Color _gold     = Color(0xFFFFD700);
  static const Color _cream    = Color(0xFFFFFBEB);

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

    _petalFloat = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DevotionalSceneThree old) {
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
    final tagText    = scene.subtitle.isNotEmpty ? scene.subtitle.toUpperCase() : 'OM SHANTI';
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

            // ── 2. Teal/emerald tranquil overlay ─────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xDD0D4F4F),
                    Color(0x660D4F4F),
                    Color(0xEE051C1C),
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // ── 3. Floating lotus petals (particle system) ───────────────
            AnimatedBuilder(
              animation: _petalFloat,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _LotusPetalPainter(
                  progress: _petalFloat.value,
                  petalColor: _lotus,
                ),
              ),
            ),

            // ── 4. Lotus centre glow ──────────────────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _petalFloat,
                builder: (_, __) => Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _lotus.withValues(alpha: 0.22 * _petalFloat.value),
                        _emerald.withValues(alpha: 0.14 * _petalFloat.value),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // ── 5. Top om/mantra badge ────────────────────────────────────
            FadeTransition(
              opacity: _contentFade,
              child: Positioned(
                top: safeTop,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(colors: [
                        _teal.withValues(alpha: 0.92),
                        _emerald.withValues(alpha: 0.78),
                      ]),
                      border: Border.all(color: _lotus.withValues(alpha: 0.6), width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: _emerald.withValues(alpha: 0.35),
                          blurRadius: 12,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🪷', style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(tagText,
                            style: SceneTypography.subtitle.copyWith(
                              color: _cream,
                              letterSpacing: 2.2,
                              fontSize: 10,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── 6. Central lotus meditation frame ─────────────────────────
            FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(22, 0, 22, safeBottom + 8),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: SceneLayout.maxContentWidth),
                      child: SceneGlassPanel(
                        backgroundOpacity: 0.80,
                        blurSigma: 24,
                        borderColor: _lotus.withValues(alpha: 0.45),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Lotus petal accent
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🪷', style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 8),
                                Container(
                                  width: 40, height: 2,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    gradient: LinearGradient(colors: [
                                      _lotus.withValues(alpha: 0.8),
                                      _emerald.withValues(alpha: 0.6),
                                    ]),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('🪷', style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Shloka title — centred word reveal
                            WordRevealText(
                              text: scene.title,
                              style: SceneTypography.mainTitle.copyWith(
                                color: _cream,
                                fontStyle: FontStyle.italic,
                                fontSize: 26,
                              ),
                              textAlign: TextAlign.center,
                              controller: _controller,
                              startFraction: _hookEnd,
                              durationFraction: 0.38,
                            ),

                            if (scene.body.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                scene.body,
                                textAlign: TextAlign.center,
                                style: SceneTypography.body.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  height: 1.65,
                                ),
                              ),
                            ],

                            if (scene.keyPoints.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              ...scene.keyPoints.take(3).map((kp) => Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('❋ ',
                                        style: TextStyle(color: _lotus, fontSize: 13)),
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
                              Divider(height: 1, color: _lotus.withValues(alpha: 0.25)),
                              const SizedBox(height: 8),
                              Text(
                                scene.closureLine,
                                textAlign: TextAlign.center,
                                style: SceneTypography.closureLine.copyWith(
                                  color: _lotus,
                                  fontSize: 15,
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

class _LotusPetalPainter extends CustomPainter {
  final double progress;
  final Color petalColor;

  _LotusPetalPainter({required this.progress, required this.petalColor});

  static final List<_Petal> _petals = List.generate(14, (i) {
    final rng = math.Random(i * 31);
    return _Petal(
      startX: rng.nextDouble(),
      startY: 1.0 + rng.nextDouble() * 0.3,
      speed: 0.3 + rng.nextDouble() * 0.4,
      size: 6 + rng.nextDouble() * 10,
      swayAmp: 0.04 + rng.nextDouble() * 0.06,
      swayFreq: 1.0 + rng.nextDouble() * 2.0,
      opacity: 0.35 + rng.nextDouble() * 0.45,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _petals) {
      final t = (progress * p.speed) % 1.0;
      final y = size.height * (p.startY - t * 1.5);
      if (y < -p.size) continue;
      final x = size.width * (p.startX + math.sin(t * math.pi * 2 * p.swayFreq) * p.swayAmp);

      final paint = Paint()
        ..color = petalColor.withValues(alpha: p.opacity * (1.0 - t * 0.5))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * math.pi * 2);
      final path = Path()
        ..moveTo(0, -p.size)
        ..quadraticBezierTo(p.size * 0.6, -p.size * 0.2, 0, p.size * 0.5)
        ..quadraticBezierTo(-p.size * 0.6, -p.size * 0.2, 0, -p.size);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LotusPetalPainter old) => old.progress != progress;
}

class _Petal {
  final double startX, startY, speed, size, swayAmp, swayFreq, opacity;
  _Petal({
    required this.startX, required this.startY, required this.speed,
    required this.size, required this.swayAmp, required this.swayFreq,
    required this.opacity,
  });
}
