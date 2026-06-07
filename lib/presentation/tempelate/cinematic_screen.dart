import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// SINGLE CINEMATIC SCENE
/// ----------------------

class CinematicScene extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicScene({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicScene> createState() => _CinematicSceneState();
}

class _CinematicSceneState extends State<CinematicScene>
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

    final textCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.08, 0.6, curve: Curves.easeOut),
    );

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
  void didUpdateWidget(covariant CinematicScene oldWidget) {
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

  String _buildTypewriterBody(SceneConfig scene) {
    if (scene.textEffect != 'typewriter') return scene.body;
    if (scene.body.isEmpty) return '';

    final progress = _textFade.value.clamp(0.0, 1.0);
    final length =
        (scene.body.length * progress).clamp(0, scene.body.length).toInt();
    if (length <= 0) return '';
    return scene.body.substring(0, length);
  }

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
            FractionalTranslation(
              translation: _pan.value,
              child: Transform.scale(
                scale: _zoom.value,
                child: _buildBackgroundImage(scene),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xCC000000),
                    Color(0x66000000),
                    Color(0x33000000),
                    Color(0x00000000),
                  ],
                ),
              ),
            ),
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha:0.55),
                          borderRadius: BorderRadius.circular(18),
                          border:
                              Border.all(color: Colors.white24, width: 0.6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.6),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (scene.subtitle.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha:0.08),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  scene.subtitle.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    letterSpacing: 2,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            Text(
                              scene.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                                color: Colors.white,
                              ),
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
                            const SizedBox(height: 12),
                            if (scene.body.isNotEmpty)
                              Text(
                                typedBody,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                  color: Colors.white70,
                                ),
                              ),
                            if (scene.keyPoints.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: scene.keyPoints
                                    .map(
                                      (kp) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2),
                                        child: Text(
                                          '• $kp',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.3,
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
                                  height: 1.3,
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
          ],
        );
      },
    );
  }
}
