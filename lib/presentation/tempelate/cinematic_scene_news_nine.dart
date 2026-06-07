import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ----------------------------------------------------
/// FUTURISTIC HOLOGRAPHIC STUDIO NEWS TEMPLATE
/// ----------------------------------------------------

class CinematicSceneNewsNine extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneNewsNine({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneNewsNine> createState() => _CinematicSceneNewsNineState();
}

class _CinematicSceneNewsNineState extends State<CinematicSceneNewsNine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<Offset> _pan;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();

    final duration = Duration(
      seconds: widget.scene.durationSeconds.clamp(5, 60),
    );

    _controller = AnimationController(vsync: this, duration: duration);

    _zoom = Tween<double>(
      begin: 1.03,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _pan = Tween<Offset>(
      begin: const Offset(-0.015, 0.0),
      end: const Offset(0.015, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    final textCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.7, curve: Curves.easeOut),
    );

    _textFade = Tween<double>(begin: 0, end: 1).animate(textCurve);
    _textSlide = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(textCurve);

    _glowPulse = Tween<double>(
      begin: 0.55,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isPlaying) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant CinematicSceneNewsNine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      widget.isPlaying ? _controller.repeat(reverse: true) : _controller.stop();
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
      return Image.network(scene.imageUrl, fit: BoxFit.cover);
    }
    return Container(color: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    final tagText = scene.subtitle.isNotEmpty
        ? scene.subtitle.toUpperCase()
        : 'HEADLINES';

    final tickerText = scene.closureLine.isNotEmpty
        ? scene.closureLine
        : scene.title;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          fit: StackFit.expand,
          children: [
            /// BACKGROUND zoom + pan
            FractionalTranslation(
              translation: _pan.value,
              child: Transform.scale(scale: _zoom.value, child: _bg(scene)),
            ),

            /// DIM OVERLAY
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),

            /// FLOATING HOLOGRAM HEADLINE CARD
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Align(
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        width: 800,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.5),
                              blurRadius: 24,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.6),
                            width: 1.4,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// HEADER TAB STRIP
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: Colors.blueAccent.withOpacity(0.22),
                                    border: Border.all(
                                      color: Colors.blueAccent.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    tagText,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            /// MAIN HEADLINE
                            Text(
                              scene.title,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                                shadows: [
                                  Shadow(color: Colors.black87, blurRadius: 8),
                                ],
                              ),
                            ),

                            /// HOOK TEXT
                            if (scene.hook.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                scene.hook,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white70,
                                ),
                              ),
                            ],

                            /// BODY
                            if (scene.body.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                scene.body,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: Colors.white70,
                                ),
                              ),
                            ],

                            /// TAGS STRIP
                            if (scene.keyPoints.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: scene.keyPoints
                                    .map(
                                      (kp) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent.withOpacity(
                                            0.18,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: Colors.blueAccent
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                        child: Text(
                                          kp,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: Colors.white,
                                          ),
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
            ),

            /// HOLOGRAM NEON TICKER BAR (STATIC)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 38,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueAccent.withOpacity(0.9),
                      Colors.blueAccent.withOpacity(0.5),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    tickerText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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
