import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class TutorialSceneSix extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const TutorialSceneSix({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<TutorialSceneSix> createState() => _TutorialSceneSixState();
}

class _TutorialSceneSixState extends State<TutorialSceneSix>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _ambientController;

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
      duration: const Duration(seconds: 15),
    )..repeat();

    if (widget.isPlaying) {
      _masterController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant TutorialSceneSix oldWidget) {
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

    return AnimatedBuilder(
      animation: Listenable.merge([_masterController, _ambientController]),
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Moving Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [
                    Color(0xFF0F172A), // Slate 900
                    Color(0xFF020617), // Slate 950
                  ],
                  begin: Alignment(math.cos(_ambientController.value * math.pi * 2), math.sin(_ambientController.value * math.pi * 2)),
                  end: Alignment(-math.cos(_ambientController.value * math.pi * 2), -math.sin(_ambientController.value * math.pi * 2)),
                ),
              ),
            ),
            
            // 2. Animated Glowing Shapes (Light Streaks)
            Positioned(
              left: -100 + 400 * math.sin(_ambientController.value * math.pi),
              top: -100 + 200 * math.cos(_ambientController.value * math.pi * 2),
              child: Container(
                width: 600,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1), // Emerald glow
                  borderRadius: BorderRadius.circular(1000),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.2), blurRadius: 100, spreadRadius: 50)
                  ]
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                  child: const SizedBox(),
                ),
              ),
            ),

            // 3. Main Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 40.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStaggeredItem(
                            index: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                              ),
                              child: const Text(
                                "TERMINAL_MODE_ACTIVE",
                                style: TextStyle(
                                  color: Color(0xFF34D399),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildStaggeredItem(
                            index: 1,
                            child: Text(
                              scene.title,
                              style: const TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ),
                          if (scene.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildStaggeredItem(
                              index: 2,
                              child: Text(
                                scene.subtitle,
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Color(0xFF94A3B8),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 60),
                    Expanded(
                      flex: 3,
                      child: _buildStaggeredItem(
                        index: 3,
                        child: _buildTerminal(scene),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTerminal(SceneConfig scene) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.8), // Translucent slate
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 40,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF020617).withValues(alpha: 0.6),
                  border: const Border(bottom: BorderSide(color: Color(0xFF1E293B))),
                ),
                child: Row(
                  children: [
                    _buildDot(Colors.redAccent),
                    const SizedBox(width: 8),
                    _buildDot(Colors.amber),
                    const SizedBox(width: 8),
                    _buildDot(const Color(0xFF10B981)),
                    const SizedBox(width: 24),
                    const Text(
                      "bash - root@server:~",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontFamily: 'monospace',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(32),
                  itemCount: scene.keyPoints.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: Row(
                          children: [
                            const Text(
                              "\$ ",
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontFamily: 'monospace',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              scene.hook.isNotEmpty ? scene.hook : "./run_script.sh",
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final pointIndex = index - 1;
                    return _buildStaggeredItem(
                      index: 4 + pointIndex, // Start staggered effect after terminal appears
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "[OK] ",
                              style: TextStyle(
                                color: Color(0xFF34D399),
                                fontFamily: 'monospace',
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                scene.keyPoints[pointIndex],
                                style: const TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  fontFamily: 'monospace',
                                  fontSize: 18,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaggeredItem({required int index, required Widget child}) {
    final start = (index * 0.1).clamp(0.0, 0.8);
    final end = (start + 0.2).clamp(0.0, 1.0);
    
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
