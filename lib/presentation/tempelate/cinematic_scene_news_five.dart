import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ----------------------------------------------------
/// STUDIO SPECIAL REPORT TEMPLATE
/// ----------------------------------------------------
///
/// Uses:
/// - scene.title        -> Main headline
/// - scene.subtitle     -> Vertical banner text (left)
/// - scene.hook         -> Sub-headline line
/// - scene.body         -> Paragraph description
/// - scene.keyPoints    -> Tag bullets
/// - scene.closureLine  -> Bottom strapline text
/// - imageUrl/localImageBytes -> Background
///
/// isPlaying controls animations (zoom/pan/text)

class CinematicSceneNewsFive extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneNewsFive({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneNewsFive> createState() => _CinematicSceneNewsFiveState();
}

class _CinematicSceneNewsFiveState extends State<CinematicSceneNewsFive>
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

    _controller = AnimationController(vsync: this, duration: duration);

    // Background zoom
    _zoom = Tween<double>(begin: 1.02, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // Subtle side pan
    _pan = Tween<Offset>(
      begin: const Offset(-0.015, 0.0),
      end: const Offset(0.015, 0.0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Text animation
    final textCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.7, curve: Curves.easeOut),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(textCurve);
    _textSlide = Tween<Offset>(
      begin: const Offset(0.08, 0.0),
      end: Offset.zero,
    ).animate(textCurve);

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CinematicSceneNewsFive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        if (_controller.isDismissed) {
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
    final strapline = scene.closureLine.isNotEmpty
        ? scene.closureLine
        : (scene.subtitle.isNotEmpty ? scene.subtitle : scene.title);

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
                child: _buildBackground(scene),
              ),
            ),

            // 2) Global dark vignette
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),

            // 3) Left vertical category banner
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  width: 80,
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFEF4444),
                        Color(0xFFEAB308),
                        Color(0xFF22C55E),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.8),
                        blurRadius: 20,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Inner glossy overlay
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.25),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Vertical text
                      Center(
                        child: RotatedBox(
                          quarterTurns: -1,
                          child: Text(
                            scene.subtitle.isNotEmpty
                                ? scene.subtitle.toUpperCase()
                                : 'SPECIAL REPORT',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4) Top-right small status chip
            Positioned(
              top: 16,
              right: 18,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 0.7,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isPlaying
                            ? Colors.greenAccent
                            : Colors.white60,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isPlaying ? 'LIVE STUDIO' : 'PREVIEW',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5) Right glass studio panel with main content
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 54),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: Colors.black.withOpacity(0.55),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.22),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.85),
                                  blurRadius: 26,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Small label + time/status
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        color:
                                            Colors.white.withOpacity(0.08),
                                        border: Border.all(
                                          color:
                                              Colors.white.withOpacity(0.22),
                                          width: 0.7,
                                        ),
                                      ),
                                      child: const Text(
                                        'STUDIO DESK',
                                        style: TextStyle(
                                          fontSize: 11,
                                          letterSpacing: 1.4,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      scene.subtitle.isNotEmpty
                                          ? scene.subtitle
                                          : '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Headline title
                                Text(
                                  scene.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    height: 1.25,
                                    color: Colors.white,
                                  ),
                                ),

                                // Hook / short line
                                if (scene.hook.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    scene.hook,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],

                                // Body description
                                if (scene.body.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    scene.body,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.45,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],

                                // Key point tags
                                if (scene.keyPoints.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: scene.keyPoints
                                        .map(
                                          (kp) => Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.06),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                width: 0.6,
                                              ),
                                            ),
                                            child: Text(
                                              kp,
                                              style: const TextStyle(
                                                fontSize: 12.5,
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
                    ),
                  ),
                ),
              ),
            ),

            // 6) Bottom strapline bar
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 34,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF111827),
                      Color(0xFF1F2937),
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.article_rounded,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strapline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
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
