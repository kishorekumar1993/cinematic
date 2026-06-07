import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ----------------------------------------------------
/// SPOTLIGHT BIOGRAPHY DOCUMENTARY TEMPLATE
/// ----------------------------------------------------

class CinematicSceneDocumentryFive extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneDocumentryFive({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneDocumentryFive> createState() => _CinematicSceneDocumentryFiveState();
}

class _CinematicSceneDocumentryFiveState extends State<CinematicSceneDocumentryFive>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.scene.durationSeconds.clamp(5, 120)),
    );

    _zoom = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(old) {
    super.didUpdateWidget(old);
    widget.isPlaying ? _controller.forward(from: 0) : _controller.stop();
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
            // Background zoom + blur fade
            Transform.scale(
              scale: _zoom.value,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _bg(scene),
                  Container(
                    color: Colors.black.withValues(alpha:0.35),
                  ),
                  // radial spotlight
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          Colors.black.withValues(alpha:0.0),
                          Colors.black.withValues(alpha:0.65),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // CENTER TITLE STRIP (cinematic)
            Align(
              alignment: Alignment.center,
              child: FadeTransition(
                opacity: _fade,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha:0.75),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    scene.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),

            // SUB HEADLINE (below title)
            if (scene.hook.isNotEmpty)
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: SlideTransition(
                    position: _slide,
                    child: FadeTransition(
                      opacity: _fade,
                      child: Text(
                        scene.hook,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // DOCUMENTARY NARRATION AREA (bottom card)
            FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 50),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha:0.9),
                          Colors.black.withValues(alpha:0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (scene.body.isNotEmpty)
                            Text(
                              scene.body,
                              style: const TextStyle(
                                fontSize: 17,
                                height: 1.5,
                                color: Colors.white,
                              ),
                            ),

                          if (scene.keyPoints.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: scene.keyPoints
                                  .map(
                                    (kp) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        "• $kp",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],

                          if (scene.closureLine.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              scene.closureLine,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
