import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ----------------------------------------------------
/// HISTORY DOCUMENTARY – ARCHIVE PAPER TEMPLATE
/// ----------------------------------------------------
///
/// Uses:
/// - scene.title        -> Main documentary title
/// - scene.subtitle     -> Era / theme (e.g. "SANGAM ERA", "TAMIL HISTORY")
/// - scene.hook         -> Short poetic / hook line
/// - scene.body         -> Main narration paragraph
/// - scene.keyPoints    -> Bullet facts
/// - scene.closureLine  -> Final line / moral
/// - scene.imageUrl / scene.localImageBytes -> Background art / landscape
///
/// isPlaying == true  -> one-time intro animation
/// isPlaying == false -> static frame

class CinematicSceneDocumentryThree extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneDocumentryThree({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneDocumentryThree> createState() => _CinematicSceneDocumentryThreeState();
}

class _CinematicSceneDocumentryThreeState extends State<CinematicSceneDocumentryThree>
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

    // Background slow zoom + gentle pan
    _zoom = Tween<double>(begin: 1.03, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _pan = Tween<Offset>(
      begin: const Offset(-0.015, -0.01),
      end: const Offset(0.015, 0.01),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Text fade + slide
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
  void didUpdateWidget(covariant CinematicSceneDocumentryThree oldWidget) {
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
        : 'HISTORY DOCUMENTARY';

    final closingLine = scene.closureLine;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 1) Background with zoom + pan + slight desaturate/darken
            FractionalTranslation(
              translation: _pan.value,
              child: Transform.scale(
                scale: _zoom.value,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha:0.35),
                    BlendMode.darken,
                  ),
                  child: _buildBackground(scene),
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
                    Colors.black.withValues(alpha:0.15),
                    Colors.black.withValues(alpha:0.9),
                  ],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),

            // 3) Top-left simple label
            Positioned(
              top: 18,
              left: 22,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha:0.8),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha:0.3),
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

            // 4) Center-left document card
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 40, 26, 48),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              // Parchment-style neutral paper
                              color: const Color(0xFFFAF4E8).withValues(alpha:0.96),
                              border: Border.all(
                                color: const Color(0xFFB0A28E),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha:0.7),
                                  blurRadius: 22,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: _buildDocumentContent(scene, closingLine),
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

  Widget _buildDocumentContent(SceneConfig scene, String closingLine) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Small heading row
        Row(
          children: [
            Container(
              width: 40,
              height: 2,
              color: const Color(0xFF8B6A4A),
            ),
            const SizedBox(width: 8),
            const Text(
              'ARCHIVE RECORD',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.3,
                color: Color(0xFF8B6A4A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Title
        Text(
          scene.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.3,
            color: Color(0xFF1F2933),
          ),
        ),

        // Hook
        if (scene.hook.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            scene.hook,
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Color(0xFF6B4F3A),
            ),
          ),
        ],

        // Body
        if (scene.body.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            scene.body,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.55,
              color: Color(0xFF3F3D3A),
            ),
          ),
        ],

        // Bullet points
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
                            color: Color(0xFF6B4F3A),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            kp,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.4,
                              color: Color(0xFF3F3D3A),
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
          Container(
            width: double.infinity,
            height: 0.8,
            color: const Color(0xFFB0A28E),
          ),
          const SizedBox(height: 6),
          Text(
            closingLine,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5A4331),
            ),
          ),
        ],
      ],
    );
  }
}
