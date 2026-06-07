import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ----------------------------------------------------------
/// DOCUMENTARY / HISTORY CINEMATIC TEMPLATE
/// ----------------------------------------------------------
///
/// Scene Mapping:
/// title          -> Big headline center
/// hook           -> sub-head subtitle
/// body           -> content paragraph
/// keyPoints      -> highlights badges
/// closureLine    -> footer quote
/// localImageBytes / imageUrl -> fullscreen bg
///

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
  late Animation<double> _fade;
  late Animation<double> _zoom;

  @override
  void initState() {
    super.initState();

    final duration =
        Duration(seconds: widget.scene.durationSeconds.clamp(5, 120));

    _controller = AnimationController(vsync: this, duration: duration);

    _fade = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _zoom = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isPlaying) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant CinematicSceneHistoryRevealOne oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
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

  Widget _buildBackground(SceneConfig scene) {
    if (scene.localImageBytes != null) {
      return Image.memory(scene.localImageBytes!, fit: BoxFit.cover);
    }
    if (scene.imageUrl.isNotEmpty) {
      return Image.network(scene.imageUrl, fit: BoxFit.cover);
    }
    return Container(color: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          fit: StackFit.expand,
          children: [
            /// Background zoom pan
            Transform.scale(
              scale: _zoom.value,
              child: _buildBackground(scene),
            ),

            /// Dark vignette overlay
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.black.withValues(alpha:0.1),
                    Colors.black.withValues(alpha:0.85),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),

            /// Main glass card
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: AnimatedOpacity(
                    opacity: _fade.value,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      width: 900,
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.black.withValues(alpha:0.55),
                        border: Border.all(
                          color: Colors.white.withValues(alpha:0.28),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// Title
                          Text(
                            scene.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),

                          if (scene.hook.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              scene.hook,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          ],

                          if (scene.body.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              scene.body,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.45,
                                color: Colors.white70,
                              ),
                            ),
                          ],

                          if (scene.keyPoints.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              alignment: WrapAlignment.center,
                              children: scene.keyPoints
                                  .map(
                                    (e) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(999),
                                        color: Colors.white.withValues(alpha:0.07),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha:0.3),
                                        ),
                                      ),
                                      child: Text(
                                        e,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white70),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// Footer closure text bar
            if (scene.closureLine.isNotEmpty)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black.withValues(alpha:0.65),
                      border: Border.all(
                        color: Colors.white.withValues(alpha:0.25),
                      ),
                    ),
                    child: Text(
                      scene.closureLine,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
