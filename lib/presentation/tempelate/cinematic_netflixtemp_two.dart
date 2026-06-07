import 'dart:ui';
import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

/// --------------------------------------------------
/// FULL SCREEN FRAME FOR TOP 5 LIST
/// Wraps CinematicTopFiveMovieScene in a proper screen
/// --------------------------------------------------
class CinematicNetflixTempTwo extends StatelessWidget {
  final SceneConfig scene;
  final bool isPlaying;
  final VoidCallback? onBack;
  final double progress; // 0.0 - 1.0 (for bottom timeline)

  const CinematicNetflixTempTwo({
    super.key,
    required this.scene,
    this.isPlaying = true,
    this.onBack,
    this.progress = 0.4, // demo value
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main cinematic scene
            CinematicNetflixTempTwo(
              scene: scene,
              isPlaying: isPlaying,
            ),

            // Top app bar frame (overlay)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: onBack ?? () => Navigator.maybePop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 0.8,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Center info (Year + label)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "2025 • TOP 5 LIST",
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.4,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          scene.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Category pill (subtitle)
                  if (scene.subtitle.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        scene.subtitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.3,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom progress frame (timeline)
            Positioned(
              left: 16,
              right: 16,
              bottom: 6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tiny visual timeline
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.redAccent.withOpacity(0.9),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Duration / hint
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isPlaying ? "Playing Top 5" : "Paused",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        "${scene.durationSeconds}s",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
