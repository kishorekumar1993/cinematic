import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ----------------------------------------------------
/// RICH PRIME-TIME NEWS TEMPLATE (TOP STORY STYLE)
/// ----------------------------------------------------

class CinematicSceneNewsFour extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneNewsFour({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneNewsFour> createState() => _CinematicSceneNewsFourState();
}

class _CinematicSceneNewsFourState extends State<CinematicSceneNewsFour>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<Offset> _pan;
  late Animation<double> _tickerSlide; // FIXED ✔️

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

    // Subtle pan
    _pan = Tween<Offset>(
      begin: const Offset(-0.02, 0.0),
      end: const Offset(0.02, 0.0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Text animation
    final textCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(textCurve);
    _textSlide = Tween<Offset>(
      begin: const Offset(0.08, 0.0),
      end: Offset.zero,
    ).animate(textCurve);

    // ✔️ FIXED ticker animation
    _tickerSlide = Tween<double>(begin: 1.0, end: -1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CinematicSceneNewsFour oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        if (_controller.isDismissed) {
          _controller.forward();
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

  /// Build Background image (network / asset / fallback)
  Widget _buildBackground(SceneConfig scene) {
    if (scene.localImageBytes != null) {
      return Image.memory(scene.localImageBytes!, fit: BoxFit.cover);
    }
    if (scene.imageUrl.isNotEmpty) {
      return Image.network(scene.imageUrl, fit: BoxFit.cover);
    }
    return Container(color: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    final tickerText =
        scene.closureLine.isNotEmpty ? scene.closureLine : scene.title;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            /// BACKGROUND MOVEMENT
            FractionalTranslation(
              translation: _pan.value,
              child: Transform.scale(
                scale: _zoom.value,
                child: _buildBackground(scene),
              ),
            ),

            /// RIGHT HIGHLIGHT OVERLAY
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.55,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Color(0xE600111F),
                      Color(0x9900111F),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            /// TOP LEFT BADGE
            Positioned(
              top: 14,
              left: 16,
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0EA5E9),
                          Color(0xFF2563EB),
                        ],
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.tv_rounded,
                            size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'PRIME NEWS',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (scene.subtitle.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha:0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        scene.subtitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.6,
                          color: Colors.white70,
                        ),
                      ),
                    )
                  ]
                ],
              ),
            ),

            /// RIGHT PANEL GLASS CARD
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 52),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            color: Colors.black.withValues(alpha:0.55),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: const [
                                    Text(
                                      'TOP STORY',
                                      style: TextStyle(
                                        fontSize: 11,
                                        letterSpacing: 1.5,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'LIVE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.greenAccent,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),

                                /// TITLE
                                Text(
                                  scene.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),

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

                                if (scene.keyPoints.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: scene.keyPoints
                                        .map(
                                          (kp) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withValues(alpha:0.06),
                                              borderRadius:
                                                  BorderRadius.circular(999),
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

            /// BOTTOM TICKER BAR FIXED ✔️
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 34,
                width: double.infinity,
                color: const Color(0xFF1D4ED8),
                child: ClipRect(
                  child: FractionalTranslation(
                    translation: Offset(_tickerSlide.value, 0),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Text(
                          tickerText,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 32),
                        Text(
                          tickerText,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
