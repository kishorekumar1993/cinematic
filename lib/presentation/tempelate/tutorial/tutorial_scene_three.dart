import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

class TutorialSceneThree extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const TutorialSceneThree({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<TutorialSceneThree> createState() => _TutorialSceneThreeState();
}

class _TutorialSceneThreeState extends State<TutorialSceneThree>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lineGrowth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.scene.durationSeconds.clamp(3, 120)),
    );

    // Progress line growing top to bottom
    _lineGrowth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant TutorialSceneThree oldWidget) {
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
      color: const Color(0xFFFAFAFA),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 40.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
                            CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.2, curve: Curves.easeOut)),
                          ),
                          child: Text(
                            scene.title,
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                              height: 1.1,
                            ),
                          ),
                        ),
                        if (scene.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          FadeTransition(
                            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.3, curve: Curves.easeIn)),
                            ),
                            child: Text(
                              scene.subtitle,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 80),
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        // Background Line
                        Positioned(
                          left: 23, // center of the 48px circle
                          top: 24,
                          bottom: 24,
                          child: Container(
                            width: 2,
                            color: const Color(0xFFE5E7EB),
                          ),
                        ),
                        // Animated Active Line
                        Positioned(
                          left: 23,
                          top: 24,
                          bottom: 24,
                          child: FractionallySizedBox(
                            heightFactor: _lineGrowth.value,
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 2,
                              color: const Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                        // Timeline Items
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: scene.keyPoints.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 48),
                          itemBuilder: (context, index) {
                            // Stagger logic based on line growth
                            // We map index to a time interval so it appears just as the line reaches it
                            double start = 0.2 + (index / scene.keyPoints.length) * 0.6;
                            double end = start + 0.15;
                            
                            final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _controller,
                                curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutBack),
                              ),
                            );

                            return ScaleTransition(
                              scale: animation,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _lineGrowth.value > start ? const Color(0xFF4F46E5) : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF4F46E5),
                                        width: 3,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${index + 1}",
                                        style: TextStyle(
                                          color: _lineGrowth.value > start ? Colors.white : const Color(0xFF4F46E5),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFF3F4F6)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 15,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: Text(
                                        scene.keyPoints[index],
                                        style: const TextStyle(
                                          fontSize: 22,
                                          color: Color(0xFF1F2937),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
