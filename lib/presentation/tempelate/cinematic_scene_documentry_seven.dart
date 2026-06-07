import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ----------------------------------------------------
/// CRIME FILE / RED MARKER DOCUMENTARY TEMPLATE
/// (NO ASSETS, PURE FLUTTER)
/// ----------------------------------------------------
///
/// SceneConfig mapping:
/// - title        -> Case headline (e.g. "வேள் பாரி கொலை சதி?") / main story
/// - subtitle     -> Case ID / location / year (e.g. "CASE #1975 · CHENNAI")
/// - hook         -> Short hook / question line
/// - body         -> Main narration
/// - keyPoints    -> Key evidence points (bullets)
/// - closureLine  -> Final punch line / conclusion
/// - imageUrl / localImageBytes -> Background ref image
///
/// isPlaying == true  -> animation plays
/// isPlaying == false -> static frame
///

class CinematicSceneDocumentrySeven extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneDocumentrySeven({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneDocumentrySeven> createState() => _CinematicSceneDocumentrySevenState();
}

class _CinematicSceneDocumentrySevenState extends State<CinematicSceneDocumentrySeven>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _zoom;
  late Animation<Offset> _slide;

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

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _zoom = Tween<double>(begin: 1.04, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0.0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CinematicSceneDocumentrySeven oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _controller.forward(from: 0);
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
  // BACKGROUND IMAGE
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

    return _fallbackBackground();
  }

  Widget _fallbackBackground() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: const Icon(
        Icons.folder_shared_rounded,
        size: 48,
        color: Colors.white70,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    final caseSubtitle = scene.subtitle.isNotEmpty
        ? scene.subtitle
        : 'UNSOLVED CASE FILE';

    final closure = scene.closureLine;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 1) Background: desaturated + dark crime mood
            Transform.scale(
              scale: _zoom.value,
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  // grayscale
                  0.3, 0.3, 0.3, 0, 0,
                  0.3, 0.3, 0.3, 0, 0,
                  0.3, 0.3, 0.3, 0, 0,
                  0,   0,   0,   1, 0,
                ]),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha:0.45),
                    BlendMode.darken,
                  ),
                  child: _buildBackground(scene),
                ),
              ),
            ),

            // 2) Vignette + slight spotlight towards left
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.4, -0.1),
                  radius: 0.9,
                  colors: [
                    Colors.white.withValues(alpha:0.05),
                    Colors.black.withValues(alpha:0.85),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),

            // 3) Top-left CASE FILE label
            Positioned(
              top: 18,
              left: 18,
              child: FadeTransition(
                opacity: _fade,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade900.withValues(alpha:0.6),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'CASE FILE',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 2,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha:0.8),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.white24,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        caseSubtitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.6,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4) Main CASE FILE card (like a manila folder page)
            FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 56),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Stack(
                        children: [
                          // Folder shadow layer
                          Transform.translate(
                            offset: const Offset(10, 10),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black.withValues(alpha:0.6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha:0.9),
                                    blurRadius: 20,
                                    offset: const Offset(0, 18),
                                  ),
                                ],
                              ),
                              height: null,
                            ),
                          ),
                          // Folder page
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEE5D5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFB19A7A),
                                width: 1.0,
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                            child: _buildCaseContent(scene, closure),
                          ),

                          // Red marker strip (top-right corner, like evidence tape)
                          Positioned(
                            right: 10,
                            top: -4,
                            child: Transform.rotate(
                              angle: -0.12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade800,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.shade900
                                          .withValues(alpha:0.7),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'CONFIDENTIAL',
                                  style: TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 1.8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
              ),
            ),

            // 5) Bottom-right small "EVIDENCE LOG" tag
            Positioned(
              right: 18,
              bottom: 20,
              child: FadeTransition(
                opacity: _fade,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha:0.85),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.red.shade500,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.fingerprint_rounded,
                        size: 13,
                        color: Colors.white70,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'EVIDENCE LOG',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCaseContent(SceneConfig scene, String closure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top casecode row
        Row(
          children: [
            Container(
              width: 36,
              height: 2,
              color: const Color(0xFF8C5A3B),
            ),
            const SizedBox(width: 8),
            const Text(
              'CASE SUMMARY',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.3,
                color: Color(0xFF6B4A32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Title like a file heading
        Text(
          scene.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1.3,
            color: Color(0xFF2B2118),
          ),
        ),

        // Hook line
        if (scene.hook.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            scene.hook,
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Color(0xFF5B4130),
            ),
          ),
        ],

        // Main body
        if (scene.body.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            scene.body,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.5,
              color: Color(0xFF3A2F26),
            ),
          ),
        ],

        // Evidence points
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
                        // red dash bullet like marker
                        const Text(
                          '– ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            kp,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.4,
                              color: Color(0xFF3A2F26),
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

        // Closure line in red ink style
        if (closure.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 0.8,
            color: const Color(0xFFB19A7A),
          ),
          const SizedBox(height: 5),
          Text(
            closure,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB91C1C), // dark red
            ),
          ),
        ],
      ],
    );
  }
}
