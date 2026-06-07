import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/presentation/tempelate/scene_design_system.dart';

/// -----------------------------------------------------------------------
/// NARRATIVE FOCUS — YouTube Documentary Style (Upgraded)
/// -----------------------------------------------------------------------
/// Clean letterbox layout. Subtle era tag top-left.
/// Bottom-left glass panel with title, body and key facts.
///
/// Scene mapping:
///   scene.hook        → 0-3s full-screen hook frame
///   scene.subtitle    → era / theme tag (top-left badge)
///   scene.title       → main headline (word-by-word animation)
///   scene.body        → narration paragraph
///   scene.keyPoints   → bullet facts (max 3)
///   scene.closureLine → gold punch line
///   scene.effect      → motion preset
/// -----------------------------------------------------------------------

class CinematicSceneDocumentryFour extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneDocumentryFour({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneDocumentryFour> createState() =>
      _CinematicSceneDocumentryFourState();
}

class _CinematicSceneDocumentryFourState
    extends State<CinematicSceneDocumentryFour>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<Offset> _pan;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  static const double _hookEnd = 0.18;

  @override
  void initState() {
    super.initState();

    final duration = Duration(
      seconds: widget.scene.durationSeconds.clamp(5, 120),
    );
    _controller = AnimationController(vsync: this, duration: duration);

    final motion = SceneMotionPreset.fromString(
        widget.scene.effect.isEmpty ? 'ken_burns' : widget.scene.effect);
    _zoom = SceneMotionPreset.buildZoom(_controller, motion);
    _pan  = SceneMotionPreset.buildPan(_controller, motion);

    final contentCurve = CurvedAnimation(
      parent: _controller,
      curve: Interval(_hookEnd, _hookEnd + 0.5, curve: Curves.easeOut),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(contentCurve);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(contentCurve);

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CinematicSceneDocumentryFour oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        if (_controller.isDismissed || _controller.isCompleted) {
          _controller.forward(from: 0);
        } else if (!_controller.isAnimating) {
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
    final eraTag = scene.subtitle.isNotEmpty
        ? scene.subtitle.toUpperCase()
        : 'DOCUMENTARY';
    final safeTop    = SceneLayout.safeTop(context);
    final safeBottom = SceneLayout.safeBottom(context);

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

            // ── 2. Vignette ───────────────────────────────────────────────
            const SceneVignette(intensity: 0.82),

            // ── 3. Subtle cinematic letterbox look (not hard bars) ─────────
            const SceneBottomGradient(strength: 0.92),

            // ── 4. Top letterbox gradient ─────────────────────────────────
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── 5. Era badge (safe-zone compliant top-left) ───────────────
            Positioned(
              top: safeTop,
              left: 18,
              child: FadeTransition(
                opacity: _contentFade,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_rounded,
                          size: 13, color: SceneColors.goldLight),
                      const SizedBox(width: 6),
                      Text(eraTag, style: SceneTypography.subtitle),
                    ],
                  ),
                ),
              ),
            ),

            // ── 6. Main content panel (safe-area bottom) ──────────────────
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
                        backgroundOpacity: 0.72,
                        borderColor: Colors.white.withValues(alpha: 0.20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // White accent line (neutral style for this template)
                            Container(
                              width: 42,
                              height: 2.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Title — word-by-word
                            WordRevealText(
                              text: scene.title,
                              style: SceneTypography.mainTitle.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                              controller: _controller,
                              startFraction: _hookEnd,
                              durationFraction: 0.4,
                            ),

                            // Body
                            if (scene.body.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(scene.body, style: SceneTypography.body),
                            ],

                            // Key points — max 3
                            if (scene.keyPoints.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              SceneKeyPoints(points: scene.keyPoints),
                            ],

                            // Closure line
                            if (scene.closureLine.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              const Divider(height: 1, color: Colors.white12),
                              const SizedBox(height: 7),
                              Text(
                                scene.closureLine,
                                style: SceneTypography.closureLine,
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

            // ── 7. Hook frame ──────────────────────────────────────────────
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
