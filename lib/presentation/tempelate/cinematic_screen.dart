import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/presentation/tempelate/scene_design_system.dart';

/// -----------------------------------------------------------------------
/// CLASSIC CARD OVERLAY — Upgraded with design system
/// -----------------------------------------------------------------------
/// Uses:
///   scene.hook        → 0-3s full-screen hook frame (if non-empty)
///   scene.subtitle    → category badge above title
///   scene.title       → main headline (word-by-word animation)
///   scene.body        → narration paragraph
///   scene.keyPoints   → max 3 bullet facts
///   scene.closureLine → gold punch line
///   scene.effect      → motion preset (zoom_in, ken_burns, pan_left, etc.)
///   scene.textEffect  → 'word_by_word' for title animation
/// -----------------------------------------------------------------------

class CinematicScreen extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicScreen({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicScreen> createState() => _CinematicScreenState();
}

class _CinematicScreenState extends State<CinematicScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<Offset> _pan;

  // Hook-phase animations (0 → hookEnd)
  late Animation<double> _hookOpacity;
  // Content-phase animations (hookEnd → 1.0)
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  static const double _hookEnd = 0.18; // first 18% = hook frame

  @override
  void initState() {
    super.initState();

    final duration = Duration(
      seconds: widget.scene.durationSeconds.clamp(3, 120),
    );

    _controller = AnimationController(vsync: this, duration: duration);

    // Background motion
    final motion = SceneMotionPreset.fromString(widget.scene.effect);
    _zoom = SceneMotionPreset.buildZoom(_controller, motion);
    _pan  = SceneMotionPreset.buildPan(_controller, motion);

    // Hook frame fades OUT after _hookEnd
    _hookOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.12, _hookEnd, curve: Curves.easeOut),
      ),
    );

    // Content fades IN starting at _hookEnd
    final contentCurve = CurvedAnimation(
      parent: _controller,
      curve: Interval(_hookEnd, _hookEnd + 0.45, curve: Curves.easeOut),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(contentCurve);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.06),
      end: Offset.zero,
    ).animate(contentCurve);

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CinematicScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        if (_controller.isCompleted || _controller.isDismissed) {
          _controller.forward(from: 0);
        } else {
          _controller.forward();
        }
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
    final scene = widget.scene;
    final hasHook = scene.hook.isNotEmpty;
    final safeBottom = SceneLayout.safeBottom(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Hook exit progress: 0 = hook visible, 1 = hook gone
        final hookExit = hasHook
            ? ((_controller.value - _hookEnd) / 0.08).clamp(0.0, 1.0)
            : 1.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. Background with motion preset ──────────────────────────
            SceneBackground(
              localImageBytes: scene.localImageBytes,
              imageUrl: scene.imageUrl,
              zoom: _zoom,
              pan: _pan,
            ),

            // ── 2. Vignette ───────────────────────────────────────────────
            const SceneVignette(intensity: 0.80),

            // ── 3. Bottom gradient ────────────────────────────────────────
            const SceneBottomGradient(strength: 0.92),

            // ── 4. Main content panel (safe area compliant) ───────────────
            FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(22, 24, 22, safeBottom),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: SceneLayout.maxContentWidth),
                      child: SceneGlassPanel(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gold accent bar
                            const SceneGoldAccent(),
                            const SizedBox(height: 10),

                            // Subtitle / category badge
                            if (scene.subtitle.isNotEmpty) ...[
                              Text(
                                scene.subtitle.toUpperCase(),
                                style: SceneTypography.subtitle,
                              ),
                              const SizedBox(height: 6),
                            ],

                            // Title — word-by-word if textEffect = 'word_by_word'
                            if (scene.textEffect == 'word_by_word')
                              WordRevealText(
                                text: scene.title,
                                style: SceneTypography.mainTitle,
                                controller: _controller,
                                startFraction: _hookEnd,
                                durationFraction: 0.4,
                              )
                            else
                              Text(scene.title,
                                  style: SceneTypography.mainTitle),

                            // Body
                            if (scene.body.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(scene.body, style: SceneTypography.body),
                            ],

                            // Key points (max 3)
                            if (scene.keyPoints.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              SceneKeyPoints(points: scene.keyPoints),
                            ],

                            // Closure line
                            if (scene.closureLine.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Divider(height: 1, color: Colors.white12),
                              const SizedBox(height: 8),
                              Text(scene.closureLine,
                                  style: SceneTypography.closureLine),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── 5. Hook frame overlay (if hook text exists) ───────────────
            if (hasHook && hookExit < 1.0)
              SceneHookFrame(
                hookText: scene.hook,
                exitOpacity: hookExit,
              ),
          ],
        );
      },
    );
  }
}
