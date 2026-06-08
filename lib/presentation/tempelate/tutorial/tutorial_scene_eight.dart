import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class TutorialSceneEight extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const TutorialSceneEight({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<TutorialSceneEight> createState() => _TutorialSceneEightState();
}

class _TutorialSceneEightState extends State<TutorialSceneEight>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _ambientController;
  late Animation<double> _fade;

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
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.1, 0.4, curve: Curves.easeIn),
      ),
    );

    if (widget.isPlaying) {
      _masterController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant TutorialSceneEight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      widget.isPlaying ? _masterController.forward() : _masterController.stop();
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    // Maximum 3 cards for this layout
    final cardsCount = scene.keyPoints.length > 3 ? 3 : scene.keyPoints.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2E), Color(0xFF0F0F1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([_masterController, _ambientController]),
          builder: (context, child) {
            return Stack(
              children: [
                // Floating subtle particles
                ...List.generate(10, (i) {
                  return Positioned(
                    left: 200 + 150 * math.sin(_ambientController.value * math.pi * 2 + i),
                    top: 150 + 100 * math.cos(_ambientController.value * math.pi * 2 + i * 2),
                    child: Container(
                      width: 4 + i.toDouble(),
                      height: 4 + i.toDouble(),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      ),
                    ),
                  );
                }),

                FadeTransition(
                  opacity: _fade,
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Text(
                          scene.title,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                        if (scene.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            scene.subtitle,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(cardsCount, (index) {
                            // Independently staggered directions
                            // Card 0: from Left
                            // Card 1: from Bottom
                            // Card 2: from Right
                            Offset slideBegin;
                            if (index == 0) {
                              slideBegin = const Offset(-0.5, 0);
                            } else if (index == 1) {
                              slideBegin = const Offset(0, 0.5);
                            } else {
                              slideBegin = const Offset(0.5, 0);
                            }

                            final cardSlide = Tween<Offset>(
                              begin: slideBegin,
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _masterController,
                                curve: Interval(
                                  (0.2 + index * 0.15).clamp(0.0, 1.0),
                                  (0.5 + index * 0.15).clamp(0.0, 1.0),
                                  curve: Curves.easeOutBack,
                                ),
                              ),
                            );

                            final cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _masterController,
                                curve: Interval(
                                  (0.2 + index * 0.15).clamp(0.0, 1.0),
                                  (0.4 + index * 0.15).clamp(0.0, 1.0),
                                  curve: Curves.easeIn,
                                ),
                              ),
                            );

                            return SlideTransition(
                              position: cardSlide,
                              child: FadeTransition(
                                opacity: cardFade,
                                child: Container(
                                  width: 320,
                                  height: 420,
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        blurRadius: 40,
                                        offset: const Offset(0, 20),
                                      )
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: Stack(
                                      children: [
                                        // Subtle internal animated gradient
                                        Positioned(
                                          top: -100 + 50 * math.sin(_ambientController.value * math.pi * 2 + index),
                                          right: -100 + 50 * math.cos(_ambientController.value * math.pi * 2 + index),
                                          child: Container(
                                            width: 250,
                                            height: 250,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.amberAccent.withValues(alpha: 0.05),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.amberAccent.withValues(alpha: 0.1),
                                                  blurRadius: 80,
                                                )
                                              ]
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(32.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Colors.amberAccent.withValues(alpha: 0.15),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5)),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "${index + 1}",
                                                    style: const TextStyle(
                                                      fontSize: 32,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.amberAccent,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 40),
                                              Text(
                                                scene.keyPoints[index],
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.5,
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
                            );
                          }),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
