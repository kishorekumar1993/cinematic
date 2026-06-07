import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ----------------------------------------------------
/// STATS / BULLETIN NEWS TEMPLATE (GENERIC, NOT HARDCODED)
/// ----------------------------------------------------
///
/// Uses:
/// - scene.title        -> Main headline
/// - scene.subtitle     -> Main tag (top-left & info chips)
/// - scene.hook         -> Short sub-head
/// - scene.body         -> Description
/// - scene.keyPoints    -> Right-side list items
/// - scene.closureLine  -> Bottom strapline
/// - imageUrl/localImageBytes -> Background
///

class CinematicSceneNewsSeven extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneNewsSeven({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneNewsSeven> createState() => _CinematicSceneNewsSevenState();
}

class _CinematicSceneNewsSevenState extends State<CinematicSceneNewsSeven>
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
      seconds: widget.scene.durationSeconds.clamp(6, 60),
    );

    _controller = AnimationController(vsync: this, duration: duration);

    _zoom = Tween<double>(begin: 1.02, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _pan = Tween<Offset>(
      begin: const Offset(-0.015, -0.01),
      end: const Offset(0.015, 0.01),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    final textCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.7, curve: Curves.easeOut),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(textCurve);
    _textSlide = Tween<Offset>(
      begin: const Offset(0.06, 0.0),
      end: Offset.zero,
    ).animate(textCurve);

    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant CinematicSceneNewsSeven oldWidget) {
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

    // 🔁 No hardcoded "ELECTION DESK" now
    final mainTag =
        scene.subtitle.isNotEmpty ? scene.subtitle.toUpperCase() : 'NEWS DESK';

    final strapline = scene.closureLine.isNotEmpty
        ? scene.closureLine
        : (scene.body.isNotEmpty ? scene.body : scene.title);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // BG with pan+zoom
            FractionalTranslation(
              translation: _pan.value,
              child: Transform.scale(
                scale: _zoom.value,
                child: _buildBackground(scene),
              ),
            ),

            // Vignette + bottom focus
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    Colors.black.withOpacity(0.08),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 240,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xFF000000),
                      Color(0x88000000),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // TOP-LEFT TAG (DYNAMIC)
            Positioned(
              top: 14,
              left: 16,
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
                          Color(0xFF22C55E),
                          Color(0xFF16A34A),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.7),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.assessment_rounded,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          mainTag, // ← dynamic, from subtitle / fallback
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // MAIN CONTENT ROW
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 60, 22, 80),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT: Headline + body
                      Expanded(
                        flex: 3,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(18, 16, 18, 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.black.withOpacity(0.55),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.18),
                                    width: 0.9,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF22C55E),
                                                Color(0xFFEAB308),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'LIVE UPDATE', // generic, not election-only
                                          style: TextStyle(
                                            fontSize: 11,
                                            letterSpacing: 1.4,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    Text(
                                      scene.title,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        height: 1.2,
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // RIGHT: list / stats panel – generic "DETAILS"
                      Expanded(
                        flex: 2,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 340),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(14, 12, 14, 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: Colors.black.withOpacity(0.65),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.22),
                                    width: 0.9,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.list_rounded,
                                          size: 16,
                                          color: Colors.white70,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'DETAILS',
                                          style: TextStyle(
                                            fontSize: 12,
                                            letterSpacing: 1.2,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    if (scene.keyPoints.isEmpty)
                                      const Text(
                                        'No detailed list items provided.',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Colors.white54,
                                        ),
                                      )
                                    else
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: scene.keyPoints
                                            .map((kp) => _buildDetailRow(kp))
                                            .toList(),
                                      ),
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

            // BOTTOM STRAPLINE
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 36,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF111827),
                      Color(0xFF020617),
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_right_alt_rounded,
                      size: 18,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
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

  Widget _buildDetailRow(String text) {
    final parts = text.split(RegExp(r'[-–]'));
    String label = text;
    String? value;
    if (parts.length >= 2) {
      label = parts[0].trim();
      value = parts.sublist(1).join('-').trim();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ),
          if (value != null && value.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 0.7,
                ),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
