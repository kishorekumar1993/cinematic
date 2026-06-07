import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ------------------------------------------------------
/// DUAL SPOTLIGHT COMPARISON SCENE
/// Circular photos + glass cards + center VS bar
/// ------------------------------------------------------
class DualSpotlightScene extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const DualSpotlightScene({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<DualSpotlightScene> createState() => _DualSpotlightSceneState();
}

class _DualSpotlightSceneState extends State<DualSpotlightScene>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slideTop;
  late Animation<Offset> _slideBottom;

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

    _slideTop = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _slideBottom = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant DualSpotlightScene oldWidget) {
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
              color.withValues(alpha: 0.45),
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

    final leftBullets = scene.leftKeyPoints;
    final rightBullets = scene.rightKeyPoints;

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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF050814),
                    Color(0xFF05060C),
                  ],
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
            _glowBlob(
              alignment: Alignment.topRight,
              color: Colors.blueAccent,
              size: 220,
            ),

            FadeTransition(
              opacity: _fade,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                child: Column(
                  children: [
                    // TOP: title, subtitle, progress
                    if (scene.title.trim().isNotEmpty) ...[
                      SlideTransition(
                        position: _slideTop,
                        child: Column(
                          children: [
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
                                    Colors.white.withValues(alpha: 0.08),
                                valueColor: AlwaysStoppedAnimation(
                                  scheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ],

                    // MIDDLE: spotlights + cards + VS
                    Expanded(
                      child: SlideTransition(
                        position: _slideBottom,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _SpotlightSide(
                                label: 'LEFT',
                                accent: scheme.primary,
                                title: scene.leftTitle,
                                subtitle: scene.leftSubtitle,
                                body: scene.leftBody,
                                bullets: leftBullets,
                                imageUrl: scene.leftImageUrl,
                              ),
                            ),
                            SizedBox(
                              width: 64,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Vertical line + VS
                                  Container(
                                    width: 2,
                                    height: 48,
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
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      gradient: LinearGradient(
                                        colors: [
                                          scheme.primary,
                                          Colors.pinkAccent,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: scheme.primary
                                              .withValues(alpha: 0.7),
                                          blurRadius: 18,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'VS',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 2,
                                    height: 48,
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
                            ),
                            Expanded(
                              child: _SpotlightSide(
                                label: 'RIGHT',
                                accent: Colors.pinkAccent,
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

                    // BOTTOM: closure
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

/// One side of the spotlight comparison
class _SpotlightSide extends StatelessWidget {
  final String label;
  final Color accent;
  final String title;
  final String subtitle;
  final String body;
  final List<String> bullets;
  final String imageUrl;

  const _SpotlightSide({
    required this.label,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.bullets,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;

    return Column(
      children: [
        // Spotlight circular image
        SizedBox(
          height: 110,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow halo
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Image circle
                ClipOval(
                  child: hasImage
                      ? Image.network(
                          imageUrl,
                          width: 74,
                          height: 74,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 74,
                            height: 74,
                            color: Colors.black54,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white54,
                            ),
                          ),
                        )
                      : Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accent.withValues(alpha: 0.3),
                                accent.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.person_outline,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                ),
                // Label chip at bottom
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.black.withValues(alpha: 0.6),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.7),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Card with glassmorphism content
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.13),
                        Colors.white.withValues(alpha: 0.03),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.72),
                        blurRadius: 20,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(color: Colors.transparent),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title line + accent
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: LinearGradient(
                                colors: [
                                  accent,
                                  accent.withValues(alpha: 0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title.trim().isEmpty ? ' ' : title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Subtitle
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

                      // Body
                      if (body.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          body,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            height: 1.35,
                          ),
                        ),
                      ],

                      // Bullets
                      if (bullets.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: bullets.length,
                            itemBuilder: (_, index) {
                              final p = bullets[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 4, top: 2),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.only(top: 5),
                                      decoration: BoxDecoration(
                                        color: accent,
                                        shape: BoxShape.circle,
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
          ),
        ),
      ],
    );
  }
}
