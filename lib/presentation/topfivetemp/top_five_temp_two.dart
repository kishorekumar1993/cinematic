import 'dart:math';
import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// CINEMATIC TOP 5 RANKING TEMPLATE V2
/// Enhanced with modern animations, particle effects, and better visual hierarchy
/// ----------------------

class CinematicTopFiveV2 extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicTopFiveV2({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicTopFiveV2> createState() => _CinematicTopFiveV2State();
}

class _CinematicTopFiveV2State extends State<CinematicTopFiveV2>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late Animation<double> _masterFade;
  late Animation<double> _rankReveal;
  late Animation<double> _titleSlide;
  late Animation<double> _contentFade;
  late Animation<double> _particleOpacity;
  late Animation<double> _rankGlow;
  late Animation<double> _counter;
  late Animation<double> _bounce;

  final List<Particle> _particles = [];
  final Random _random = Random();
  late int _rank;

  @override
  void initState() {
    super.initState();
    
    // Extract rank before initializing animations
    _rank = _extractRankNumberAsInt();

    final duration = Duration(
      seconds: widget.scene.durationSeconds.clamp(8, 180),
    );

    _mainController = AnimationController(
      vsync: this,
      duration: duration,
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Master fade animation for entire scene
    _masterFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOutCubic),
      ),
    );

    // Rank number reveal - Using simple tween instead of TweenSequence
    _rankReveal = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.1, 0.4, curve: Curves.elasticOut),
      ),
    );

    // Title slide from left
    _titleSlide = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // Content fade in
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    // Particle system opacity
    _particleOpacity = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    // Pulsing glow effect - using sin wave for continuous pulsing
    _rankGlow = Tween<double>(begin: 0.7, end: 1.2).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const SineCurve(),
      ),
    );

    // Counter animation for rank number
    _counter = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.15, 0.35, curve: Curves.easeOut),
      ),
    );

    // Bounce animation for subtle movement
    _bounce = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const SineCurve(),
      ),
    );

    // Initialize particles
    _initializeParticles();

    if (widget.isPlaying) {
      _mainController.repeat(reverse: false);
    } else {
      _mainController.forward(); // Play once to show initial state
    }
  }

  void _initializeParticles() {
    _particles.clear();
    for (int i = 0; i < 50; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 1 + _random.nextDouble() * 3,
        speed: 0.1 + _random.nextDouble() * 0.3,
        color: _getRandomParticleColor(),
      ));
    }
  }

  Color _getRandomParticleColor() {
    final colors = [
      Colors.amber,
      Colors.cyan,
      Colors.purpleAccent,
      Colors.blueAccent,
      Colors.white,
    ];
    return colors[_random.nextInt(colors.length)].withValues(alpha:0.6);
  }

  @override
  void didUpdateWidget(covariant CinematicTopFiveV2 oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        if (_mainController.isCompleted) {
          _mainController.repeat(reverse: false);
        } else if (!_mainController.isAnimating) {
          _mainController.repeat(reverse: false);
        }
      } else {
        _mainController.stop();
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  String _extractRankNumber() {
    final RegExp rankPattern = RegExp(r'#?(\d+)');
    final titleMatch = rankPattern.firstMatch(widget.scene.title);
    if (titleMatch != null) return titleMatch.group(1) ?? '1';

    final subtitleMatch = rankPattern.firstMatch(widget.scene.subtitle);
    if (subtitleMatch != null) return subtitleMatch.group(1) ?? '1';

    // Try to extract from key points
    for (final point in widget.scene.keyPoints) {
      final match = rankPattern.firstMatch(point);
      if (match != null) return match.group(1) ?? '1';
    }

    return '1';
  }

  int _extractRankNumberAsInt() {
    return int.tryParse(_extractRankNumber()) ?? 1;
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      case 4:
        return const Color(0xFF4A90E2); // Blue
      case 5:
        return const Color(0xFF50E3C2); // Teal
      default:
        return Colors.purpleAccent;
    }
  }

  String _getRankSuffix(int rank) {
    if (rank % 100 >= 11 && rank % 100 <= 13) return 'th';
    switch (rank % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Widget _buildBackground() {
    if (widget.scene.localImageBytes != null) {
      return Stack(
        children: [
          Image.memory(
            widget.scene.localImageBytes!,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.black.withValues(alpha:0.8),
                  Colors.transparent,
                ],
                stops: const [0.3, 0.9],
              ),
            ),
          ),
        ],
      );
    }

    if (widget.scene.imageUrl.isNotEmpty) {
      return Stack(
        children: [
          Image.network(
            widget.scene.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _defaultBackground(),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.black.withValues(alpha:0.7),
                  Colors.transparent,
                ],
                stops: const [0.2, 0.8],
              ),
            ),
          ),
        ],
      );
    }

    return _defaultBackground();
  }

  Widget _defaultBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: SweepGradient(
          center: Alignment.center,
          colors: [
            Colors.indigo.shade900,
            Colors.purple.shade800,
            Colors.deepPurple.shade900,
            Colors.black,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildInfoCards(Color rankColor) {
    return Column(
      children: [
        // Year/Category Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                rankColor.withValues(alpha:0.15),
                rankColor.withValues(alpha:0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: rankColor.withValues(alpha:0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: rankColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'YEAR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: rankColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.scene.closureLine.isNotEmpty
                    ? widget.scene.closureLine
                    : '2024',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Score/Rating Card
        Transform.translate(
          offset: Offset(0, _bounce.value),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha:0.1),
                  Colors.white.withValues(alpha:0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha:0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SCORE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${(9.0 - (_rank - 1) * 0.5).toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      '/10',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (9.0 - (_rank - 1) * 0.5) / 10,
                  backgroundColor: Colors.white.withValues(alpha:0.1),
                  color: rankColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor(_rank);
    final animatedRank = (_counter.value.clamp(0.0, 1.0) * _rank).ceil();
    final rankSuffix = _getRankSuffix(animatedRank);

    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _particleController]),
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // --- Background ---
            _buildBackground(),

            // --- Particle System ---
            Opacity(
              opacity: _particleOpacity.value,
              child: CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  controller: _particleController,
                ),
              ),
            ),

            // --- Main Content ---
            Opacity(
              opacity: _masterFade.value,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header with rank ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rank Circle
                        Transform.scale(
                          scale: _rankReveal.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  rankColor.withValues(alpha:0.9),
                                  rankColor.withValues(alpha:0.1),
                                ],
                                stops: const [0.5, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: rankColor.withValues(alpha:0.5),
                                  blurRadius: 30 * _rankGlow.value.clamp(0.7, 1.2),
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha:0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withValues(alpha:0.3),
                                width: 2,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow effect
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withValues(alpha:0.2),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.1, 0.5],
                                    ),
                                  ),
                                ),
                                // Rank number
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '#$animatedRank',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.0,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(alpha:0.8),
                                            blurRadius: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      rankSuffix,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white.withValues(alpha:0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 30),

                        // Title area
                        Expanded(
                          child: Transform.translate(
                            offset: Offset(_titleSlide.value, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Subtitle/Category
                                if (widget.scene.subtitle.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: rankColor.withValues(alpha:0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: rankColor.withValues(alpha:0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      widget.scene.subtitle.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2.0,
                                        color: rankColor,
                                      ),
                                    ),
                                  ),

                                // Main Title
                                Text(
                                  widget.scene.title,
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha:0.8),
                                        blurRadius: 15,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),

                                // Hook line
                                if (widget.scene.hook.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      widget.scene.hook,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withValues(alpha:0.9),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // --- Main Content Area ---
                    Opacity(
                      opacity: _contentFade.value,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side - Content
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Body text
                                if (widget.scene.body.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 30),
                                    child: Text(
                                      widget.scene.body,
                                      style: TextStyle(
                                        fontSize: 18,
                                        height: 1.6,
                                        color: Colors.white.withValues(alpha:0.9),
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(alpha:0.5),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                // Key Points
                                if (widget.scene.keyPoints.isNotEmpty)
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: widget.scene.keyPoints
                                        .map(
                                          (point) => Transform.translate(
                                            offset: Offset(
                                              0,
                                              _bounce.value * 0.5,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.white.withValues(alpha:0.1),
                                                    Colors.white.withValues(alpha:0.05),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.white.withValues(alpha:0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.star_rounded,
                                                    size: 16,
                                                    color: rankColor,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    point,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 60),

                          // Right side - Stats/Info Cards
                          Expanded(
                            flex: 1,
                            child: _buildInfoCards(rankColor),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // --- Progress Indicator ---
                    Opacity(
                      opacity: _contentFade.value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOP 5 PROGRESS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
                              color: Colors.white.withValues(alpha:0.6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: List.generate(
                              5,
                              (index) => Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    right: index < 4 ? 8 : 0,
                                  ),
                                  height: 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    gradient: index < _rank
                                        ? LinearGradient(
                                            colors: [
                                              rankColor,
                                              rankColor.withValues(alpha:0.7),
                                            ],
                                          )
                                        : null,
                                    color: index < _rank
                                        ? null
                                        : Colors.white.withValues(alpha:0.1),
                                  ),
                                  child: index == _rank - 1
                                      ? Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(2),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    rankColor,
                                                    rankColor.withValues(alpha:0.7),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Positioned.fill(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(2),
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.white.withValues(alpha:0.3),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Decorative corner accents ---
            Positioned(
              top: 0,
              right: 0,
              child: Opacity(
                opacity: _masterFade.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        rankColor.withValues(alpha:0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Opacity(
                opacity: _masterFade.value * 0.5,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha:0.05),
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

// --- Custom Sine Curve for continuous animations ---
class SineCurve extends Curve {
  const SineCurve();

  @override
  double transform(double t) {
    return sin(2 * pi * t) * 0.5 + 0.5;
  }
}

// --- Particle System ---
class Particle {
  double x, y;
  double size;
  double speed;
  Color color;
  double angle;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    this.angle = 0,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final AnimationController controller;

  ParticlePainter({
    required this.particles,
    required this.controller,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final time = controller.value * 2 * pi;

    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      // Animated position
      final dx = particle.x + sin(time * particle.speed + particle.angle) * 0.1;
      final dy = particle.y + cos(time * particle.speed * 0.8 + particle.angle) * 0.1;

      // Draw particle
      canvas.drawCircle(
        Offset(dx * size.width, dy * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}