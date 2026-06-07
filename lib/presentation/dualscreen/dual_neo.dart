import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ------------------------------------
/// DUAL NEON COMPARISON SCENE TEMPLATE
/// ------------------------------------
class DualNeoScene extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const DualNeoScene({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<DualNeoScene> createState() => _DualNeoSceneState();
}

class _DualNeoSceneState extends State<DualNeoScene>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slideCards;
  late Animation<double> _scaleVs;

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
      curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
    );

    _slideCards = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _scaleVs = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant DualNeoScene oldWidget) {
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
      child: Transform.translate(
        offset: const Offset(0, 0),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.55),
                Colors.transparent,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
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
            // BACKGROUND
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF050712),
                    Color(0xFF05060A),
                  ],
                ),
              ),
            ),
            // GLOW BLOBS
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
            _glowBlob(
              alignment: Alignment.center,
              color: Colors.blueAccent,
              size: 220,
            ),

            // MAIN CONTENT
            FadeTransition(
              opacity: _fade,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                child: Column(
                  children: [
                    // TITLE + SUBTITLE + PROGRESS
                    if (scene.title.isNotEmpty) ...[
                      Text(
                        scene.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      if (scene.subtitle.isNotEmpty) ...[
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
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: _controller.value.clamp(0.0, 1.0),
                          minHeight: 4,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation(
                            scheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // CARDS + VS
                    Expanded(
                      child: SlideTransition(
                        position: _slideCards,
                        child: Row(
                          children: [
                            // LEFT PANEL
                            Expanded(
                              child: _NeonSideCard(
                                alignmentRight: false,
                                accentColor: scheme.primary,
                                label: 'LEFT',
                                title: scene.leftTitle,
                                subtitle: scene.leftSubtitle,
                                body: scene.leftBody,
                                bullets: leftBullets,
                                imageUrl: scene.leftImageUrl,
                              ),
                            ),

                            // VS COLUMN
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: ScaleTransition(
                                scale: _scaleVs,
                                child: _VsPillar(
                                  primary: scheme.primary,
                                ),
                              ),
                            ),

                            // RIGHT PANEL
                            Expanded(
                              child: _NeonSideCard(
                                alignmentRight: true,
                                accentColor: Colors.pinkAccent,
                                label: 'RIGHT',
                                title: scene.rightTitle,
                                subtitle: scene.rightSubtitle,
                                body: scene.rightBody,
                                bullets: rightBullets,
                                imageUrl: scene.rightImageUrl,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // CLOSURE LINE
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
          ],
        );
      },
    );
  }
}

/// VS PILLAR IN CENTER
class _VsPillar extends StatelessWidget {
  final Color primary;

  const _VsPillar({required this.primary});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top small line
          Container(
            width: 2,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.0),
                  Colors.white.withValues(alpha: 0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // VS bubble
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  primary,
                  Colors.pinkAccent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.7),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'VS',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Bottom small line
          Container(
            width: 2,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.4),
                  Colors.white.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// SIDE CARD
class _NeonSideCard extends StatelessWidget {
  final bool alignmentRight;
  final Color accentColor;
  final String label;
  final String title;
  final String subtitle;
  final String body;
  final String bullets;
  final String imageUrl;

  const _NeonSideCard({
    required this.alignmentRight,
    required this.accentColor,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.bullets,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // ⛔ No more right text alignment – keep content clean
    const TextAlign textAlign = TextAlign.left;
    const CrossAxisAlignment crossAlign = CrossAxisAlignment.start;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          // Glass background
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.14),
                  Colors.white.withValues(alpha: 0.03),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 20,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
          ),

          // Blur layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(color: Colors.transparent),
          ),

          // Top accent bar (same for left & right)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor,
                    accentColor.withValues(alpha: 0.0),
                    accentColor.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: crossAlign,
              children: [
                // LABEL + line (mirrored only for chip position)
                Row(
                  children: [
                    if (!alignmentRight)
                      _labelChip(label: label, accentColor: accentColor),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.25),
                              Colors.transparent,
                            ],
                            begin: alignmentRight
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            end: alignmentRight
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                    if (alignmentRight)
                      _labelChip(label: label, accentColor: accentColor),
                  ],
                ),

                const SizedBox(height: 10),

                // IMAGE (optional)
                if (imageUrl.trim().isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      height: kToolbarHeight*2.5,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 120,
                        color: Colors.black.withValues(alpha: 0.5),
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
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withValues(alpha: 0.22),
                          accentColor.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 26,
                    ),
                  ),

                const SizedBox(height: 10),

                // TITLE
                Text(
                  title.isEmpty ? ' ' : title,
                  textAlign: textAlign,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),

                // SUBTITLE
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

                // BODY
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

                // BULLETS
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
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accentColor.withValues(alpha: 0.18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.8),
          width: 0.8,
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
    );
  }
}
