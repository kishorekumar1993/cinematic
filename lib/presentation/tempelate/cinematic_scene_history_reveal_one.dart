import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/presentation/tempelate/scene_design_system.dart';

/// -----------------------------------------------------------------------
/// HISTORY REVEAL — Ancient & Cinematic (Upgraded)
/// -----------------------------------------------------------------------
/// Scene mapping:
///   scene.hook        → 0-3s full-screen hook frame (hook text)
///   scene.title       → big centered headline (word-by-word)
///   scene.subtitle    → sub-head under title
///   scene.body        → paragraph
///   scene.keyPoints   → highlight badges (max 4)
///   scene.closureLine → bottom quote bar
///   scene.effect      → motion preset (default: ken_burns)
/// -----------------------------------------------------------------------

class CinematicSceneHistoryRevealOne extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneHistoryRevealOne({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneHistoryRevealOne> createState() =>
      _CinematicSceneHistoryRevealOneState();
}

class _CinematicSceneHistoryRevealOneState
    extends State<CinematicSceneHistoryRevealOne>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<Offset> _pan;
  late Animation<double> _cardFade;
  late Animation<double> _cardScale;

  static const double _hookEnd = 0.18;

  @override
  void initState() {
    super.initState();

    final duration =
        Duration(seconds: widget.scene.durationSeconds.clamp(5, 120));
    _controller = AnimationController(vsync: this, duration: duration);

    // Ken Burns slow breathe
    _zoom = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _pan = Tween<Offset>(
      begin: const Offset(-0.015, -0.01),
      end: const Offset(0.015, 0.01),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Glass card reveal (after hook phase)
    final cardCurve = CurvedAnimation(
      parent: _controller,
      curve: Interval(_hookEnd, _hookEnd + 0.45, curve: Curves.easeOut),
    );
    _cardFade  = Tween<double>(begin: 0.0, end: 1.0).animate(cardCurve);
    _cardScale = Tween<double>(begin: 0.92, end: 1.0).animate(cardCurve);

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CinematicSceneHistoryRevealOne oldWidget) {
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
      builder: (_, __) {
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

            // ── 2. Deep radial vignette ───────────────────────────────────
            const SceneVignette(intensity: 0.85),

            // ── 3. Warm amber color grade ─────────────────────────────────
            const SceneColorGrade(
              color: Color(0xFFFACC15),
              opacity: 0.05,
            ),

            // ── 4. Center glass reveal card ───────────────────────────────
            Align(
              alignment: Alignment.center,
              child: FadeTransition(
                opacity: _cardFade,
                child: ScaleTransition(
                  scale: _cardScale,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              color: Colors.black.withValues(alpha: 0.60),
                              border: Border.all(
                                color: SceneColors.goldOverlay(0.30),
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Top gold accent
                                const SceneGoldAccent(width: 44),
                                const SizedBox(height: 16),

                                // Title — word-by-word reveal
                                WordRevealText(
                                  text: scene.title,
                                  style: SceneTypography.mainTitle.copyWith(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  controller: _controller,
                                  startFraction: _hookEnd,
                                  durationFraction: 0.38,
                                  textAlign: TextAlign.center,
                                ),

                                // Subtitle
                                if (scene.subtitle.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    scene.subtitle,
                                    textAlign: TextAlign.center,
                                    style: SceneTypography.hookLine,
                                  ),
                                ],

                                // Body
                                if (scene.body.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  Text(
                                    scene.body,
                                    textAlign: TextAlign.center,
                                    style: SceneTypography.body,
                                  ),
                                ],

                                // Key point badges (max 4)
                                if (scene.keyPoints.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    alignment: WrapAlignment.center,
                                    children: scene.keyPoints
                                        .take(4)
                                        .map((e) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                color: SceneColors.goldOverlay(0.12),
                                                border: Border.all(
                                                  color: SceneColors.goldOverlay(0.35),
                                                ),
                                              ),
                                              child: Text(e,
                                                  style: SceneTypography.keyPoint
                                                      .copyWith(
                                                          color: SceneColors.goldLight,
                                                          fontSize: 12)),
                                            ))
                                        .toList(),
                                  ),
                                ],

                                const SizedBox(height: 12),
                                // Bottom accent
                                const SceneGoldAccent(width: 44),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── 5. Closure quote at safe bottom ───────────────────────────
            if (scene.closureLine.isNotEmpty)
              Positioned(
                bottom: safeBottom,
                left: 28,
                right: 28,
                child: FadeTransition(
                  opacity: _cardFade,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.black.withValues(alpha: 0.70),
                        border: Border.all(
                          color: SceneColors.goldOverlay(0.30),
                        ),
                      ),
                      child: Text(
                        scene.closureLine,
                        textAlign: TextAlign.center,
                        style: SceneTypography.closureLine.copyWith(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ── 6. Hook frame (0-3s hero) ──────────────────────────────────
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
