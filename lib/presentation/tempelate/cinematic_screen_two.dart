import 'dart:ui'; // for ImageFilter.blur

import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// SINGLE CINEMATIC SCENE
/// ----------------------

class CinematicScreenTwo extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicScreenTwo({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicScreenTwo> createState() => _CinematicScreenTwoState();
}

class _CinematicScreenTwoState extends State<CinematicScreenTwo>
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
        _zoom = Tween<double>(begin: 1.15, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.linear),
        );
        break;
      case 'zoom_in':
      default:
        _zoom = Tween<double>(begin: 1.0, end: 1.15).animate(
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
          begin: const Offset(0.0, 0.2),
          end: Offset.zero,
        ).animate(textCurve);
        break;
      case 'slide_left':
        _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(textCurve);
        _textSlide = Tween<Offset>(
          begin: const Offset(0.15, 0.0),
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
  void didUpdateWidget(covariant CinematicScreenTwo oldWidget) {
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

            // --- Dark vignette edges ---
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.1, 1.0],
                ),
              ),
            ),

            // --- Cinematic top bar (letterbox + scene info) ---
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Scene chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 0.6,
                        ),
                      ),
                      child: Text(
                        scene.subtitle.isNotEmpty
                            ? scene.subtitle.toUpperCase()
                            : 'SCENE',
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 2,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    // Right small indicator
                    Row(
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
                          widget.isPlaying ? 'REC' : 'PAUSED',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- Cinematic bottom bar (letterbox) ---
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // --- TEXT BLOCK: bottom-right glass card with animation ---
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  child: Row(
                    children: [
                      // Left vertical gradient bar (accent)
                      Container(
                        width: 4,
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFEF4444),
                              Color(0xFFFACC15),
                              Color(0xFF22C55E),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Right glass card
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 640),
                                padding: const EdgeInsets.fromLTRB(
                                    20, 16, 20, 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color: Colors.black.withOpacity(0.45),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.18),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.7),
                                      blurRadius: 22,
                                      offset: const Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Title row + mini label
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            scene.title,
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w700,
                                              height: 1.15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        if (scene.hook.isNotEmpty)
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 12),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.06),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: const Text(
                                              'STORY MOMENT',
                                              style: TextStyle(
                                                fontSize: 11,
                                                letterSpacing: 1.2,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),

                                    if (scene.hook.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        scene.hook,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],

                                    if (scene.body.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        typedBody,
                                        style: const TextStyle(
                                          fontSize: 15.5,
                                          height: 1.4,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],

                                    if (scene.keyPoints.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 4,
                                        children: scene.keyPoints
                                            .map(
                                              (kp) => Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Icon(
                                                    Icons.circle,
                                                    size: 5,
                                                    color: Colors.white54,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Text(
                                                      kp,
                                                      style:
                                                          const TextStyle(
                                                        fontSize: 13.5,
                                                        height: 1.3,
                                                        color:
                                                            Colors.white70,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],

                                    if (scene.closureLine.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 1,
                                            color: Colors.white
                                                .withOpacity(0.7),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              scene.closureLine,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                height: 1.3,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
