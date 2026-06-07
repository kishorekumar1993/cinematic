import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/presentation/tempelate/scene_design_system.dart';

/// -----------------------------------------------------------------------
/// DOCUMENTARY HISTORY – BLACK & GOLD TEMPLATE  (Upgraded)
/// -----------------------------------------------------------------------
/// Scene mapping:
///   scene.hook        → 0-3s full-screen hero hook frame
///   scene.subtitle    → era tag (e.g. "SANGAM ERA")
///   scene.title       → main headline (word-by-word animation)
///   scene.body        → narration paragraph
///   scene.keyPoints   → bullet facts (max 3)
///   scene.closureLine → gold punch line
///   scene.effect      → motion preset
/// -----------------------------------------------------------------------

class CinematicSceneDocumentryOne extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneDocumentryOne({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneDocumentryOne> createState() =>
      _CinematicSceneDocumentryOneState();
}

class _CinematicSceneDocumentryOneState
    extends State<CinematicSceneDocumentryOne>
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
      seconds: widget.scene.durationSeconds.clamp(5, 90),
    );

    _controller = AnimationController(vsync: this, duration: duration);

    // Ken Burns by default for documentary feel
    final motionStr = widget.scene.effect.isEmpty ? 'ken_burns' : widget.scene.effect;
    final motion = SceneMotionPreset.fromString(motionStr);
    _zoom = SceneMotionPreset.buildZoom(_controller, motion);
    _pan  = SceneMotionPreset.buildPan(_controller, motion);

    final contentCurve = CurvedAnimation(
      parent: _controller,
      curve: Interval(_hookEnd, _hookEnd + 0.5, curve: Curves.easeOut),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(contentCurve);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.07),
      end: Offset.zero,
    ).animate(contentCurve);

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CinematicSceneDocumentryOne oldWidget) {
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
    final eraTag = scene.subtitle.isNotEmpty
        ? scene.subtitle.toUpperCase()
        : 'HISTORY FILES';
    final safeBottom = SceneLayout.safeBottom(context);
    final safeTop = SceneLayout.safeTop(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final hookExit = hasHook
            ? ((_controller.value - _hookEnd) / 0.08).clamp(0.0, 1.0)
            : 1.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. Background with Ken Burns ──────────────────────────────
            SceneBackground(
              localImageBytes: scene.localImageBytes,
              imageUrl: scene.imageUrl,
              zoom: _zoom,
              pan: _pan,
            ),

            // ── 2. Dark amber vignette ────────────────────────────────────
            const SceneVignette(intensity: 0.88),

            // ── 3. Bottom gradient ────────────────────────────────────────
            const SceneBottomGradient(strength: 0.95),

            // ── 4. Warm documentary color grade ──────────────────────────
            const SceneColorGrade(
              color: Color(0xFFFACC15), // warm amber
              opacity: 0.04,
            ),

            // ── 5. Top-left badges (safe zone compliant) ──────────────────
            FadeTransition(
              opacity: _contentFade,
              child: Positioned(
                top: safeTop,
                left: 22,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SceneGoldBadge(
                      text: 'DOCUMENTARY',
                      icon: Icons.history_edu_rounded,
                    ),
                    const SizedBox(width: 8),
                    // Era tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.70),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: SceneColors.goldOverlay(0.55),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        eraTag,
                        style: SceneTypography.subtitle
                            .copyWith(color: SceneColors.goldLight),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 6. Bottom content panel ───────────────────────────────────
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

                            // Title — word-by-word reveal
                            WordRevealText(
                              text: scene.title,
                              style: SceneTypography.mainTitle,
                              controller: _controller,
                              startFraction: _hookEnd,
                              durationFraction: 0.38,
                            ),

                            // Hook italic line (shown as body sub-head, NOT hook frame)
                            // Only shows if hook text isn't used as hook frame
                            // (when isPlaying=false or very short)

                            // Body narration
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

            // ── 7. Bottom-right chapter tag ────────────────────────────────
            Positioned(
              right: 22,
              bottom: safeBottom,
              child: FadeTransition(
                opacity: _contentFade,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: SceneColors.goldOverlay(0.45),
                      width: 0.8,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_stories_rounded,
                          size: 12, color: SceneColors.goldLight),
                      SizedBox(width: 5),
                      Text(
                        'CHAPTER OF TIME',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          letterSpacing: 1.4,
                          color: SceneColors.goldLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── 8. Hook frame (0-3s hero) ──────────────────────────────────
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
