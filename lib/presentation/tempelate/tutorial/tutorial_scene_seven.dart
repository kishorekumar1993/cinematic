import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

class TutorialSceneSeven extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const TutorialSceneSeven({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<TutorialSceneSeven> createState() => _TutorialSceneSevenState();
}

class _TutorialSceneSevenState extends State<TutorialSceneSeven>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Using a longer duration base since we want highly staggered effects
    final durationSecs = widget.scene.durationSeconds.clamp(8, 120);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: durationSecs),
    );

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant TutorialSceneSeven oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      widget.isPlaying ? _controller.forward() : _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    return Container(
      color: const Color(0xFFF8FAFC), // Slate 50
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Highly staggered timings matching Netflix/Cinematic anticipation builds
            // Base duration let's say is 8 seconds.
            // 0s-1s: Title
            // 1s-2s: Subtitle
            // 2s-3s: Card 1
            // 3s-4s: Card 2...
            
            // Map absolute seconds to controller percentage (0.0 to 1.0)
            final double secToPercent = 1.0 / (_controller.duration!.inSeconds.toDouble());

            final titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(0.0, (1.0 * secToPercent).clamp(0.0, 1.0), curve: Curves.easeIn),
              ),
            );

            final subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval((1.0 * secToPercent).clamp(0.0, 1.0), (2.0 * secToPercent).clamp(0.0, 1.0), curve: Curves.easeIn),
              ),
            );

            return Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      FadeTransition(
                        opacity: titleFade,
                        child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(titleFade),
                          child: Text(
                            scene.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                      if (scene.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        FadeTransition(
                          opacity: subtitleFade,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(subtitleFade),
                            child: Text(
                              scene.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(scene.keyPoints.length, (index) {
                        // Stagger cards starting from 2.0s
                        final double startSec = 2.0 + (index * 1.0);
                        final double endSec = startSec + 1.0;

                        final pointFade = Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Interval(
                              (startSec * secToPercent).clamp(0.0, 1.0),
                              (endSec * secToPercent).clamp(0.0, 1.0),
                              curve: Curves.easeOut,
                            ),
                          ),
                        );

                        final pointSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Interval(
                              (startSec * secToPercent).clamp(0.0, 1.0),
                              (endSec * secToPercent).clamp(0.0, 1.0),
                              curve: Curves.easeOutBack,
                            ),
                          ),
                        );

                        // Line drawing animation between nodes
                        final lineStartSec = startSec - 0.5;
                        final lineEndSec = startSec + 0.5;
                        final lineDraw = Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Interval(
                              (lineStartSec * secToPercent).clamp(0.0, 1.0),
                              (lineEndSec * secToPercent).clamp(0.0, 1.0),
                              curve: Curves.easeInOut,
                            ),
                          ),
                        );

                        return Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 4,
                                      color: index == 0 ? Colors.transparent : const Color(0xFFE2E8F0),
                                      alignment: Alignment.centerLeft,
                                      child: index == 0 ? null : FractionallySizedBox(
                                        widthFactor: lineDraw.value,
                                        child: Container(
                                          height: 4,
                                          color: const Color(0xFF3B82F6),
                                        ),
                                      ),
                                    ),
                                  ),
                                  FadeTransition(
                                    opacity: pointFade,
                                    child: ScaleTransition(
                                      scale: pointFade, // Using fade curve for scale bounce too
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            )
                                          ],
                                          border: Border.all(color: Colors.white, width: 4),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${index + 1}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 4,
                                      color: index == scene.keyPoints.length - 1 ? Colors.transparent : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              FadeTransition(
                                opacity: pointFade,
                                child: SlideTransition(
                                  position: pointSlide,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 12),
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        )
                                      ],
                                    ),
                                    child: Text(
                                      scene.keyPoints[index],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF334155),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                if (scene.closureLine.isNotEmpty) ...[
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _controller,
                        // Show CTA at the very end
                        curve: Interval(
                          ((2.0 + scene.keyPoints.length) * secToPercent).clamp(0.0, 1.0),
                          ((3.0 + scene.keyPoints.length) * secToPercent).clamp(0.0, 1.0),
                          curve: Curves.easeIn
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: Text(
                        scene.closureLine,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  )
                ]
              ],
            );
          },
        ),
      ),
    );
  }
}
