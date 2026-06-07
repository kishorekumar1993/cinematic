import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ------------------------------------------------------
/// MASTER DUAL PRIME COMPARISON TEMPLATE
/// Clean, symmetric, premium — best universal layout
/// ------------------------------------------------------
class DualRankScene extends StatelessWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const DualRankScene({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF080A13),
                Color(0xFF05060A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // TITLE + SUBTITLE (optional)
              if (scene.title.trim().isNotEmpty) ...[
                Text(
                  scene.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (scene.subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
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
              ],

              Expanded(
                child: Row(
                  children: [
                    // LEFT PANEL
                    Expanded(
                      child: _PrimeSide(
                        title: scene.leftTitle,
                        subtitle: scene.leftSubtitle,
                        body: scene.leftBody,
                        bullets: scene.leftKeyPoints,
                        accent: scheme.primary,
                        imageUrl: scene.leftImageUrl,
                      ),
                    ),

                    // VS PILLAR
                    SizedBox(
                      width: 62,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Line top
                          Container(
                            width: 2,
                            height: 40,
                            color: Colors.white.withOpacity(0.25),
                          ),
                          const SizedBox(height: 8),
                          // VS bubble
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  scheme.primary,
                                  Colors.pinkAccent
                                ],
                              ),
                            ),
                            child: const Text(
                              "VS",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Line bottom
                          Container(
                            width: 2,
                            height: 40,
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ],
                      ),
                    ),

                    // RIGHT PANEL
                    Expanded(
                      child: _PrimeSide(
                        title: scene.rightTitle,
                        subtitle: scene.rightSubtitle,
                        body: scene.rightBody,
                        bullets: scene.rightKeyPoints,
                        accent: Colors.pinkAccent,
                        imageUrl: scene.rightImageUrl,
                      ),
                    ),
                  ],
                ),
              ),

              // CLOSURE TEXT (optional)
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
      ],
    );
  }
}

/// SIDE CARD WIDGET
class _PrimeSide extends StatelessWidget {
  final String title;
  final String subtitle;
  final String body;
  final List<String> bullets;
  final Color accent;
  final String imageUrl;

  const _PrimeSide({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.bullets,
    required this.accent,
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                // TITLE
                if (title.trim().isNotEmpty)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),

                // SUBTITLE
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

                // BODY
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

                // BULLETS
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
