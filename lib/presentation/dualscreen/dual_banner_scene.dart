import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

/// -----------------------------------------------------------------
/// 3) DUAL BANNER SCENE (Wide banner + Image + Body + Bullets)
/// -----------------------------------------------------------------
class DualBannerScene extends StatelessWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const DualBannerScene({
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
        // BG
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF02050A), Color(0xFF0C111A)],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: _bannerCard(
                  title: scene.leftTitle,
                  subtitle: scene.leftSubtitle,
                  body: scene.leftBody,
                  bullets: scene.leftKeyPoints,
                  color: scheme.primary,
                  imageUrl: scene.leftImageUrl,
                ),
              ),

              SizedBox(
                width: 60,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
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
                child: _bannerCard(
                  title: scene.rightTitle,
                  subtitle: scene.rightSubtitle,
                  body: scene.rightBody,
                  bullets: scene.rightKeyPoints,
                  color: Colors.pinkAccent,
                  imageUrl: scene.rightImageUrl,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bannerCard({
    required String title,
    required String subtitle,
    required String body,
    required List<String> bullets,
    required Color color,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha:0.20),
            Colors.transparent,
          ],
        ),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE (optional)
          if (imageUrl.trim().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                imageUrl,
                height: 210,
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
            )
          else
            Container(
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha:0.25),
                    color.withValues(alpha:0.05),
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.image_outlined,
                color: Colors.white.withValues(alpha:0.8),
              ),
            ),

          const SizedBox(height: 10),

          // Banner Title (optional)
          if (title.trim().isNotEmpty)
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),

          // Subtitle (optional)
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

          // Body (optional)
          if (body.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              body,
              style:  TextStyle(
                fontSize: 13,
                height: 1.3,
                color: Colors.white,
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Bullet points (optional)
          if (bullets.isNotEmpty)
            ...bullets.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $p',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
