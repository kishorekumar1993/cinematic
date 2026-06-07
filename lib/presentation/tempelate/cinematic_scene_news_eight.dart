import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ----------------------------------------------------
/// CLEAN TOP HEADLINE NEWS TEMPLATE (CHANNEL BANNER STYLE)
/// ----------------------------------------------------
///
/// Uses:
/// - scene.title        -> Main headline
/// - scene.subtitle     -> Category / tag (e.g. "WORLD NEWS", "TAMIL NADU", "TECH")
//  - scene.hook         -> Small sub-headline
/// - scene.body         -> Description paragraph
/// - scene.keyPoints    -> Mini bullet tags
/// - scene.closureLine  -> Small highlight line under body
/// - scene.imageUrl / scene.localImageBytes -> Background
///
/// isPlaying == true  -> subtle zoom/pan + text anim
/// isPlaying == false -> static frame

class CinematicSceneNewsEigth extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneNewsEigth({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneNewsEigth> createState() => _CinematicSceneNewsEigthState();
}

class _CinematicSceneNewsEigthState extends State<CinematicSceneNewsEigth>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<Offset> _pan;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _badgePulse;

  @override
  void initState() {
    super.initState();

    final duration = Duration(
      seconds: widget.scene.durationSeconds.clamp(6, 60),
    );

    _controller = AnimationController(vsync: this, duration: duration);

    // Background zoom (subtle)
    _zoom = Tween<double>(begin: 1.02, end: 1.07).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // Slow horizontal pan
    _pan = Tween<Offset>(
      begin: const Offset(-0.02, 0.0),
      end: const Offset(0.02, 0.0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Text fade & slide
    final textCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.7, curve: Curves.easeOut),
    );

    _textFade = Tween<double>(begin: 0, end: 1).animate(textCurve);
    _textSlide = Tween<Offset>(
      begin: const Offset(0.05, 0.0),
      end: Offset.zero,
    ).animate(textCurve);

    // Top badge pulse
    _badgePulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant CinematicSceneNewsEigth oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        if (!_controller.isAnimating) {
          _controller.repeat(reverse: true);
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

    final subtitleTag =
        scene.subtitle.isNotEmpty ? scene.subtitle.toUpperCase() : 'TOP HEADLINE';

    final smallHighlight = scene.closureLine;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 1) Background with pan + zoom
            FractionalTranslation(
              translation: _pan.value,
              child: Transform.scale(
                scale: _zoom.value,
                child: _buildBackground(scene),
              ),
            ),

            // 2) Global vignette – center focus
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),

            // 3) Small top-center channel badge + tag
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Opacity(
                  opacity: _badgePulse.value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.black.withOpacity(0.55),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0EA5E9),
                                    Color(0xFF2563EB),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.public_rounded,
                                      size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'NEWS LIVE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      letterSpacing: 1.4,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              subtitleTag,
                              style: const TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.6,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 4) Main headline banner (bottom-center, wide)
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 46),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: Colors.black.withOpacity(0.65),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.22),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.85),
                                  blurRadius: 22,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row: small label + status
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
                                              Colors.white.withOpacity(0.25),
                                          width: 0.7,
                                        ),
                                      ),
                                      child: const Text(
                                        'HEADLINE',
                                        style: TextStyle(
                                          fontSize: 11,
                                          letterSpacing: 1.4,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
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
                                          widget.isPlaying
                                              ? 'LIVE'
                                              : 'PREVIEW',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white70,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Title (main headline)
                                Text(
                                  scene.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    height: 1.25,
                                    color: Colors.white,
                                  ),
                                ),

                                // Hook
                                if (scene.hook.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    scene.hook,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],

                                // Body
                                if (scene.body.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    scene.body,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      height: 1.4,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],

                                // Key points – small tags
                                if (scene.keyPoints.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: scene.keyPoints
                                        .map(
                                          (kp) => Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                              horizontal: 8,
                                              vertical: 3,
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
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],

                                // Small highlight line
                                if (smallHighlight.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  const Divider(
                                    height: 1,
                                    color: Colors.white24,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    smallHighlight,
                                    style: const TextStyle(
                                      fontSize: 12.5,
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
              ),
            ),
          ],
        );
      },
    );
  }
}
