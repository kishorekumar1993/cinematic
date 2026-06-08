import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

class TutorialSceneTwo extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const TutorialSceneTwo({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<TutorialSceneTwo> createState() => _TutorialSceneTwoState();
}

class _TutorialSceneTwoState extends State<TutorialSceneTwo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _wipeAnimation;
  late Animation<Offset> _titleSlide;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _codeFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.scene.durationSeconds.clamp(3, 120)),
    );

    // Left to Right Wipe for the code container
    _wipeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeInOutCubic),
      ),
    );

    // Staggered Title Slide
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOutBack),
      ),
    );

    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.3, curve: Curves.easeOutBack),
      ),
    );

    // Code Fade
    _codeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeIn),
      ),
    );

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant TutorialSceneTwo oldWidget) {
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
      color: const Color(0xFF0D1117), // GitHub Dark Background
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Staggered Title
                  ClipRect(
                    child: SlideTransition(
                      position: _titleSlide,
                      child: Text(
                        scene.title,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (scene.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ClipRect(
                      child: SlideTransition(
                        position: _subtitleSlide,
                        child: Text(
                          scene.subtitle,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),

                  // Left-to-Right Wipe Code Container
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _wipeAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF161B22),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF30363D)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF21262D),
                                    border: Border(bottom: BorderSide(color: Color(0xFF30363D))),
                                  ),
                                  child: Row(
                                    children: [
                                      Row(
                                        children: [
                                          _buildDot(Colors.redAccent),
                                          const SizedBox(width: 8),
                                          _buildDot(Colors.amber),
                                          const SizedBox(width: 8),
                                          _buildDot(Colors.greenAccent),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      const Text(
                                        "main.dart",
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: FadeTransition(
                                    opacity: _codeFade,
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(32),
                                      child: Text(
                                        scene.hook.isNotEmpty ? scene.hook : "// Code snippet here",
                                        style: const TextStyle(
                                          color: Color(0xFFC9D1D9),
                                          fontFamily: 'monospace',
                                          fontSize: 18,
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Tip Slide Up
                  if (scene.body.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    ClipRect(
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: const Interval(0.6, 0.8, curve: Curves.easeOutCubic),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.blueAccent, size: 28),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  scene.body,
                                  style: const TextStyle(color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ]
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
