import 'dart:ui';
import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// CINEMATIC SCENE TEMPLATE 5
/// National Geographic / Discovery Channel Caption Bar
/// ----------------------

class CinematicSceneSix extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneSix({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneSix> createState() => _CinematicSceneSixState();
}

class _CinematicSceneSixState extends State<CinematicSceneSix>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<Offset> _pan;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    final duration = Duration(seconds: widget.scene.durationSeconds.clamp(3, 120));

    _controller = AnimationController(vsync: this, duration: duration);

    _zoom = Tween<double>(begin: 1.02, end: 1.10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _pan = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    final textCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.6, curve: Curves.easeOut),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(textCurve);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(textCurve);

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CinematicSceneSix oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isPlaying != widget.isPlaying) {
      widget.isPlaying ? _controller.forward() : _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bg(SceneConfig scene) {
    if (scene.localImageBytes != null) {
      return Image.memory(scene.localImageBytes!, fit: BoxFit.cover);
    }
    if (scene.imageUrl.isNotEmpty) {
      return Image.network(scene.imageUrl, fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : const Center(child: CircularProgressIndicator()));
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
            // Background motion
            FractionalTranslation(
              translation: _pan.value,
              child: Transform.scale(scale: _zoom.value, child: _bg(scene)),
            ),

            // Subtle cinematic vignette
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha:0.90),
                    Colors.black.withValues(alpha:0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Caption panel bottom center
            FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha:0.55),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha:0.15),
                            width: 0.6,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Subtitle tag
                            if (scene.subtitle.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  scene.subtitle.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 2,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),

                            // Title
                            Text(
                              scene.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),

                            // Hook
                            if (scene.hook.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                scene.hook,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white70,
                                ),
                              )
                            ],

                            // Body
                            if (scene.body.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                scene.body,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  height: 1.45,
                                  color: Colors.white70,
                                ),
                              ),
                            ],

                            // Closure line emphasized
                            if (scene.closureLine.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Text(
                                scene.closureLine,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
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

            // Small PLAY/PAUSE indicator
            Positioned(
              right: 20,
              bottom: 20,
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isPlaying
                          ? Colors.redAccent
                          : Colors.white54,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.isPlaying ? "PLAYING" : "PAUSED",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
