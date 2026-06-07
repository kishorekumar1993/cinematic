
import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// SMALL THUMBNAIL
/// ----------------------

class SceneThumbnail extends StatelessWidget {
  final SceneConfig scene;
  final int index;
  final bool isActive;

  const SceneThumbnail({
    super.key,
    required this.scene,
    required this.index,
    this.isActive = false,
  });

  Widget _buildThumbImage(SceneConfig scene) {
    if (scene.localImageBytes != null) {
      return Image.memory(
        scene.localImageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade900,
          child: const Icon(Icons.image_not_supported),
        ),
      );
    }

    if (scene.imageUrl.isNotEmpty) {
      return Image.network(
        scene.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade900,
          child: const Icon(Icons.image_not_supported),
        ),
      );
    }

    return Container(
      color: Colors.grey.shade900,
      child: const Icon(Icons.image_not_supported),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = isActive
        ? Theme.of(context).colorScheme.primary
        : Colors.white.withValues(alpha:0.15);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildThumbImage(scene),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha:0.7),
                        Colors.black.withValues(alpha:0.0),
                      ],
                    ),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      '${index + 1}. ${scene.title}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha:0.7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

