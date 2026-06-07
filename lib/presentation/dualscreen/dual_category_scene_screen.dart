import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ----------------------
/// DUAL CATEGORY SCENE
/// ----------------------

class DualCategoryScene extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const DualCategoryScene({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<DualCategoryScene> createState() => _DualCategorySceneState();
}

class _DualCategorySceneState extends State<DualCategoryScene>
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
    )..forward();

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.7, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant DualCategoryScene oldWidget) {
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

  Widget _glowCircle({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    final scheme = Theme.of(context).colorScheme;

    final leftBullets = scene.leftKeyPoints.map((e) => '• $e').join('\n');
    final rightBullets = scene.rightKeyPoints.map((e) => '• $e').join('\n');

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF050712),
                    Color(0xFF05060A),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -120,
              left: -40,
              child: _glowCircle(
                color: scheme.primary.withValues(alpha: 0.4),
                size: 220,
              ),
            ),
            Positioned(
              bottom: -120,
              right: -60,
              child: _glowCircle(
                color: Colors.pinkAccent.withValues(alpha: 0.35),
                size: 260,
              ),
            ),
            FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (scene.title.isNotEmpty) ...[
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
                                Colors.white.withValues(alpha: 0.08),
                            valueColor:
                                AlwaysStoppedAnimation(scheme.primary),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _DualSideCard(
                                label: 'LEFT',
                                title: scene.leftTitle,
                                subtitle: scene.leftSubtitle,
                                body: scene.leftBody,
                                bullets: leftBullets,
                                imageUrl: scene.leftImageUrl,
                                alignRight: false,
                              ),
                            ),
                            SizedBox(
                              width: 46,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          scheme.primary,
                                          Colors.pinkAccent,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: scheme.primary
                                              .withValues(alpha: 0.5),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'VS',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: _DualSideCard(
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
                      if (scene.closureLine.isNotEmpty) ...[
                        const SizedBox(height: 10),
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

class _DualSideCard extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;
  final String body;
  final String bullets;
  final String imageUrl;
  final bool alignRight;

  const _DualSideCard({
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
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.75),
            blurRadius: 20,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: imageUrl.isEmpty
                ? Container(
                    height: 150,
                    color: Colors.grey.shade900,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.white54),
                  )
                : Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 150,
                      color: Colors.grey.shade900,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image,
                          color: Colors.white54),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: alignRight
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: alignRight
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (!alignRight)
                      _labelChip(label: label, scheme: scheme),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                            begin: alignRight
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            end: alignRight
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                    if (alignRight)
                      _labelChip(label: label, scheme: scheme),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title.isEmpty ? ' ' : title,
                  textAlign: textAlign,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
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

  Widget _labelChip({
    required String label,
    required ColorScheme scheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.5),
          width: 0.7,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          letterSpacing: 1.4,
          color: Colors.white,
        ),
      ),
    );
  }
}

