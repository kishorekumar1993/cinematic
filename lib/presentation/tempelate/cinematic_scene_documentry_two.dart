import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ----------------------------------------------------
/// DOCUMENTARY HISTORY – MINIMAL BLACK & GOLD TEMPLATE
/// ----------------------------------------------------
///
/// Uses:
/// - scene.title        -> Main doc title
/// - scene.subtitle     -> Era / theme (e.g. "SANGAM ERA", "TAMIL HISTORY")
/// - scene.hook         -> Short poetic / hook line
/// - scene.body         -> Main narration paragraph
/// - scene.keyPoints    -> Bullet list of facts
/// - scene.closureLine  -> Final punch line / moral
/// - imageUrl/localImageBytes -> Background art / landscape
///
/// isPlaying == true  -> one-time intro animation
/// isPlaying == false -> static frame

class CinematicSceneDocumentryTwo extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneDocumentryTwo({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneDocumentryTwo> createState() => _CinematicSceneDocumentryTwoState();
}

class _CinematicSceneDocumentryTwoState extends State<CinematicSceneDocumentryTwo>
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
      seconds: widget.scene.durationSeconds.clamp(5, 90),
    );

    _controller = AnimationController(
      vsync: this,
      duration: duration,
    );

    // Background: slow zoom & slight pan
    _zoom = Tween<double>(begin: 1.04, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _pan = Tween<Offset>(
      begin: const Offset(-0.015, -0.01),
      end: const Offset(0.015, 0.01),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Text: fade & slide up
    final textCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.8, curve: Curves.easeOut),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(textCurve);
    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(textCurve);

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CinematicSceneDocumentryTwo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        if (_controller.isCompleted || _controller.isDismissed) {
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

  // -------------------------
  // BACKGROUND IMAGE BUILDER
  // -------------------------
  Widget _buildBackground(SceneConfig scene) {
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

    final eraTag = scene.subtitle.isNotEmpty
        ? scene.subtitle.toUpperCase()
        : 'DOCUMENTARY HISTORY';

    final closingLine = scene.closureLine;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 1) Background sepia-toned with zoom + pan + darken
            FractionalTranslation(
              translation: _pan.value,
              child: Transform.scale(
                scale: _zoom.value,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    // sepia
                    0.393, 0.769, 0.189, 0, 0,
                    0.349, 0.686, 0.168, 0, 0,
                    0.272, 0.534, 0.131, 0, 0,
                    0,     0,     0,     1, 0,
                  ]),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.28),
                      BlendMode.darken,
                    ),
                    child: _buildBackground(scene),
                  ),
                ),
              ),
            ),

            // 2) Vignette
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.black.withOpacity(0.18),
                    Colors.black.withOpacity(0.92),
                  ],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),

            // 3) Top-center small label
            Positioned(
              top: 18,
              left: 0,
              right: 0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.black.withOpacity(0.75),
                        border: Border.all(
                          color: const Color(0xFFFACC15).withOpacity(0.7),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.history_edu_rounded,
                            size: 14,
                            color: Color(0xFFFDE68A),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            eraTag,
                            style: const TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.6,
                              color: Color(0xFFFDE68A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 4) Center card with golden frame
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 780),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: Colors.black.withOpacity(0.82),
                              border: Border.all(
                                color: const Color(0xFFFACC15).withOpacity(0.6),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.9),
                                  blurRadius: 26,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: _buildContent(scene, closingLine),
                          ),
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

  Widget _buildContent(SceneConfig scene, String closingLine) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Small decorative line
        Container(
          width: 54,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFACC15),
                Color(0xFFEAB308),
                Color(0xFFA16207),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Title
        Text(
          scene.title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.25,
            color: Colors.white,
          ),
        ),

        // Hook line
        if (scene.hook.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            scene.hook,
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Color(0xFFFDE68A),
            ),
          ),
        ],

        // Body narration
        if (scene.body.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            scene.body,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.5,
              color: Colors.white70,
            ),
          ),
        ],

        // Key facts
        if (scene.keyPoints.isNotEmpty) ...[
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: scene.keyPoints
                .map(
                  (kp) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFFFDE68A),
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

        // Closing line
        if (closingLine.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            color: Colors.white24,
          ),
          const SizedBox(height: 6),
          Text(
            closingLine,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFACC15),
            ),
          ),
        ],
      ],
    );
  }
}
