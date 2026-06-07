import 'dart:ui';
import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';


/// --------------------------------------------------
/// CINEMATIC SCENE TEMPLATE – TOP 5 MOVIE CATEGORY
/// Netflix / IMDb Style Ranking Panel (Bottom Card)
/// --------------------------------------------------
class CinematicNetflixTemp extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicNetflixTemp({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicNetflixTemp> createState() =>
      _CinematicNetflixTempState();
}

class _CinematicNetflixTempState
    extends State<CinematicNetflixTemp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<Offset> _pan;
  late Animation<double> _fadePanel;
  late Animation<Offset> _slidePanel;

  @override
  void initState() {
    super.initState();

    final duration =
        Duration(seconds: widget.scene.durationSeconds.clamp(3, 120));

    _controller = AnimationController(vsync: this, duration: duration);

    // Background Motion (Pan + Zoom)
    _zoom = Tween<double>(begin: 1.03, end: 1.10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _pan = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.02, -0.02),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Panel Entrance
    final panelCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.65, curve: Curves.easeOut),
    );

    _fadePanel = Tween<double>(begin: 0, end: 1).animate(panelCurve);
    _slidePanel = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(panelCurve);

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CinematicNetflixTemp oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        if (_controller.isCompleted) {
          _controller.reset();
        }
        _controller.forward();
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

  // Background
  Widget _bg(SceneConfig scene) {
    if (scene.localImageBytes != null) {
      return Image.memory(scene.localImageBytes!, fit: BoxFit.cover);
    }
    if (scene.imageUrl.isNotEmpty) {
      return Image.network(
        scene.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : const Center(child: CircularProgressIndicator()),
        errorBuilder: (_, __, ___) => Container(color: Colors.black),
      );
    }
    return Container(color: Colors.black);
  }

  // Parse body -> up to 5 lines
  List<String> _topItemsFromBody(String body) {
    if (body.trim().isEmpty) return const [];
    final lines = body.split('\n');
    return lines
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .take(5)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    final items = _topItemsFromBody(scene.body);

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background motion
            FractionalTranslation(
              translation: _pan.value,
              child: Transform.scale(scale: _zoom.value, child: _bg(scene)),
            ),

            // 2. Dark vignette
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.90),
                    Colors.black.withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // 3. Bottom panel with Top 5
            FadeTransition(
              opacity: _fadePanel,
              child: SlideTransition(
                position: _slidePanel,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.60),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.16),
                            width: 0.7,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.60),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Subtitle tag
                            if (scene.subtitle.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 4, left: 2),
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
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),

                            // Hook
                            if (scene.hook.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                scene.hook,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white70,
                                ),
                              ),
                            ],

                            const SizedBox(height: 10),

                            // Top 5 Items List
                            if (items.isNotEmpty)
                              Column(
                                children: [
                                  for (int i = 0; i < items.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: _TopMovieItemRow(
                                        index: i,
                                        text: items[i],
                                        progress: _controller.value,
                                      ),
                                    ),
                                ],
                              ),

                            // Closure line
                            if (scene.closureLine.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                scene.closureLine,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 14.5,
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

            // 4. PLAY/PAUSE indicator
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

/// Single row showing rank badge + movie/category text
class _TopMovieItemRow extends StatelessWidget {
  final int index;
  final String text;
  final double progress; // 0 to 1 from AnimationController

  const _TopMovieItemRow({
    required this.index,
    required this.text,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    // Staggered timing
    const staggerDelay = 0.06;
    const entranceDuration = 0.20;
    final start = 0.25 + index * staggerDelay;
    final end = start + entranceDuration;

    final t = ((progress - start) / (end - start)).clamp(0.0, 1.0);
    final opacity = t;
    final offsetY = (1.0 - t) * 10;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, offsetY),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rank badge
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.80),
                  width: 1.2,
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.65),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                "${index + 1}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Text content
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.35,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
