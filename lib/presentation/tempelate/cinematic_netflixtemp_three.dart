import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ----------------------------------------------
/// FUTURISTIC TOP 5 TIMELINE TEMPLATE (YEAR 2025)
/// ----------------------------------------------
/// Mapping:
///   scene.title        -> Main heading ("Top 5 AI Tools in 2025")
///   scene.subtitle     -> Small tag ("AI • TOOLS")
///   scene.body         -> Short intro paragraph
///   scene.keyPoints    -> Up to 5 items (Top 5)
///   scene.closureLine  -> Bottom CTA / summary
///   scene.imageUrl / localImageBytes -> optional background
class CinematicNetflixTempThree extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicNetflixTempThree({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicNetflixTempThree> createState() =>
      _CinematicNetflixTempThreeState();
}

class _CinematicNetflixTempThreeState
    extends State<CinematicNetflixTempThree>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bgZoom;
  late Animation<double> _yearGlow;
  late Animation<double> _listFade;
  late Animation<Offset> _listSlide;

  @override
  void initState() {
    super.initState();

    final int seconds =
        widget.scene.durationSeconds.clamp(5, 120).toInt();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: seconds),
    );

    _bgZoom = Tween<double>(begin: 1.02, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _yearGlow = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _listFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.7, curve: Curves.easeOut),
    );

    _listSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant CinematicNetflixTempThree oldWidget) {
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
  // BACKGROUND
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF050816),
            Color(0xFF020308),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.timeline_rounded,
        size: 48,
        color: Colors.white70,
      ),
    );
  }

  // Small glowing dot for timeline
  Widget _timelineDot(int index, int total) {
    final t = (_controller.value + index * 0.15) % 1.0;
    final alpha = (0.4 + 0.6 * (1.0 - (t - 0.5).abs() * 2)).clamp(0.4, 1.0);

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.cyanAccent.withOpacity(alpha),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(alpha),
            blurRadius: 12,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    final List<String> items = (scene.keyPoints.isNotEmpty
            ? scene.keyPoints
            : scene.body.split('\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .take(5)
        .toList();

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 1) Background with slow zoom
            Transform.scale(
              scale: _bgZoom.value,
              child: _buildBackground(scene),
            ),

            // 2) Dark overlay with vignette
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xE6000000),
                    Color(0x00000000),
                  ],
                ),
              ),
            ),

            // 3) Left side: big 2025 pillar + timeline line
            Positioned(
              left: 24,
              top: 40,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // small tag above
                  if (scene.subtitle.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        scene.subtitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.5,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // big 2025 with glow
                  Opacity(
                    opacity: _yearGlow.value,
                    child: Text(
                      '2025',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: Colors.cyanAccent.withOpacity(0.9),
                        shadows: [
                          Shadow(
                            color: Colors.cyanAccent
                                .withOpacity(_yearGlow.value),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'TOP PICKS',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // vertical line + glowing dots
                  Expanded(
                    child: LayoutBuilder(
                      builder: (_, constraints) {
                        final total = items.isNotEmpty ? items.length : 5;
                        final gap = total > 1
                            ? (constraints.maxHeight - 20) / (total - 1)
                            : 0.0;

                        return Stack(
                          children: [
                            // vertical line
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(left: 5),
                                width: 2,
                                height: constraints.maxHeight,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.cyanAccent.withOpacity(0.4),
                                      Colors.purpleAccent.withOpacity(0.2),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // dots
                            for (int i = 0; i < total; i++)
                              Positioned(
                                left: 0,
                                top: i * gap,
                                child: _timelineDot(i, total),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 4) Right side: title + list in glass card
            FadeTransition(
              opacity: _listFade,
              child: SlideTransition(
                position: _listSlide,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(120, 32, 24, 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            padding:
                                const EdgeInsets.fromLTRB(20, 18, 20, 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: Colors.black.withOpacity(0.65),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.22),
                                width: 0.9,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withOpacity(0.85),
                                  blurRadius: 26,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // main title
                                Text(
                                  scene.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                    color: Colors.white,
                                  ),
                                ),

                                // hook / small line
                                if (scene.hook.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    scene.hook,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],

                                // intro body
                                if (scene.body.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    scene.body,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 14),

                                // list items
                                if (items.isNotEmpty)
                                  Column(
                                    children: List.generate(items.length,
                                        (index) {
                                      final rank = index + 1;
                                      final text = items[index];

                                      return Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 4),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // rank badge
                                            Container(
                                              width: 28,
                                              height: 28,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient:
                                                    const LinearGradient(
                                                  colors: [
                                                    Color(0xFF22C55E),
                                                    Color(0xFF22D3EE),
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        Colors.black.withOpacity(
                                                            0.6),
                                                    blurRadius: 10,
                                                    offset:
                                                        const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                '$rank',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            // text
                                            Expanded(
                                              child: Text(
                                                text,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  height: 1.35,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
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

            // 5) Bottom closure line
            if (scene.closureLine.isNotEmpty)
              Positioned(
                left: 24,
                right: 24,
                bottom: 20,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 0.7,
                      ),
                    ),
                    child: Text(
                      scene.closureLine,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
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
