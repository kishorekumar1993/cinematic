import 'dart:ui'; // (kept in case you want to reuse blur later)

import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// SINGLE CINEMATIC SCENE
/// Minimal bottom-left text layout
/// ----------------------

class CinematicSceneFour extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneFour({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneFour> createState() => _CinematicSceneFourState();
}

class _CinematicSceneFourState extends State<CinematicSceneFour>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<Offset> _pan;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    final duration = Duration(
      seconds: widget.scene.durationSeconds.clamp(3, 120),
    );

    _controller = AnimationController(
      vsync: this,
      duration: duration,
    );

    // --- Zoom animation ---
    switch (widget.scene.effect) {
      case 'zoom_out':
        _zoom = Tween<double>(begin: 1.12, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.linear),
        );
        break;
      case 'zoom_in':
      default:
        _zoom = Tween<double>(begin: 1.0, end: 1.12).animate(
          CurvedAnimation(parent: _controller, curve: Curves.linear),
        );
    }

    // --- Pan animation ---
    switch (widget.scene.effect) {
      case 'pan_right':
        _pan = Tween<Offset>(
          begin: const Offset(-0.03, 0.0),
          end: const Offset(0.03, 0.0),
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
      case 'pan_left':
        _pan = Tween<Offset>(
          begin: const Offset(0.03, 0.0),
          end: const Offset(-0.03, 0.0),
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
      default:
        _pan = Tween<Offset>(
          begin: Offset.zero,
          end: Offset.zero,
        ).animate(_controller);
    }

    // --- Text animation curve ---
    final textCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.08, 0.6, curve: Curves.easeOut),
    );

    // --- Text fade + slide effects ---
    switch (widget.scene.textEffect) {
      case 'slide_up':
        _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(textCurve);
        _textSlide = Tween<Offset>(
          begin: const Offset(0.0, 0.12),
          end: Offset.zero,
        ).animate(textCurve);
        break;
      case 'slide_left':
        _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(textCurve);
        _textSlide = Tween<Offset>(
          begin: const Offset(0.1, 0.0),
          end: Offset.zero,
        ).animate(textCurve);
        break;
      case 'typewriter':
        _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(textCurve);
        _textSlide =
            Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
          textCurve,
        );
        break;
      case 'fade':
      default:
        _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(textCurve);
        _textSlide =
            Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
          textCurve,
        );
        break;
    }

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CinematicSceneFour oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        if (_controller.isDismissed) {
          _controller.forward();
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

  // --- Typewriter effect for body text ---
  String _buildTypewriterBody(SceneConfig scene) {
    if (scene.textEffect != 'typewriter') return scene.body;
    if (scene.body.isEmpty) return '';

    final progress = _textFade.value.clamp(0.0, 1.0);
    final length =
        (scene.body.length * progress).clamp(0, scene.body.length).toInt();
    if (length <= 0) return '';
    return scene.body.substring(0, length);
  }

  // --- Background image builder (local / network / fallback) ---
  Widget _buildBackgroundImage(SceneConfig scene) {
    if (scene.localImageBytes != null) {
      return Image.memory(
        scene.localImageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade900,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, size: 48),
        ),
      );
    }

    if (scene.imageUrl.isNotEmpty) {
      return Image.network(
        scene.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade900,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, size: 48),
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
      color: Colors.grey.shade900,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, size: 48),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final typedBody = _buildTypewriterBody(scene);

        return Stack(
          fit: StackFit.expand,
          children: [
            // --- Background with pan + zoom ---
            FractionalTranslation(
              translation: _pan.value,
              child: Transform.scale(
                scale: _zoom.value,
                child: _buildBackgroundImage(scene),
              ),
            ),

            // --- Very subtle bottom gradient for readability ---
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),

            // --- Small top-left scene label (minimal) ---
            if (scene.subtitle.isNotEmpty)
              Positioned(
                top: 18,
                left: 20,
                child: Opacity(
                  opacity: 0.85,
                  child: Text(
                    scene.subtitle.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 2,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),

            // --- Minimal bottom-left text block ---
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            scene.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              color: Colors.white,
                            ),
                          ),

                          // Hook just under title (muted)
                          if (scene.hook.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              scene.hook,
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.white70,
                              ),
                            ),
                          ],

                          // Body – main narrative
                          if (scene.body.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              typedBody,
                              style: const TextStyle(
                                fontSize: 14.5,
                                height: 1.5,
                                color: Colors.white70,
                              ),
                            ),
                          ],

                          // Key points – simple bullet list
                          if (scene.keyPoints.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: scene.keyPoints
                                  .map(
                                    (kp) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '• ',
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              color: Colors.white60,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              kp,
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                height: 1.35,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],

                          // Closure line – subtle emphasis
                          if (scene.closureLine.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              scene.closureLine,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.35,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],

                          // Tiny status in the corner (optional)
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: widget.isPlaying
                                      ? Colors.redAccent
                                      : Colors.white54,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.isPlaying ? 'PLAYING' : 'PAUSED',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white54,
                                  letterSpacing: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
