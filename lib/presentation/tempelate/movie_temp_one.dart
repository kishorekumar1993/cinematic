import 'dart:ui';
import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// TOP 2025 MOVIE CINEMATIC TEMPLATE
/// ----------------------

class MovieTempOne extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const MovieTempOne({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<MovieTempOne> createState() => _MovieTempOneState();
}

class _MovieTempOneState extends State<MovieTempOne>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  late Animation<double> _scaleIn;
  late Animation<double> _shimmer;
  late Animation<double> _parallax;

  @override
  void initState() {
    super.initState();

    final duration = Duration(
      seconds: widget.scene.durationSeconds.clamp(5, 120),
    );

    _controller = AnimationController(vsync: this, duration: duration);

    // Fade in animation
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Slide up animation for text
    _slideUp = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // Scale in for badge
    _scaleIn = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    // Shimmer effect for gold accents
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // Subtle parallax for background
    _parallax = Tween<double>(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant MovieTempOne oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        if (!_controller.isAnimating) {
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

  Widget _buildBackground(SceneConfig scene) {
    if (scene.localImageBytes != null) {
      return Image.memory(
        scene.localImageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black,
                Colors.grey.shade900,
              ],
            ),
          ),
        ),
      );
    }

    if (scene.imageUrl.isNotEmpty) {
      return Image.network(
        scene.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black,
                Colors.grey.shade900,
              ],
            ),
          ),
        ),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(color: Colors.amber),
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black,
            Colors.grey.shade900,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // --- Background with parallax effect ---
            Transform.translate(
              offset: Offset(0, _parallax.value),
              child: Transform.scale(
                scale: 1.1,
                child: _buildBackground(scene),
              ),
            ),

            // --- Gradient overlays for cinematic look ---
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // --- Gold accent bars (top and bottom) ---
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.amber.shade600,
                      Colors.amber.shade400,
                      Colors.amber.shade600,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.amber.shade600,
                      Colors.amber.shade400,
                      Colors.amber.shade600,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // --- Top badge: "TOP 2025" ---
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _fadeIn.value,
                child: Transform.scale(
                  scale: _scaleIn.value,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade700,
                            Colors.amber.shade500,
                            Colors.amber.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.7),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Shimmer effect
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                  stops: [
                                    _shimmer.value - 0.3,
                                    _shimmer.value,
                                    _shimmer.value + 0.3,
                                  ],
                                ).createShader(bounds);
                              },
                              child: Container(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                scene.subtitle.isNotEmpty
                                    ? scene.subtitle.toUpperCase()
                                    : 'TOP 2025',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.5,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- Main content area ---
            Center(
              child: Opacity(
                opacity: _fadeIn.value,
                child: Transform.translate(
                  offset: Offset(0, _slideUp.value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Movie title
                          Text(
                            scene.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 46,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                              letterSpacing: 1.5,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                                Shadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                          ),

                          // Hook/Tagline
                          if (scene.hook.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.amber.shade600,
                                    width: 1.5,
                                  ),
                                  bottom: BorderSide(
                                    color: Colors.amber.shade600,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              child: Text(
                                scene.hook.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3.0,
                                  color: Colors.amber.shade200,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.7),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          // Body/Description
                          if (scene.body.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text(
                              scene.body,
                              textAlign: TextAlign.center,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.white.withOpacity(0.9),
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Key points as elegant chips
                          if (scene.keyPoints.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: scene.keyPoints
                                  .map(
                                    (kp) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.amber.shade800
                                                .withOpacity(0.3),
                                            Colors.amber.shade600
                                                .withOpacity(0.2),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.amber.shade700
                                              .withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        kp,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.amber.shade100,
                                          letterSpacing: 0.5,
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

            // --- Bottom info bar ---
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _fadeIn.value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Closure line / year
                      if (scene.closureLine.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.amber.shade700.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            scene.closureLine.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: Colors.amber.shade300,
                            ),
                          ),
                        ),

                      // Play status indicator
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.isPlaying
                                  ? Colors.amber.shade400
                                  : Colors.white54,
                              boxShadow: widget.isPlaying
                                  ? [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.6),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.isPlaying ? 'PLAYING' : 'PAUSED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Decorative corner frames ---
            Positioned(
              top: 20,
              left: 20,
              child: Opacity(
                opacity: _fadeIn.value * 0.6,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CustomPaint(
                    painter: CornerFramePainter(
                      color: Colors.amber.shade600,
                      isTopLeft: true,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Opacity(
                opacity: _fadeIn.value * 0.6,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CustomPaint(
                    painter: CornerFramePainter(
                      color: Colors.amber.shade600,
                      isTopRight: true,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: 20,
              child: Opacity(
                opacity: _fadeIn.value * 0.6,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CustomPaint(
                    painter: CornerFramePainter(
                      color: Colors.amber.shade600,
                      isBottomLeft: true,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              right: 20,
              child: Opacity(
                opacity: _fadeIn.value * 0.6,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CustomPaint(
                    painter: CornerFramePainter(
                      color: Colors.amber.shade600,
                      isBottomRight: true,
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

// --- Custom painter for elegant corner frames ---
class CornerFramePainter extends CustomPainter {
  final Color color;
  final bool isTopLeft;
  final bool isTopRight;
  final bool isBottomLeft;
  final bool isBottomRight;

  CornerFramePainter({
    required this.color,
    this.isTopLeft = false,
    this.isTopRight = false,
    this.isBottomLeft = false,
    this.isBottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final path = Path();

    if (isTopLeft) {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
    } else if (isTopRight) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (isBottomLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else if (isBottomRight) {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}