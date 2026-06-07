import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

/// ------------------------------------------------------------------
/// 1) DUAL MIRROR SCENE  (Glass + Center Line + Image + Bullets + Body)
/// ------------------------------------------------------------------
class DualMirrorScene extends StatelessWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const DualMirrorScene({
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
        // Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A0E1A),
                Color(0xFF0C0D14),
              ],
            ),
          ),
        ),

        Row(
          children: [
            Expanded(
              child: _mirrorSide(
                context,
                title: scene.leftTitle,
                subtitle: scene.leftSubtitle,
                body: scene.leftBody,
                points: scene.leftKeyPoints,
                accent: scheme.primary,
                imageUrl: scene.leftImageUrl,
              ),
            ),

            // Divider Glow Line
            Container(
              width: 3,
              margin: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0),
                    Colors.white.withOpacity(.6),
                    Colors.white.withOpacity(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            Expanded(
              child: _mirrorSide(
                context,
                title: scene.rightTitle,
                subtitle: scene.rightSubtitle,
                body: scene.rightBody,
                points: scene.rightKeyPoints,
                accent: Colors.pinkAccent,
                imageUrl: scene.rightImageUrl,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _mirrorSide(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String body,
    required List<String> points,
    required Color accent,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE (top, optional)
          if (imageUrl.trim().isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Image.network(
                imageUrl,
                height: 210,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
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
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
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
                color: Colors.white.withOpacity(0.8),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Accent strip
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [
                        accent,
                        accent.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // TITLE (optional)
                if (title.trim().isNotEmpty)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                // SUBTITLE (optional)
                if (subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white60,
                    ),
                  ),
                ],

                // BODY (optional)
                if (body.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    body,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.3,
                      color: Colors.white70,
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // BULLETS (optional)
                if (points.isNotEmpty)
                  ...points.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              p,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

