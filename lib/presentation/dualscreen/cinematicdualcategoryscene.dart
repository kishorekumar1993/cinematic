

import 'dart:ui';

import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

class CinematicDualCategoryScene extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicDualCategoryScene({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicDualCategoryScene> createState() =>
      _CinematicDualCategorySceneState();
}

class _CinematicDualCategorySceneState extends State<CinematicDualCategoryScene>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.scene.durationSeconds.clamp(3, 120)),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.65, curve: Curves.easeOut),
      ),
    );

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CinematicDualCategoryScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        if (_controller.isDismissed) {
          _controller.forward();
        } else {
          _controller.forward();
        }
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

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return Container(
        height: 150,
        color: Colors.grey.shade800,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported),
      );
    }

    return Image.network(
      url,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 150,
        color: Colors.grey.shade800,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final leftBullets = scene.leftKeyPoints
            .map((e) => '• $e')
            .join('\n');
        final rightBullets = scene.rightKeyPoints
            .map((e) => '• $e')
            .join('\n');

        return Stack(
          fit: StackFit.expand,
          children: [
            // Dark background
            Container(color: Colors.black),

            FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Main title + subtitle
                      if (scene.title.isNotEmpty)
                        Text(
                          scene.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      if (scene.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          scene.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // LEFT + RIGHT blocks
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _DualCategorySideCard(
                                label: 'LEFT',
                                title: scene.leftTitle,
                                subtitle: scene.leftSubtitle,
                                body: scene.leftBody,
                                bullets: leftBullets,
                                imageUrl: scene.leftImageUrl,
                                alignRight: false,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _DualCategorySideCard(
                                label: 'RIGHT',
                                title: scene.rightTitle,
                                subtitle: scene.rightSubtitle,
                                body: scene.rightBody,
                                bullets: rightBullets,
                                imageUrl: scene.rightImageUrl,
                                alignRight: true,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // closure line
                      if (scene.closureLine.isNotEmpty) ...[
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
            ),
          ],
        );
      },
    );
  }
}

class _DualCategorySideCard extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;
  final String body;
  final String bullets;
  final String imageUrl;
  final bool alignRight;

  const _DualCategorySideCard({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.bullets,
    required this.imageUrl,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    final textAlign = alignRight ? TextAlign.right : TextAlign.left;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha:0.25), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.6),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: imageUrl.isEmpty
                ? Container(
                    height: 150,
                    color: Colors.grey.shade800,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported),
                  )
                : Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: alignRight
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Label chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.4,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  title.isEmpty ? ' ' : title,
                  textAlign: textAlign,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                // Subtitle
                if (subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: textAlign,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
                // Body
                if (body.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    body,
                    textAlign: textAlign,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
                // Bullets
                if (bullets.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    bullets,
                    textAlign: textAlign,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.4,
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
