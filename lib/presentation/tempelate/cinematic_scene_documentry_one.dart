import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ----------------------------------------------------
/// DOCUMENTARY HISTORY – BLACK & GOLD TEMPLATE
/// ----------------------------------------------------
///
/// Uses:
/// - scene.title        -> Main documentary title / headline
/// - scene.subtitle     -> Era / category (e.g. "SANGAM ERA", "HISTORY FILES")
/// - scene.hook         -> Short poetic / hook line
/// - scene.body         -> Main narration paragraph
/// - scene.keyPoints    -> Bullet points (facts / highlights)
/// - scene.closureLine  -> Final punch / moral line
/// - imageUrl/localImageBytes -> Background (painting / art / map / landscape)
///
/// isPlaying == true  -> run intro animation
/// isPlaying == false -> freeze frame

class CinematicSceneDocumentryOne extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneDocumentryOne({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneDocumentryOne> createState() => _CinematicSceneDocumentryOneState();
}

class _CinematicSceneDocumentryOneState extends State<CinematicSceneDocumentryOne>
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

    // Slow zoom for background
    _zoom = Tween<double>(begin: 1.05, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Subtle diagonal pan
    _pan = Tween<Offset>(
      begin: const Offset(-0.015, -0.01),
      end: const Offset(0.015, 0.01),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Text fade + slide
    final textCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.7, curve: Curves.easeOut),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(textCurve);
    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.06),
      end: Offset.zero,
    ).animate(textCurve);

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CinematicSceneDocumentryOne oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        // restart if finished or never started
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
        : 'HISTORY FILES';

    final closingLine = scene.closureLine;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 1) Background with zoom + pan
            FractionalTranslation(
              translation: _pan.value,
              child: Transform.scale(
                scale: _zoom.value,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha:0.25),
                    BlendMode.darken,
                  ),
                  child: _buildBackground(scene),
                ),
              ),
            ),

            // 2) Vignette – black with slight golden tint
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.black.withValues(alpha:0.15),
                    Colors.black.withValues(alpha:0.9),
                  ],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),

            // 3) Top-left golden label
            Positioned(
              top: 18,
              left: 22,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFACC15), // amber 400
                          Color(0xFFB45309), // amber 800-ish
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.7),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.history_edu_rounded,
                          size: 14,
                          color: Colors.black,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'DOCUMENTARY',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha:0.7),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFFFACC15).withValues(alpha:0.6),
                        width: 0.7,
                      ),
                    ),
                    child: Text(
                      eraTag,
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.6,
                        color: Color(0xFFFDE68A), // light gold
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 4) Bottom-left main history panel
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 44),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: Colors.black.withValues(alpha:0.78),
                              border: Border.all(
                                color: const Color(0xFFFACC15).withValues(alpha:0.55),
                                width: 1.1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha:0.9),
                                  blurRadius: 26,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Small top accent line
                                Container(
                                  width: 52,
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

                                // Hook / poetic line
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

                                // Key points as facts list
                                if (scene.keyPoints.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: scene.keyPoints
                                        .map(
                                          (kp) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 4),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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

                                // Closure line – highlighted in gold
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
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 5) Tiny bottom-right year / chapter tag (optional from subtitle/body)
            Positioned(
              right: 20,
              bottom: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha:0.7),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFFACC15).withValues(alpha:0.5),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.auto_stories_rounded,
                      size: 13,
                      color: Color(0xFFFDE68A),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'CHAPTER OF TIME',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        color: Color(0xFFFDE68A),
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
