import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// TOP 5 RANKING CINEMATIC TEMPLATE
/// For Movies, Jobs, Vehicles, Products, etc.
/// ----------------------

class CinematicSceneTopFiveRankingOne extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneTopFiveRankingOne({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneTopFiveRankingOne> createState() =>
      _CinematicSceneTopFiveRankingOneState();
}

class _CinematicSceneTopFiveRankingOneState extends State<CinematicSceneTopFiveRankingOne>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideIn;
  late Animation<double> _scaleRank;
  late Animation<double> _glow;
  late Animation<double> _countUp;
  late Animation<double> _shimmer;

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
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Slide in from bottom
    _slideIn = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // Scale rank number
    _scaleRank = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Pulsing glow effect
    _glow = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Count up effect for rank
    _countUp = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    // Shimmer effect
    _shimmer = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CinematicSceneTopFiveRankingOne oldWidget) {
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
                Colors.indigo.shade900,
                Colors.purple.shade900,
                Colors.black,
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
                Colors.indigo.shade900,
                Colors.purple.shade900,
                Colors.black,
              ],
            ),
          ),
        ),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(color: Colors.purple),
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
            Colors.indigo.shade900,
            Colors.purple.shade900,
            Colors.black,
          ],
        ),
      ),
    );
  }

  // Extract rank number from title or use subtitle
  String _extractRankNumber() {
    // Try to find #1, #2, etc. in title
    final RegExp rankPattern = RegExp(r'#?(\d+)');
    final match = rankPattern.firstMatch(widget.scene.title);
    if (match != null) {
      return match.group(1) ?? '1';
    }
    
    // Check subtitle
    final matchSubtitle = rankPattern.firstMatch(widget.scene.subtitle);
    if (matchSubtitle != null) {
      return matchSubtitle.group(1) ?? '1';
    }
    
    return '1';
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey.shade300; // Silver
      case 3:
        return Colors.orange.shade700; // Bronze
      default:
        return Colors.cyan; // Others
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
        return Icons.military_tech; // Medal
      case 3:
        return Icons.workspace_premium; // Badge
      default:
        return Icons.star; // Star
    }
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    final rankString = _extractRankNumber();
    final rank = int.tryParse(rankString) ?? 1;
    final rankColor = _getRankColor(rank);
    final animatedRank = (_countUp.value * rank).round();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // --- Background ---
            Transform.scale(
              scale: 1.05,
              child: _buildBackground(scene),
            ),

            // --- Dark gradient overlay ---
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha:0.7),
                    Colors.black.withValues(alpha:0.4),
                    Colors.black.withValues(alpha:0.85),
                  ],
                ),
              ),
            ),

            // --- Animated grid pattern ---
            Opacity(
              opacity: 0.1 * _fadeIn.value,
              child: CustomPaint(
                size: Size.infinite,
                painter: GridPatternPainter(),
              ),
            ),

            // --- Top badge: "TOP 5 2025" ---
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _fadeIn.value,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade700,
                          Colors.indigo.shade600,
                          Colors.purple.shade700,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha:0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha:0.6),
                          blurRadius: 25,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 22,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha:0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Text(
                          scene.subtitle.isNotEmpty
                              ? scene.subtitle.toUpperCase()
                              : 'TOP 5 • 2025',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha:0.5),
                                blurRadius: 4,
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

            // --- Main content area ---
            Center(
              child: Opacity(
                opacity: _fadeIn.value,
                child: Transform.translate(
                  offset: Offset(0, _slideIn.value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // --- Large Rank Number with icon ---
                          Transform.scale(
                            scale: _scaleRank.value,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    rankColor.withValues(alpha:0.8),
                                    rankColor.withValues(alpha:0.3),
                                  ],
                                ),
                                border: Border.all(
                                  color: rankColor,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: rankColor.withValues(alpha:_glow.value),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha:0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Shimmer effect
                                  ClipOval(
                                    child: ShaderMask(
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withValues(alpha:0.0),
                                            Colors.white.withValues(alpha:0.3),
                                            Colors.white.withValues(alpha:0.0),
                                          ],
                                          stops: [
                                            (_shimmer.value - 0.3).clamp(0.0, 1.0),
                                            _shimmer.value.clamp(0.0, 1.0),
                                            (_shimmer.value + 0.3).clamp(0.0, 1.0),
                                          ],
                                        ).createShader(bounds);
                                      },
                                      child: Container(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '#$animatedRank',
                                        style: TextStyle(
                                          fontSize: 72,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          height: 1.0,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(alpha:0.7),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Icon(
                                        _getRankIcon(rank),
                                        size: 32,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(alpha:0.7),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 40),

                          // --- Title and details ---
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Title
                                Text(
                                  scene.title,
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha:0.8),
                                        blurRadius: 15,
                                        offset: const Offset(0, 4),
                                      ),
                                      Shadow(
                                        color: rankColor.withValues(alpha:0.4),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),

                                // Hook
                                if (scene.hook.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: rankColor.withValues(alpha:0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: rankColor.withValues(alpha:0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      scene.hook.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                        color: rankColor.withValues(alpha:0.9),
                                      ),
                                    ),
                                  ),
                                ],

                                // Body
                                if (scene.body.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    scene.body,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      color: Colors.white.withValues(alpha:0.85),
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(alpha:0.8),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                // Key points as feature tags
                                if (scene.keyPoints.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: scene.keyPoints
                                        .map(
                                          (kp) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withValues(alpha:0.15),
                                                  Colors.white.withValues(alpha:0.08),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha:0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  size: 14,
                                                  color: rankColor,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  kp,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
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

            // --- Bottom info bar ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _fadeIn.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha:0.9),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category/Year
                      if (scene.closureLine.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: rankColor.withValues(alpha:0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            scene.closureLine.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: rankColor.withValues(alpha:0.9),
                            ),
                          ),
                        ),

                      // Progress indicators (showing rank position)
                      Row(
                        children: List.generate(
                          5,
                          (index) => Container(
                            margin: const EdgeInsets.only(right: 6),
                            width: 40,
                            height: 6,
                            decoration: BoxDecoration(
                              color: index < rank
                                  ? rankColor
                                  : Colors.white.withValues(alpha:0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),

                      // Status
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.isPlaying
                                  ? rankColor
                                  : Colors.white54,
                              boxShadow: widget.isPlaying
                                  ? [
                                      BoxShadow(
                                        color: rankColor.withValues(alpha:0.6),
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
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Decorative side accent ---
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: _fadeIn.value * 0.3,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        rankColor,
                        rankColor,
                        Colors.transparent,
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

// --- Grid pattern painter for background ---
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha:0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 50.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}