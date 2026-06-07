import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ----------------------------------------------------
/// NEWSPAPER / RETRO PRINT DOCUMENTARY TEMPLATE
/// (NO ASSETS, PURE FLUTTER)
/// ----------------------------------------------------

class CinematicSceneDocumentrySix extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneDocumentrySix({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneDocumentrySix> createState() =>
      _CinematicSceneDocumentrySixState();
}

class _CinematicSceneDocumentrySixState
    extends State<CinematicSceneDocumentrySix>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _zoom;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    // clamp() returns num, so cast to int for Duration
    final int seconds =
        widget.scene.durationSeconds.clamp(5, 120).toInt();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: seconds),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _zoom = Tween<double>(begin: 1.05, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CinematicSceneDocumentrySix oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      widget.isPlaying ? _controller.forward(from: 0) : _controller.stop();
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
    // Debug: see what type you’re actually getting (for web)
    // ✅ Only use memory image if it's a proper Uint8List and not empty
    if (scene.localImageBytes is Uint8List &&
        (scene.localImageBytes as Uint8List).isNotEmpty) {
      return Image.memory(
        scene.localImageBytes as Uint8List,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackBackground(),
      );
    }

    // Network image fallback
    if (scene.imageUrl.isNotEmpty) {
      return Image.network(
        scene.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
        errorBuilder: (_, __, ___) => _fallbackBackground(),
      );
    }

    // Final fallback
    return _fallbackBackground();
  }

  Widget _fallbackBackground() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: const Icon(
        Icons.article_rounded,
        size: 48,
        color: Colors.white70,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    final bodyText = scene.body;
    final editionTitle =
        scene.subtitle.isEmpty ? 'SPECIAL EDITION' : scene.subtitle.toUpperCase();

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1) Background desaturated + darkened (retro print feel)
              Transform.scale(
                scale: _zoom.value,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    // grayscale matrix
                    0.3, 0.3, 0.3, 0, 0,
                    0.3, 0.3, 0.3, 0, 0,
                    0.3, 0.3, 0.3, 0, 0,
                    0,   0,   0,   1, 0,
                  ]),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                    child: _buildBackground(scene),
                  ),
                ),
              ),

              // 2) Simple vignette (no texture asset)
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),

              // 3) Newspaper top strip title
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: FadeTransition(
                    opacity: _fade,
                    child: Text(
                      editionTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              // 4) Main headline (big newspaper title)
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 56),
                  child: FadeTransition(
                    opacity: _fade,
                    child: Text(
                      scene.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.15,
                        fontFamily: 'Georgia', // falls back if not available
                      ),
                    ),
                  ),
                ),
              ),

              // 5) Tagline / hook under headline
              if (scene.hook.isNotEmpty)
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 104),
                    child: FadeTransition(
                      opacity: _fade,
                      child: Text(
                        scene.hook,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),

              // 6) Bottom article column (like front-page story)
              FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 56),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.95),
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (bodyText.isNotEmpty)
                              Text(
                                bodyText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  fontFamily: 'Times New Roman',
                                  color: Colors.white,
                                ),
                              ),

                            if (scene.keyPoints.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: scene.keyPoints
                                    .map(
                                      (kp) => Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 4),
                                        child: Text(
                                          '• $kp',
                                          style: const TextStyle(
                                            fontSize: 14,
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
                              const Divider(
                                color: Colors.white30,
                                height: 1,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                scene.closureLine,
                                style: const TextStyle(
                                  fontSize: 15,
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
            ],
          ),
        );
      },
    );
  }
}
