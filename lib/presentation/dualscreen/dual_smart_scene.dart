import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

class DualSmartScene extends StatelessWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const DualSmartScene({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: _smartCard(
              context,
              title: scene.leftTitle,
              subtitle: scene.leftSubtitle,
              body: scene.leftBody,
              bullets: scene.leftKeyPoints,
              imageUrl: scene.leftImageUrl,
              accent: scheme.primary,
            ),
          ),

          SizedBox(
            width: 60,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: LinearGradient(
                    colors: [
                      scheme.primary,
                      Colors.pinkAccent,
                    ],
                  ),
                ),
                child: const Text(
                  "VS",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: _smartCard(
              context,
              title: scene.rightTitle,
              subtitle: scene.rightSubtitle,
              body: scene.rightBody,
              bullets: scene.rightKeyPoints,
              imageUrl: scene.rightImageUrl,
              accent: Colors.pinkAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smartCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String body,
    required List<String> bullets,
    required String imageUrl,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha:0.20),
            Colors.transparent,
          ],
        ),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ONLY show image if available
          if (imageUrl.trim().isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                imageUrl,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 110,
                  color: Colors.black45,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ONLY show title if exists
          if (title.trim().isNotEmpty)
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: accent,
              ),
            ),

          // ONLY show subtitle
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

          // ONLY show body text
          if (body.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              body,
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
                color: Colors.white,
              ),
            ),
          ],

          // ONLY show bullets if list exists
          if (bullets.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...bullets.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "• $p",
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],

          // OPTIONAL future placeholders:
          // (supports more with zero changes)

          // Footer note support
          // if(scene.footerNote != null) Show here

        ],
      ),
    );
  }
}
