import 'dart:ui';
import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// BREAKING NEWS CINEMATIC TEMPLATE
/// ----------------------

class CinematicSceneNewsTwo extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneNewsTwo({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneNewsTwo> createState() => _CinematicSceneNewsTwoState();
}

class _CinematicSceneNewsTwoState extends State<CinematicSceneNewsTwo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;
  late Animation<double> _tickerSlide;
  late Animation<double> _zoom;

  @override
  void initState() {
    super.initState();

    // Use total scene duration just to keep controller alive;
    // ticker will loop until isPlaying = false
    final duration = Duration(
      seconds: widget.scene.durationSeconds.clamp(5, 120),
    );

    _controller = AnimationController(vsync: this, duration: duration);

    // Flashing pulse for BREAKING bar
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Slight background zoom
    _zoom = Tween<double>(begin: 1.02, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // Ticker movement from right to left
    _tickerSlide = Tween<double>(begin: 1.0, end: -1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CinematicSceneNewsTwo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        if (!_controller.isAnimating) {
          _controller.repeat();
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

  // --- Background image (local / network / fallback) ---
  Widget _buildBackground(SceneConfig scene) {
    if (scene.localImageBytes != null) {
      return Image.memory(
        scene.localImageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, size: 48, color: Colors.white),
        ),
      );
    }

    if (scene.imageUrl.isNotEmpty) {
      return Image.network(
        scene.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, size: 48, color: Colors.white),
        ),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
      );
    }

    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, size: 48, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final tickerText = scene.closureLine.isNotEmpty
            ? scene.closureLine
            : (scene.subtitle.isNotEmpty
                ? scene.subtitle
                : 'LIVE BREAKING UPDATE • STAY TUNED •');

        return Stack(
          fit: StackFit.expand,
          children: [
            // --- Background with cinematic zoom ---
            Transform.scale(
              scale: _zoom.value,
              child: _buildBackground(scene),
            ),

            // --- Dark gradient overlay for readability ---
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFF000000),
                    Color(0x66000000),
                    Color(0x00000000),
                  ],
                ),
              ),
            ),

            // --- BREAKING NEWS header bar ---
            Align(
              alignment: Alignment.topCenter,
              child: Opacity(
                opacity: _pulse.value,
                child: Container(
                  height: 52,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade900,
                        Colors.red.shade700,
                        Colors.red.shade600,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.7),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'BREAKING',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          scene.subtitle.isNotEmpty
                              ? scene.subtitle.toUpperCase()
                              : 'BREAKING NEWS UPDATE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Center headline + hook/body ---
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Headline
                      Text(
                        scene.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.7),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),

                      // Hook (sub-head)
                      if (scene.hook.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          scene.hook,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],

                      // Body content as details
                      if (scene.body.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          scene.body,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.white70,
                          ),
                        ),
                      ],

                      // Optional key points as tags
                      if (scene.keyPoints.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: scene.keyPoints
                              .map(
                                (kp) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.16),
                                      width: 0.6,
                                    ),
                                  ),
                                  child: Text(
                                    kp,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
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

            // --- Moving ticker bar at bottom ---
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 40,
                width: double.infinity,
                color: Colors.red.shade800,
                child: ClipRect(
                  child: Stack(
                    children: [
                      // Repeating text flow (simple 1-pass illusion)
                      FractionalTranslation(
                        translation: Offset(_tickerSlide.value, 0),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Text(
                              tickerText,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(width: 32),
                            Text(
                              tickerText,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- LIVE tag + play status above ticker ---
            Positioned(
              left: 20,
              bottom: 48,
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.circle, size: 10, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'LIVE',
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
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isPlaying
                              ? Colors.greenAccent
                              : Colors.white54,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.isPlaying ? 'ON AIR' : 'PAUSED',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
