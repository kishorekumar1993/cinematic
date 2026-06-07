import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ----------------------------------------------------
/// YOUTUBE DOCUMENTARY FRAME TEMPLATE
/// ----------------------------------------------------
///
/// Optimized for YouTube documentary-style videos:
/// - Background: slow zoom/pan
/// - Soft letterbox bars (top & bottom)
/// - Clean documentary "paper card" in bottom-left
///
/// SceneConfig mapping:
/// - title        -> Main documentary title
/// - subtitle     -> Era / theme (e.g. "SANGAM ERA", "TAMIL HISTORY")
/// - hook         -> Short poetic hook or line
/// - body         -> Main narration (can use typewriter effect)
/// - keyPoints    -> Bullet facts
/// - closureLine  -> Final strong line
/// - effect       -> "zoom_in", "zoom_out", "pan_left", "pan_right" (optional)
/// - textEffect   -> "fade", "slide_up", "slide_left", "typewriter"
/// - imageUrl / localImageBytes -> Background image
///
/// isPlaying == true  -> animation runs
/// isPlaying == false -> frame pauses (good for scrub/preview)
///

class CinematicSceneDocumentryFour extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneDocumentryFour({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneDocumentryFour> createState() => _CinematicSceneDocumentryFourState();
}

class _CinematicSceneDocumentryFourState extends State<CinematicSceneDocumentryFour>
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
      seconds: widget.scene.durationSeconds.clamp(5, 120),
    );

    _controller = AnimationController(
      vsync: this,
      duration: duration,
    );

    // -----------------------
    // BACKGROUND EFFECT LOGIC
    // -----------------------
    switch (widget.scene.effect) {
      case 'zoom_out':
        _zoom = Tween<double>(begin: 1.1, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.linear),
        );
        break;
      case 'zoom_in':
      default:
        _zoom = Tween<double>(begin: 1.0, end: 1.08).animate(
          CurvedAnimation(parent: _controller, curve: Curves.linear),
        );
    }

    switch (widget.scene.effect) {
      case 'pan_right':
        _pan = Tween<Offset>(
          begin: const Offset(-0.02, 0.0),
          end: const Offset(0.02, 0.0),
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
      case 'pan_left':
        _pan = Tween<Offset>(
          begin: const Offset(0.02, 0.0),
          end: const Offset(-0.02, 0.0),
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

    // -------------------
    // TEXT EFFECT LOGIC
    // -------------------
    final textCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.75, curve: Curves.easeOut),
    );

    switch (widget.scene.textEffect) {
      case 'slide_up':
        _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(textCurve);
        _textSlide = Tween<Offset>(
          begin: const Offset(0.0, 0.15),
          end: Offset.zero,
        ).animate(textCurve);
        break;
      case 'slide_left':
        _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(textCurve);
        _textSlide = Tween<Offset>(
          begin: const Offset(0.08, 0.0),
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
  void didUpdateWidget(covariant CinematicSceneDocumentryFour oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        if (_controller.isDismissed || _controller.isCompleted) {
          _controller.forward(from: 0);
        } else if (!_controller.isAnimating) {
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

  // -----------------------
  // TYPEWRITER FOR BODY
  // -----------------------
  String _buildTypewriterBody(SceneConfig scene) {
    if (scene.textEffect != 'typewriter') return scene.body;
    if (scene.body.isEmpty) return '';

    final progress = _textFade.value.clamp(0.0, 1.0);
    final length =
        (scene.body.length * progress).clamp(0, scene.body.length).toInt();
    if (length <= 0) return '';
    return scene.body.substring(0, length);
  }

  // -----------------------
  // BACKGROUND IMAGE BUILDER
  // -----------------------
  Widget _buildBackgroundImage(SceneConfig scene) {
    if (scene.localImageBytes != null) {
      return Image.memory(
        scene.localImageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackBackground(),
      );
    }

    if (scene.imageUrl.isNotEmpty) {
      return Image.network(
        scene.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackBackground(),
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

    return _fallbackBackground();
  }

  Widget _fallbackBackground() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported,
        size: 48,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    final typedBody = _buildTypewriterBody(scene);

    final eraTag = scene.subtitle.isNotEmpty
        ? scene.subtitle.toUpperCase()
        : 'DOCUMENTARY';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // BACKGROUND with zoom + pan + slight darken
            FractionalTranslation(
              translation: _pan.value,
              child: Transform.scale(
                scale: _zoom.value,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha:0.2),
                    BlendMode.darken,
                  ),
                  child: _buildBackgroundImage(scene),
                ),
              ),
            ),

            // LETTERBOX EFFECT (top & bottom bars)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha:0.9),
                      Colors.black.withValues(alpha:0.0),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha:0.9),
                      Colors.black.withValues(alpha:0.0),
                    ],
                  ),
                ),
              ),
            ),

            // SMALL ERA LABEL (top-left, subtle)
            Positioned(
              top: 14,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha:0.75),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha:0.28),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      eraTag,
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.4,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // MAIN DOCUMENTARY CARD (bottom-left, YouTube-safe area)
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 60),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha:0.70),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha:0.2),
                            width: 0.9,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.9),
                              blurRadius: 24,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Small top accent line
                            Container(
                              width: 40,
                              height: 2,
                              color: Colors.white.withValues(alpha:0.7),
                            ),
                            const SizedBox(height: 8),

                            // TITLE
                            Text(
                              scene.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                                color: Colors.white,
                              ),
                            ),

                            // HOOK
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

                            // BODY (with optional typewriter)
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

                            // KEY POINTS
                            if (scene.keyPoints.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: scene.keyPoints
                                    .map(
                                      (kp) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 3),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '• ',
                                              style: TextStyle(
                                                fontSize: 13.5,
                                                color: Colors.white70,
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

                            // CLOSURE LINE
                            if (scene.closureLine.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              const Divider(
                                height: 1,
                                color: Colors.white24,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                scene.closureLine,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
          ],
        );
      },
    );
  }
}
