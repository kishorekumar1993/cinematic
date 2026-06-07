
import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// BREAKING NEWS TEMPLATE
/// ----------------------

class CinematicSceneNewsOne extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneNewsOne({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneNewsOne> createState() => _CinematicSceneNewsOneState();
}

class _CinematicSceneNewsOneState extends State<CinematicSceneNewsOne>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;
  late Animation<double> _tickerSlide;
  late Animation<double> _zoom;

  @override
  void initState() {
    super.initState();

    final duration = Duration(seconds: widget.scene.durationSeconds.clamp(3, 120));

    _controller = AnimationController(vsync: this, duration: duration);

    // Flashing pulse for Breaking text
    _pulse = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Subtle zoom for background
    _zoom = Tween<double>(begin: 1.03, end: 1.10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // Ticker slide animation
    _tickerSlide = Tween<double>(begin: 1.0, end: -1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    if (widget.isPlaying) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant CinematicSceneNewsOne oldWidget) {
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
      return Image.network(
        scene.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : const Center(child: CircularProgressIndicator()),
      );
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
            // Slight zooming background
            Transform.scale(scale: _zoom.value, child: _bg(scene)),

            // Gradient overlay for readability
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black,
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // BREAKING NEWS Header Bar
            Align(
              alignment: Alignment.topCenter,
              child: Opacity(
                opacity: _pulse.value,
                child: Container(
                  height: 50,
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade900,
                        Colors.red.shade600,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.6),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Text(
                    "BREAKING NEWS",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),

            // Main Headline Center
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Text(
                    scene.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha:0.7),
                          blurRadius: 10,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Optional Body / Supporting Information
            if (scene.body.isNotEmpty)
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 120.0, left: 24, right: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Text(
                      scene.body,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),

            // MOVING TICKER BAR
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 38,
                width: double.infinity,
                color: Colors.red.shade800,
                child: Stack(
                  children: [
                    // scrolling text
                    FractionalTranslation(
                      translation: Offset(_tickerSlide.value, 0),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Text(
                            scene.closureLine.isNotEmpty
                                ? scene.closureLine
                                : "LIVE BREAKING UPDATE • STAY TUNED •",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            // Small LIVE indicator
            Positioned(
              left: 20,
              bottom: 56,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.circle, size: 10, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      "LIVE",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
