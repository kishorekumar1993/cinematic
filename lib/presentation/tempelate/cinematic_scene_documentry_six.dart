import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/presentation/tempelate/scene_design_system.dart';

/// -----------------------------------------------------------------------
/// IMMERSIVE DOCUMENTARY — Fullscreen Narrative (Upgraded)
/// -----------------------------------------------------------------------
/// Scene mapping:
///   scene.hook        → 0-3s full-screen hook frame
///   scene.subtitle    → edition / category label (top center)
///   scene.title       → large centered headline (word-by-word)
///   scene.body        → article-style paragraph (bottom)
///   scene.keyPoints   → bullet facts (max 3)
///   scene.closureLine → final punch line
///   scene.effect      → motion preset (default: ken_burns)
/// -----------------------------------------------------------------------

class CinematicSceneDocumentrySix extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneDocumentrySix({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneDocumentrySix> createState() =>
      _CinematicSceneDocumentrySixState();
}

class _CinematicSceneDocumentrySixState
    extends State<CinematicSceneDocumentrySix>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<Offset> _pan;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  static const double _hookEnd = 0.18;

  @override
  void initState() {
    super.initState();

    final int seconds = widget.scene.durationSeconds.clamp(5, 120).toInt();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: seconds),
    );

    // Ken Burns as default for this immersive template
    final motionStr =
        widget.scene.effect.isEmpty ? 'ken_burns' : widget.scene.effect;
    final motion = SceneMotionPreset.fromString(motionStr);
    _zoom = SceneMotionPreset.buildZoom(_controller, motion);
    _pan  = SceneMotionPreset.buildPan(_controller, motion);

    // Content fade + slide starts after hook phase
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Interval(_hookEnd, _hookEnd + 0.5, curve: Curves.easeOut),
    );
    _fade  = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _slide = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
      end: Offset.zero,
    ).animate(curve);

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CinematicSceneDocumentrySix oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      widget.isPlaying
          ? _controller.forward(from: _controller.isDismissed ? 0 : null)
          : _controller.stop();
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
    final editionTitle = scene.subtitle.isEmpty
        ? 'SPECIAL EDITION'
        : scene.subtitle.toUpperCase();
    final safeTop = SceneLayout.safeTop(context);
    final safeBottom = SceneLayout.safeBottom(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final hookExit = hasHook
            ? ((_controller.value - _hookEnd) / 0.08).clamp(0.0, 1.0)
            : 1.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. Background — desaturated for newspaper feel ────────────
            ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.3, 0.3, 0.3, 0, 0,
                0.3, 0.3, 0.3, 0, 0,
                0.3, 0.3, 0.3, 0, 0,
                0,   0,   0,   1, 0,
              ]),
              child: SceneBackground(
                localImageBytes: scene.localImageBytes is Uint8List &&
                        (scene.localImageBytes as Uint8List).isNotEmpty
                    ? scene.localImageBytes
                    : null,
                imageUrl: scene.imageUrl,
                zoom: _zoom,
                pan: _pan,
              ),
            ),

            // ── 2. Vignette ───────────────────────────────────────────────
            const SceneVignette(intensity: 0.80),

            // ── 3. Top edition label (safe-zone compliant) ────────────────
            Positioned(
              top: safeTop + 4,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fade,
                child: Center(
                  child: Text(
                    editionTitle,
                    style: SceneTypography.subtitle.copyWith(
                      color: SceneColors.goldLight,
                      letterSpacing: 3.0,
                    ),
                  ),
                ),
              ),
            ),

            // ── 4. Centered main headline ─────────────────────────────────
            Positioned(
              top: safeTop + 32,
              left: 28,
              right: 28,
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    const SceneGoldAccent(width: 36, height: 2),
                    const SizedBox(height: 14),
                    WordRevealText(
                      text: scene.title,
                      style: SceneTypography.mainTitle.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                      controller: _controller,
                      startFraction: _hookEnd,
                      durationFraction: 0.38,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // ── 5. Bottom article section ─────────────────────────────────
            FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(24, 20, 24, safeBottom),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.96),
                          Colors.black.withValues(alpha: 0.55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (scene.body.isNotEmpty)
                            Text(
                              scene.body,
                              style: SceneTypography.body.copyWith(
                                fontStyle: FontStyle.normal,
                              ),
                            ),

                          if (scene.keyPoints.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            SceneKeyPoints(points: scene.keyPoints),
                          ],

                          if (scene.closureLine.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            const Divider(color: Colors.white24, height: 1),
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

            // ── 6. Hook frame ─────────────────────────────────────────────
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
