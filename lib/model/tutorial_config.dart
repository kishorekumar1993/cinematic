import 'dart:typed_data';

import 'package:cinematic/model/screen_config.dart';

class TutorialConfig {
  final String id;
  final String title;
  final String subtitle;          // optional era / section label
  final String body;              // introductory paragraph
  final List<String> steps;       // numbered step instructions
  final String codeSnippet;       // code block (markdown / plain)
  final String tip;               // pro tip / note
  final String imageUrl;          // background image
  final Uint8List? localImageBytes; // local fallback
  final int durationSeconds;      // scene duration (5-90 sec)
  final String effect;            // zoom_in, zoom_out, pan_right, pan_left
  final String textEffect;        // fade, slide_up, slide_down, slide_left, slide_right

  TutorialConfig({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.body = '',
    required this.steps,
    this.codeSnippet = '',
    this.tip = '',
    this.imageUrl = '',
    this.localImageBytes,
    required this.durationSeconds,
    this.effect = 'zoom_in',
    this.textEffect = 'fade',
  });

  factory TutorialConfig.fromJson(Map<String, dynamic> json) {
    return TutorialConfig(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      body: json['body'] as String? ?? '',
      steps: (json['steps'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      codeSnippet: json['codeSnippet'] as String? ?? '',
      tip: json['tip'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      durationSeconds: json['durationSeconds'] as int? ?? 8,
      effect: json['effect'] as String? ?? 'zoom_in',
      textEffect: json['textEffect'] as String? ?? 'fade',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'body': body,
      'steps': steps,
      'codeSnippet': codeSnippet,
      'tip': tip,
      'imageUrl': imageUrl,
      'durationSeconds': durationSeconds,
      'effect': effect,
      'textEffect': textEffect,
    };
  }

  /// Optional: convert from existing SceneConfig (if you already have one)
  factory TutorialConfig.fromSceneConfig(SceneConfig scene) {
    return TutorialConfig(
      id: scene.id,
      title: scene.title,
      subtitle: scene.subtitle,
      body: scene.body,
      steps: scene.keyPoints,          // SceneConfig's keyPoints become steps
      codeSnippet: scene.hook,         // hook becomes code snippet
      tip: scene.closureLine,          // closureLine becomes tip
      imageUrl: scene.imageUrl,
      localImageBytes: scene.localImageBytes,
      durationSeconds: scene.durationSeconds,
      effect: scene.effect,
      textEffect: scene.textEffect,
    );
  }
}