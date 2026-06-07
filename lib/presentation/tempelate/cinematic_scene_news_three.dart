import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ----------------------------------------------------
/// RICH BREAKING NEWS CINEMATIC TEMPLATE (TV CHANNEL STYLE)
/// ----------------------------------------------------
class CinematicSceneNewsThree extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneNewsThree({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneNewsThree> createState() =>
      _CinematicSceneNewsThreeState();
}

class _CinematicSceneNewsThreeState extends State<CinematicSceneNewsThree>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;
  late Animation<double> _tickerSlide;
  late Animation<double> _zoom;

  @override
  void initState() {
    super.initState();

    // Make sure seconds is an int between 5 and 120
    final int seconds =
        widget.scene.durationSeconds.clamp(5, 120).toInt();

    final duration = Duration(seconds: seconds);

    _controller = AnimationController(vsync: this, duration: duration);

    // Pulse for BREAKING area + subtle glow
    _pulse = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Slow zoom for background
    _zoom = Tween<double>(begin: 1.02, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // Ticker slide from right to left
    _tickerSlide = Tween<double>(begin: 1.0, end: -1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CinematicSceneNewsThree oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        if (!_controller.isAnimating) {
          _controller.repeat();
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
    // 🔍 Debug: see what type is coming in
    // (you can remove this after testing)
    debugPrint('localImageBytes type = ${scene.localImageBytes?.runtimeType}');

    // ✅ Only use memory image if it's a proper Uint8List and not empty
    if (scene.localImageBytes is Uint8List &&
        (scene.localImageBytes as Uint8List).isNotEmpty) {
      return Image.memory(
        scene.localImageBytes as Uint8List,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, size: 48, color: Colors.white),
        ),
      );
    }

    // Fallback to network image if URL is provided
    if (scene.imageUrl.isNotEmpty) {
      return Image.network(
        scene.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, size: 48, color: Colors.white),
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

    // Final fallback
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

    final tickerText = (scene.closureLine.isNotEmpty
            ? scene.closureLine
            : (scene.body.isNotEmpty ? scene.body : scene.title))
        .replaceAll('\n', '   •   ');

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // If not playing, keep ticker fixed in place (no slide)
        final double tickerOffsetX =
            widget.isPlaying ? _tickerSlide.value : 0.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1) Background with slow zoom
            Transform.scale(
              scale: _zoom.value,
              child: _buildBackground(scene),
            ),

            // 2) Rich overlay: radial vignette + bottom gradient
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    Colors.black.withValues(alpha:0.05),
                    Colors.black.withValues(alpha:0.85),
                  ],
                  stops: const [0.25, 1.0],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFF000000),
                    Color(0x99000000),
                    Color(0x00000000),
                  ],
                ),
              ),
            ),

            // 3) Top glass BREAKING bar
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade900.withValues(alpha:0.85 * _pulse.value),
                            Colors.red.shade700.withValues(alpha:0.85),
                            Colors.red.shade500.withValues(alpha:0.9),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha:0.18),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha:0.45 * _pulse.value),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          // Logo / Channel tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'BREAKING',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.6,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Subtitle as context / category
                          Expanded(
                            child: Text(
                              scene.subtitle.isNotEmpty
                                  ? scene.subtitle.toUpperCase()
                                  : 'LIVE BREAKING NEWS UPDATE',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Time + Status pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha:0.25),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha:0.25),
                                width: 0.6,
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
                                        : Colors.white70,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.isPlaying ? 'ON AIR' : 'PAUSED',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                    letterSpacing: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 4) Center glass headline panel
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: Colors.black.withValues(alpha:0.55),
                          border: Border.all(
                            color: Colors.white.withValues(alpha:0.22),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.8),
                              blurRadius: 26,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Small top accent bar
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 46,
                                height: 3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFF97316),
                                      Color(0xFFEF4444),
                                      Color(0xFFEAB308),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Title (headline)
                            Text(
                              scene.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                                color: Colors.white,
                              ),
                            ),

                            // Hook – sub-head
                            if (scene.hook.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                scene.hook,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                              ),
                            ],

                            // Body – smaller details
                            if (scene.body.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                scene.body,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  height: 1.45,
                                  color: Colors.white70,
                                ),
                              ),
                            ],

                            // Key points – tags row
                            if (scene.keyPoints.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                alignment: WrapAlignment.center,
                                children: scene.keyPoints
                                    .map(
                                      (kp) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha:0.06),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha:0.2),
                                            width: 0.7,
                                          ),
                                        ),
                                        child: Text(
                                          kp,
                                          style: const TextStyle(
                                            fontSize: 13,
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

            // 5) Dual-layer bottom bar: info strip + ticker
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Upper info strip over ticker (glass)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          height: 32,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black.withValues(alpha:0.55),
                            border: Border.all(
                              color: Colors.white.withValues(alpha:0.2),
                              width: 0.6,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.public_rounded,
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  scene.subtitle.isNotEmpty
                                      ? scene.subtitle
                                      : 'Top Story • Live Coverage',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom ticker bar
                  Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade900,
                          Colors.red.shade700,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.7),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ClipRect(
                      child: Stack(
                        children: [
                          FractionalTranslation(
                            translation: Offset(tickerOffsetX, 0),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Text(
                                  tickerText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 32),
                                Text(
                                  tickerText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 6) LIVE + channel tag (bottom-left, floating)
            Positioned(
              left: 22,
              bottom: 54,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha:0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.circle, size: 10, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha:0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha:0.25),
                        width: 0.7,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.tv_rounded,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.isPlaying
                              ? 'NEWSCAST RUNNING'
                              : 'PREVIEW MODE',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
