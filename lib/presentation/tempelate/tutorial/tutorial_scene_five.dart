import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

class TutorialSceneFive extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const TutorialSceneFive({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<TutorialSceneFive> createState() => _TutorialSceneFiveState();
}

class _TutorialSceneFiveState extends State<TutorialSceneFive>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _imageZoom;

  @override
  void initState() {
    super.initState();
    final durationSecs = widget.scene.durationSeconds.clamp(3, 120);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: durationSecs),
    );

    // Continuous slow zoom (1.0 -> 1.1) and pan handled via FractionalTranslation
    _imageZoom = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant TutorialSceneFive oldWidget) {
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

  Widget _buildVisualSide(SceneConfig scene) {
    if (scene.localImageBytes != null) {
      return Image.memory(
        scene.localImageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (scene.imageUrl.isNotEmpty) {
      return Image.network(
        scene.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Container(
      color: const Color(0xFF1E293B),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 100, color: Colors.blueGrey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          // Left side: Visuals
          Expanded(
            flex: 5,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Combine Zoom with a slight pan
                final pan = Offset(-0.05 * _controller.value, 0);
                
                return ClipRect(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      FractionalTranslation(
                        translation: pan,
                        child: Transform.scale(
                          scale: _imageZoom.value,
                          child: _buildVisualSide(scene),
                        ),
                      ),
                      // Inner gradient shadow for depth
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          // Right side: Content
          Expanded(
            flex: 6,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Staggered Title
                      _buildStaggeredItem(
                        index: 0,
                        child: Text(
                          scene.title,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            height: 1.1,
                          ),
                        ),
                      ),
                      if (scene.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildStaggeredItem(
                          index: 1,
                          child: Text(
                            scene.subtitle,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                      if (scene.body.isNotEmpty)
                        _buildStaggeredItem(
                          index: 2,
                          child: Text(
                            scene.body,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFF334155),
                              height: 1.6,
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                      if (scene.keyPoints.isNotEmpty)
                        ...List.generate(scene.keyPoints.length, (i) {
                          return _buildStaggeredItem(
                            index: 3 + i,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(Icons.check, color: Color(0xFF10B981), size: 24),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        scene.keyPoints[i],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Color(0xFF1E293B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStaggeredItem({required int index, required Widget child}) {
    final start = 0.1 + (index * 0.1);
    final end = start + 0.2;
    
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
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
}
