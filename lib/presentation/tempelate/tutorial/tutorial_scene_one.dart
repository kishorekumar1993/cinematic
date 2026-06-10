import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';
import 'package:cinematic/services/voice_manager.dart';
import 'dart:ui';
import 'dart:math' as math;

class TutorialSceneOne extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const TutorialSceneOne({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<TutorialSceneOne> createState() => _TutorialSceneOneState();
}

class _TutorialSceneOneState extends State<TutorialSceneOne>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _ambientController;

  late Animation<double> _bgZoom;
  late Animation<double> _maskHeight;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _pointsSlide;

  final int _particleCount = 40;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    final durationSecs = widget.scene.durationSeconds.clamp(3, 120);

    _masterController = AnimationController(
      vsync: this,
      duration: Duration(seconds: durationSecs),
    );

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _bgZoom = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _masterController, curve: Curves.linear),
    );

    // Mask animation for Title
    _maskHeight = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.05, 0.25, curve: Curves.easeInOutCubic),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.25, 0.45, curve: Curves.easeIn),
      ),
    );

    _pointsSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _particles = List.generate(_particleCount, (i) => _Particle());

    if (widget.isPlaying) {
      _masterController.forward();
      // Speak the title and subtitle when the scene starts playing
      VoiceManager().speak("${widget.scene.title}. ${widget.scene.subtitle}");
    }
  }

  @override
  void didUpdateWidget(covariant TutorialSceneOne oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _masterController.forward();
        VoiceManager().speak("${widget.scene.title}. ${widget.scene.subtitle}");
      } else {
        _masterController.stop();
        VoiceManager().stop();
      }
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  Widget _buildBackground(SceneConfig scene) {
    if (scene.localImageBytes != null) {
      return Image.memory(
        scene.localImageBytes!,
        fit: BoxFit.cover,
      );
    }
    if (scene.imageUrl.isNotEmpty) {
      return Image.network(
        scene.imageUrl,
        fit: BoxFit.cover,
      );
    }
    return Container(color: const Color(0xFF0F172A)); // Dark slate
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    return AnimatedBuilder(
      animation: Listenable.merge([_masterController, _ambientController]),
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Ken Burns Background
            Transform.scale(
              scale: _bgZoom.value,
              child: _buildBackground(scene),
            ),

            // 2. Cinematic Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // 3. Floating Particles Layer
            CustomPaint(
              painter: _ParticlePainter(_particles, _ambientController.value),
            ),

            // 4. Content Reveal
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tag
                      FadeTransition(
                        opacity: _maskHeight, // reuse for tag fade
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white38),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "INTRODUCTION",
                            style: TextStyle(
                              color: Colors.white70,
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title Mask Reveal
                      ClipRect(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          heightFactor: _maskHeight.value,
                          child: Text(
                            scene.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 64,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),

                      if (scene.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        FadeTransition(
                          opacity: _subtitleFade,
                          child: Text(
                            scene.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 60),

                      // Staggered points
                      if (scene.keyPoints.isNotEmpty)
                        SlideTransition(
                          position: _pointsSlide,
                          child: FadeTransition(
                            opacity: _subtitleFade,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(scene.keyPoints.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.blueAccent, width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blueAccent.withValues(alpha: 0.3),
                                              blurRadius: 12,
                                            )
                                          ]
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${index + 1}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        scene.keyPoints[index],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }),
                            ),
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
}

class _Particle {
  final double x = math.Random().nextDouble();
  final double y = math.Random().nextDouble();
  final double speed = 0.2 + math.Random().nextDouble() * 0.5;
  final double size = 1.0 + math.Random().nextDouble() * 3.0;
  final double alpha = 0.1 + math.Random().nextDouble() * 0.5;
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: p.alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      // Move upwards
      final currentY = (p.y - (progress * p.speed)) % 1.0;
      // Slight horizontal drift
      final currentX = (p.x + math.sin(progress * math.pi * 2 + p.y * 10) * 0.05) % 1.0;

      // Handle negative modulo wrapper
      final dy = currentY < 0 ? currentY + 1.0 : currentY;
      final dx = currentX < 0 ? currentX + 1.0 : currentX;

      canvas.drawCircle(Offset(dx * size.width, dy * size.height), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
