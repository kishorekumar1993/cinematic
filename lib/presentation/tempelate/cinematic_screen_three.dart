import 'dart:ui'; // for ImageFilter.blur

import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// SINGLE CINEMATIC SCENE
/// ----------------------

class CinematicSceneThree extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneThree({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneThree> createState() => _CinematicSceneThreeState();
}

class _CinematicSceneThreeState extends State<CinematicSceneThree>
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
  void didUpdateWidget(covariant CinematicSceneThree oldWidget) {
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

            // --- Overall gradient overlay (top + bottom darker) ---
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x99000000),
                    Color(0x00000000),
                    Color(0xCC000000),
                  ],
                ),
              ),
            ),

            // --- Subtle vignette at corners ---
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.75),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),

            // --- Small top-left scene label ---
            Positioned(
              top: 20,
              left: 24,
              child: Opacity(
                opacity: 0.9,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF38BDF8),
                            Color(0xFF6366F1),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scene.subtitle.isNotEmpty
                              ? scene.subtitle.toUpperCase()
                              : 'CINEMATIC MOMENT',
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 2,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          scene.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- Centered glass story card ---
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 720,
                        minWidth: 420,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              color: Colors.black.withOpacity(0.55),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.22),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 26,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top accent + timing / status row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFF97316),
                                            Color(0xFFEC4899),
                                            Color(0xFF22C55E),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: widget.isPlaying
                                                ? Colors.redAccent
                                                : Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          widget.isPlaying ? 'PLAYING' : 'PAUSED',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white70,
                                            letterSpacing: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                // Subtitle (small, above main title)
                                if (scene.subtitle.isNotEmpty) ...[
                                  Text(
                                    scene.subtitle,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white60,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],

                                // Main title
                                Text(
                                  scene.title,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    height: 1.15,
                                    color: Colors.white,
                                  ),
                                ),

                                // Hook line
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

                                // Body / narrative
                                if (scene.body.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  Text(
                                    typedBody,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      height: 1.45,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],

                                // Key points (bullets) as subtle chips
                                if (scene.keyPoints.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: scene.keyPoints.map((kp) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.white.withOpacity(0.06),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.15),
                                            width: 0.6,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.circle,
                                              size: 4,
                                              color: Colors.white70,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              kp,
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                height: 1.3,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],

                                // Closure line separated visually
                                if (scene.closureLine.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.only(top: 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Colors.white.withOpacity(0.16),
                                          width: 0.7,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.format_quote_rounded,
                                          size: 18,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            scene.closureLine,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              height: 1.35,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
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
              ),
            ),

            // --- Bottom-right tiny scene index / label (optional style) ---
            Positioned(
              right: 24,
              bottom: 20,
              child: Opacity(
                opacity: 0.85,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 0.6,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.movie_rounded,
                        size: 14,
                        color: Colors.white70,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'CINEMATIC STORY',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          color: Colors.white70,
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
