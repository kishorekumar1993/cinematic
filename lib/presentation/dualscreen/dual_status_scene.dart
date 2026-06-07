import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';
/// ---------------------------------------------------------------
/// 2) DUAL STATS SCENE (Image + Badge + Bullets + Optional Body)
/// ---------------------------------------------------------------
class DualStatsScene extends StatelessWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const DualStatsScene({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    final leftColor = Colors.blueAccent;
    final rightColor = Colors.orangeAccent;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _statSide(
              title: scene.leftTitle,
              subtitle: scene.leftSubtitle,
              body: scene.leftBody,
              bullets: scene.leftKeyPoints,
              color: leftColor,
              imageUrl: scene.leftImageUrl,
            ),
          ),

          SizedBox(
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "VS",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _statSide(
              title: scene.rightTitle,
              subtitle: scene.rightSubtitle,
              body: scene.rightBody,
              bullets: scene.rightKeyPoints,
              color: rightColor,
              imageUrl: scene.rightImageUrl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statSide({
    required String title,
    required String subtitle,
    required String body,
    required List<String> bullets,
    required Color color,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE / AVATAR (optional)
          if (imageUrl.trim().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
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
            )
          else
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.25),
                    color.withOpacity(0.05),
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.image_outlined,
                color: Colors.white.withOpacity(0.8),
              ),
            ),

          const SizedBox(height: 10),

          // BADGE (optional – only if title)
          if (title.trim().isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

          // SUBTITLE (optional)
          if (subtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],

          // BODY (optional)
          if (body.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              body,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                height: 1.3,
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Bullet / Stat lines (optional)
          if (bullets.isNotEmpty)
            ...bullets.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

