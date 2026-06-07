
import 'dart:typed_data';

class SceneConfig {
  final String id;
  final String templateId;
  final String title;
  final String subtitle;
  final String hook;
  final String body;
  final List<String> keyPoints;
  final String imageUrl;
  final int durationSeconds;
  final String effect;
  final String transitionOut;
  final String textEffect;
  final String voiceTone;
  final String musicStyle;
  final String animationInstructions;
  final String closureLine;

  /// Local uploaded image (not stored in JSON)
  final Uint8List? localImageBytes;
  final String? localImageName;

  /// NEW: LEFT side full details
  final String leftTitle;
  final String leftSubtitle;
  final String leftBody;
  final List<String> leftKeyPoints;
  final String leftImageUrl;

  /// NEW: RIGHT side full details
  final String rightTitle;
  final String rightSubtitle;
  final String rightBody;
  final List<String> rightKeyPoints;
  final String rightImageUrl;

  SceneConfig({
    required this.id,
    this.templateId = '',
    required this.title,
    required this.subtitle,
    required this.hook,
    required this.body,
    required this.keyPoints,
    required this.imageUrl,
    required this.durationSeconds,
    required this.effect,
    required this.transitionOut,
    required this.textEffect,
    required this.voiceTone,
    required this.musicStyle,
    required this.animationInstructions,
    required this.closureLine,
    this.localImageBytes,
    this.localImageName,

    /// NEW LEFT
    this.leftTitle = '',
    this.leftSubtitle = '',
    this.leftBody = '',
    this.leftKeyPoints = const [],
    this.leftImageUrl = '',

    /// NEW RIGHT
    this.rightTitle = '',
    this.rightSubtitle = '',
    this.rightBody = '',
    this.rightKeyPoints = const [],
    this.rightImageUrl = '',
  });

  factory SceneConfig.fromJson(Map<String, dynamic> json) {
    return SceneConfig(
      id: json['id'] as String,
      templateId: json['templateId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      hook: json['hook'] as String? ?? '',
      body: json['body'] as String? ?? '',
      keyPoints: (json['keyPoints'] as List?)
              ?.map((e) => (e ?? '').toString())
              .toList() ??
          const [],
      imageUrl: json['imageUrl'] as String? ?? '',
      durationSeconds: json['durationSeconds'] as int? ?? 8,
      effect: json['effect'] as String? ?? 'zoom_in',
      transitionOut: json['transitionOut'] as String? ?? 'fade',
      textEffect: json['textEffect'] as String? ?? 'fade',
      voiceTone: json['voiceTone'] as String? ?? '',
      musicStyle: json['musicStyle'] as String? ?? '',
      animationInstructions: json['animationInstructions'] as String? ?? '',
      closureLine: json['closureLine'] as String? ?? '',
      localImageBytes: null,
      localImageName: null,

      // NEW LEFT
      leftTitle: json['leftTitle'] as String? ?? '',
      leftSubtitle: json['leftSubtitle'] as String? ?? '',
      leftBody: json['leftBody'] as String? ?? '',
      leftKeyPoints: (json['leftKeyPoints'] as List?)
              ?.map((e) => (e ?? '').toString())
              .toList() ??
          const [],
      leftImageUrl: json['leftImageUrl'] as String? ?? '',

      // NEW RIGHT
      rightTitle: json['rightTitle'] as String? ?? '',
      rightSubtitle: json['rightSubtitle'] as String? ?? '',
      rightBody: json['rightBody'] as String? ?? '',
      rightKeyPoints: (json['rightKeyPoints'] as List?)
              ?.map((e) => (e ?? '').toString())
              .toList() ??
          const [],
      rightImageUrl: json['rightImageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'title': title,
      'subtitle': subtitle,
      'hook': hook,
      'body': body,
      'keyPoints': keyPoints,
      'imageUrl': imageUrl,
      'durationSeconds': durationSeconds,
      'effect': effect,
      'transitionOut': transitionOut,
      'textEffect': textEffect,
      'voiceTone': voiceTone,
      'musicStyle': musicStyle,
      'animationInstructions': animationInstructions,
      'closureLine': closureLine,

      // NEW LEFT
      'leftTitle': leftTitle,
      'leftSubtitle': leftSubtitle,
      'leftBody': leftBody,
      'leftKeyPoints': leftKeyPoints,
      'leftImageUrl': leftImageUrl,

      // NEW RIGHT
      'rightTitle': rightTitle,
      'rightSubtitle': rightSubtitle,
      'rightBody': rightBody,
      'rightKeyPoints': rightKeyPoints,
      'rightImageUrl': rightImageUrl,
    };
  }
}
