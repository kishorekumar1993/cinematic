
import 'screen_config.dart';

/// ----------------------
/// MODELS (Animatic Archive)
/// ----------------------
class AnimaticArchive {
  final String version;
  final String title;
  final DateTime createdAt;
  final List<SceneConfig> scenes;

  AnimaticArchive({
    required this.version,
    required this.title,
    required this.createdAt,
    required this.scenes,
  });

  factory AnimaticArchive.fromJson(Map<String, dynamic> json) {
    return AnimaticArchive(
      version: json['version'] as String? ?? '1.0.0',
      title: json['title'] as String? ?? 'Untitled Animatic',
      createdAt: DateTime.parse(json['createdAt'] as String),
      scenes: (json['scenes'] as List<dynamic>)
          .map((e) => SceneConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'scenes': scenes.map((e) => e.toJson()).toList(),
    };
  }
}
