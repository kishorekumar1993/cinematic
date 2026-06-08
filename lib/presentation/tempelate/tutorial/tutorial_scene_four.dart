import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

class TutorialSceneFour extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const TutorialSceneFour({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<TutorialSceneFour> createState() => _TutorialSceneFourState();
}

class _TutorialSceneFourState extends State<TutorialSceneFour>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _ambientController;

  late Animation<double> _bgZoom;
  late Animation<double> _cardScale;
  late Animation<double> _cardRotation;
  late Animation<double> _titleFade;

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
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _bgZoom = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _masterController, curve: Curves.linear),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.1, 0.4, curve: Curves.easeIn),
      ),
    );

    _cardScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _cardRotation = Tween<double>(begin: -0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    if (widget.isPlaying) {
      _masterController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant TutorialSceneFour oldWidget) {
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
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0xFF2B203E), Color(0xFF100B1A)],
          radius: 1.5,
        )
      ),
    );
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
            // Ken Burns Background
            Transform.scale(
              scale: _bgZoom.value,
              child: _buildBackground(scene),
            ),
            
            // Dark vignette overlay
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _titleFade,
                        child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(_titleFade),
                          child: Column(
                            children: [
                              Text(
                                scene.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (scene.subtitle.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  scene.subtitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Card Animation (Zoom in, slight rotate, glow)
                      Transform.rotate(
                        angle: _cardRotation.value,
                        child: Transform.scale(
                          scale: _cardScale.value,
                          child: Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: const Color(0xFF282A36),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFBD93F9),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  // Breathing glow effect
                                  color: const Color(0xFFBD93F9).withValues(alpha: 0.2 + 0.3 * _ambientController.value),
                                  blurRadius: 40 + 20 * _ambientController.value,
                                  spreadRadius: 5 + 5 * _ambientController.value,
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lightbulb_outline, 
                                      color: const Color(0xFFF1FA8C), 
                                      size: 36 + 4 * _ambientController.value,
                                    ),
                                    const SizedBox(width: 16),
                                    const Text(
                                      "PRO TIP",
                                      style: TextStyle(
                                        color: Color(0xFFF1FA8C),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 3,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  scene.closureLine.isNotEmpty ? scene.closureLine : "Highlight tip will appear here.",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    color: Colors.white,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
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
