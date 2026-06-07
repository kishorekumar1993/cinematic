import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ------------------------------------------------------
/// DUAL CLEAN SPLIT COMPARISON SCENE
/// Super simple, symmetric, clean and premium
/// ------------------------------------------------------
class DualRibbonScene extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const DualRibbonScene({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<DualRibbonScene> createState() => _DualRibbonSceneState();
}

class _DualRibbonSceneState extends State<DualRibbonScene>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: widget.scene.durationSeconds.clamp(3, 120),
      ),
    )..forward();

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.8, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant DualRibbonScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _controller.forward();
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

  Widget _glowBlob({
    required Alignment alignment,
    required Color color,
    required double size,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.45),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF050712),
                    Color(0xFF05060A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            _glowBlob(
              alignment: Alignment.topLeft,
              color: scheme.primary,
              size: 260,
            ),
            _glowBlob(
              alignment: Alignment.bottomRight,
              color: Colors.pinkAccent,
              size: 280,
            ),

            FadeTransition(
              opacity: _fade,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                child: Column(
                  children: [
                    // TITLE + SUBTITLE + PROGRESS (optional)
                    if (scene.title.trim().isNotEmpty) ...[
                      Text(
                        scene.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      if (scene.subtitle.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          scene.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: _controller.value.clamp(0.0, 1.0),
                          minHeight: 4,
                          backgroundColor:
                              Colors.white.withOpacity(0.08),
                          valueColor: AlwaysStoppedAnimation(scheme.primary),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // MAIN COMPARISON
                    Expanded(
                      child: SlideTransition(
                        position: _slide,
                        child: Row(
                          children: [
                            // LEFT
                            Expanded(
                              child: _CleanSideCard(
                                accent: scheme.primary,
                                label: 'LEFT',
                                title: scene.leftTitle,
                                subtitle: scene.leftSubtitle,
                                body: scene.leftBody,
                                bullets: scene.leftKeyPoints,
                                imageUrl: scene.leftImageUrl,
                              ),
                            ),

                            // VS COLUMN
                            SizedBox(
                              width: 56,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 2,
                                    height: 40,
                                    color:
                                        Colors.white.withOpacity(0.25),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(999),
                                      color: Colors.white.withOpacity(0.08),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.4),
                                      ),
                                    ),
                                    child: const Text(
                                      'VS',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 2,
                                    height: 40,
                                    color:
                                        Colors.white.withOpacity(0.25),
                                  ),
                                ],
                              ),
                            ),

                            // RIGHT
                            Expanded(
                              child: _CleanSideCard(
                                accent: Colors.pinkAccent,
                                label: 'RIGHT',
                                title: scene.rightTitle,
                                subtitle: scene.rightSubtitle,
                                body: scene.rightBody,
                                bullets: scene.rightKeyPoints,
                                imageUrl: scene.rightImageUrl,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // CLOSURE LINE
                    if (scene.closureLine.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        scene.closureLine,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CleanSideCard extends StatelessWidget {
  final Color accent;
  final String label;
  final String title;
  final String subtitle;
  final String body;
  final List<String> bullets;
  final String imageUrl;

  const _CleanSideCard({
    required this.accent,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.bullets,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          // Glass background
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.10),
                  Colors.white.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.7),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(color: Colors.transparent),
          ),

          // Content
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LABEL + small line
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: accent.withOpacity(0.22),
                        border: Border.all(
                          color: accent.withOpacity(0.7),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        label.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.20),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // IMAGE (optional)
                if (hasImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 120,
                        color: Colors.black54,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [
                          accent.withOpacity(0.25),
                          accent.withOpacity(0.05),
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),

                const SizedBox(height: 10),

                // TITLE (optional)
                if (title.trim().isNotEmpty)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),

                // SUBTITLE (optional)
                if (subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],

                // BODY (optional)
                if (body.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Colors.white70,
                    ),
                  ),
                ],

                // BULLETS (optional)
                if (bullets.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: bullets.length,
                      itemBuilder: (_, index) {
                        final p = bullets[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(top: 6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  p,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.3,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
