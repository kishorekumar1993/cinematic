import 'dart:async';
import 'dart:typed_data';

import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/presentation/dualscreen/dual_category_scene_screen.dart';
import 'package:cinematic/presentation/tempelate/cinematic_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// SCENE EDITOR BOTTOM SHEET (DUAL)
/// ----------------------

class SceneEditorSheet extends StatefulWidget {
  final SceneConfig scene;
  final bool isNew;

  const SceneEditorSheet({super.key, required this.scene, this.isNew = false});

/// Place this inside your SceneEditorSheet (static method) or a separate helper file.
static Future<SceneConfig?> openSafe(
  BuildContext requestContext,
  SceneConfig scene, {
  bool isNew = false,
}) {
  final completer = Completer<SceneConfig?>();
  // single-call guard to avoid multiple concurrent opens (optional)
  bool _opening = false;

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // avoid calling if already opening
    if (_opening) {
      completer.complete(null);
      return;
    }
    _opening = true;

    try {
      // Guard 1: ensure requestContext is still mounted
      if (!requestContext.mounted) {
        if (kDebugMode) debugPrint('SceneEditorSheet.openSafe: context not mounted');
        completer.complete(null);
        _opening = false;
        return;
      }

      // Guard 2: check app lifecycle (avoid calling when detached)
      final lifecycle = WidgetsBinding.instance.lifecycleState;
      if (lifecycle == AppLifecycleState.detached) {
        if (kDebugMode) debugPrint('SceneEditorSheet.openSafe: app detached');
        completer.complete(null);
        _opening = false;
        return;
      }

      // Guard 3: use try/catch around showModalBottomSheet to avoid engine errors
      SceneConfig? result;
      try {
        result = await showModalBottomSheet<SceneConfig>(
          context: requestContext,
          isScrollControlled: true,
          backgroundColor: const Color(0xFF11131B),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (ctx) => SceneEditorSheet(scene: scene, isNew: isNew),
        );
      } catch (e, st) {
        // sometimes the engine/view may be disposed between scheduling and render;
        // catch and log in debug but do not crash the app.
        if (kDebugMode) {
          debugPrint('SceneEditorSheet.openSafe: showModalBottomSheet threw: $e\n$st');
        }
        result = null;
      }

      completer.complete(result);
    } finally {
      _opening = false;
    }
  });

  return completer.future;
}

  @override
  State<SceneEditorSheet> createState() => _SceneEditorSheetState();
}

class _SceneEditorSheetState extends State<SceneEditorSheet> {
  // BASE
  late TextEditingController _titleCtrl;
  late TextEditingController _subtitleCtrl;
  late TextEditingController _hookCtrl;
  late TextEditingController _bodyCtrl;
  late TextEditingController _keyPointsCtrl;
  late TextEditingController _imageUrlCtrl;
  late TextEditingController _voiceToneCtrl;
  late TextEditingController _musicStyleCtrl;
  late TextEditingController _durationCtrl;
  late TextEditingController _animationInstructionsCtrl;
  late TextEditingController _closureLineCtrl;

  // NEW: LEFT
  late TextEditingController _leftTitleCtrl;
  late TextEditingController _leftSubtitleCtrl;
  late TextEditingController _leftBodyCtrl;
  late TextEditingController _leftKeyPointsCtrl;
  late TextEditingController _leftImageUrlCtrl;

  // NEW: RIGHT
  late TextEditingController _rightTitleCtrl;
  late TextEditingController _rightSubtitleCtrl;
  late TextEditingController _rightBodyCtrl;
  late TextEditingController _rightKeyPointsCtrl;
  late TextEditingController _rightImageUrlCtrl;

  late String _selectedEffect;
  late String _selectedTextEffect;
  late String _selectedTransition;

  final List<String> _effects = const [
    'zoom_in',
    'zoom_out',
    'pan_left',
    'pan_right',
    'dual_category', // dual template
  ];

  final List<String> _textEffects = const [
    'fade',
    'slide_up',
    'slide_left',
    'typewriter',
  ];

  final List<String> _transitions = const ['fade', 'none'];

  SceneConfig? _previewScene;
  Key _previewKey = UniqueKey();

  Uint8List? _localImageBytes;
  String? _localImageName;

  @override
  void initState() {
    super.initState();
    final s = widget.scene;

    // base
    _titleCtrl = TextEditingController(text: s.title);
    _subtitleCtrl = TextEditingController(text: s.subtitle);
    _hookCtrl = TextEditingController(text: s.hook);
    _bodyCtrl = TextEditingController(text: s.body);
    _keyPointsCtrl = TextEditingController(text: s.keyPoints.join('\n'));
    _imageUrlCtrl = TextEditingController(text: s.imageUrl);
    _voiceToneCtrl = TextEditingController(text: s.voiceTone);
    _musicStyleCtrl = TextEditingController(text: s.musicStyle);
    _durationCtrl = TextEditingController(text: s.durationSeconds.toString());
    _animationInstructionsCtrl = TextEditingController(
      text: s.animationInstructions,
    );
    _closureLineCtrl = TextEditingController(text: s.closureLine);

    // left
    _leftTitleCtrl = TextEditingController(text: s.leftTitle);
    _leftSubtitleCtrl = TextEditingController(text: s.leftSubtitle);
    _leftBodyCtrl = TextEditingController(text: s.leftBody);
    _leftKeyPointsCtrl = TextEditingController(
      text: s.leftKeyPoints.join('\n'),
    );
    _leftImageUrlCtrl = TextEditingController(text: s.leftImageUrl);

    // right
    _rightTitleCtrl = TextEditingController(text: s.rightTitle);
    _rightSubtitleCtrl = TextEditingController(text: s.rightSubtitle);
    _rightBodyCtrl = TextEditingController(text: s.rightBody);
    _rightKeyPointsCtrl = TextEditingController(
      text: s.rightKeyPoints.join('\n'),
    );
    _rightImageUrlCtrl = TextEditingController(text: s.rightImageUrl);

    _selectedEffect = _effects.contains(s.effect) ? s.effect : 'zoom_in';
    _selectedTextEffect = _textEffects.contains(s.textEffect)
        ? s.textEffect
        : 'fade';
    _selectedTransition = _transitions.contains(s.transitionOut)
        ? s.transitionOut
        : 'fade';

    _localImageBytes = s.localImageBytes;
    _localImageName = s.localImageName;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _hookCtrl.dispose();
    _bodyCtrl.dispose();
    _keyPointsCtrl.dispose();
    _imageUrlCtrl.dispose();
    _voiceToneCtrl.dispose();
    _musicStyleCtrl.dispose();
    _durationCtrl.dispose();
    _animationInstructionsCtrl.dispose();
    _closureLineCtrl.dispose();

    _leftTitleCtrl.dispose();
    _leftSubtitleCtrl.dispose();
    _leftBodyCtrl.dispose();
    _leftKeyPointsCtrl.dispose();
    _leftImageUrlCtrl.dispose();

    _rightTitleCtrl.dispose();
    _rightSubtitleCtrl.dispose();
    _rightBodyCtrl.dispose();
    _rightKeyPointsCtrl.dispose();
    _rightImageUrlCtrl.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      final Uint8List? safeBytes = file.bytes;

      if (safeBytes == null) {
        if (kDebugMode) {
          debugPrint(
            'Cannot read image bytes. bytes is null for file: ${file.name}',
          );
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot read image bytes on this platform'),
          ),
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _localImageBytes = safeBytes;
        _localImageName = file.name;

        if (_imageUrlCtrl.text.trim().isEmpty) {
          _imageUrlCtrl.text = 'local://${file.name}';
        }

        _previewScene = _buildSceneFromInputs();
        _previewKey = UniqueKey();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Selected: ${file.name}')));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Error picking image: $e\n$st');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  SceneConfig _buildSceneFromInputs() {
    final duration = int.tryParse(_durationCtrl.text.trim()) ?? 8;

    final keyPoints = _keyPointsCtrl.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final leftKeyPoints = _leftKeyPointsCtrl.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final rightKeyPoints = _rightKeyPointsCtrl.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return SceneConfig(
      id: widget.scene.id,
      title: _titleCtrl.text.trim(),
      subtitle: _subtitleCtrl.text.trim(),
      hook: _hookCtrl.text.trim(),
      body: _bodyCtrl.text.trim(),
      keyPoints: keyPoints,
      imageUrl: _imageUrlCtrl.text.trim(),
      durationSeconds: duration,
      effect: _selectedEffect,
      transitionOut: _selectedTransition,
      textEffect: _selectedTextEffect,
      voiceTone: _voiceToneCtrl.text.trim(),
      musicStyle: _musicStyleCtrl.text.trim(),
      animationInstructions: _animationInstructionsCtrl.text.trim(),
      closureLine: _closureLineCtrl.text.trim(),
      localImageBytes: _localImageBytes,
      localImageName: _localImageName,

      // LEFT
      leftTitle: _leftTitleCtrl.text.trim(),
      leftSubtitle: _leftSubtitleCtrl.text.trim(),
      leftBody: _leftBodyCtrl.text.trim(),
      leftKeyPoints: leftKeyPoints,
      leftImageUrl: _leftImageUrlCtrl.text.trim(),

      // RIGHT
      rightTitle: _rightTitleCtrl.text.trim(),
      rightSubtitle: _rightSubtitleCtrl.text.trim(),
      rightBody: _rightBodyCtrl.text.trim(),
      rightKeyPoints: rightKeyPoints,
      rightImageUrl: _rightImageUrlCtrl.text.trim(),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We return a DraggableScrollableSheet so the host showModalBottomSheet can
    // control height and content will scroll properly without overflow.
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        // Use a ListView with the provided controller so the sheet is scrollable.
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // drag handle & title row
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    widget.isNew ? 'Add Scene' : 'Edit Scene',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    // ListView handles content of the sheet; controller enables draggable scrolling
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Base Scene',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _field('Title', _titleCtrl),
                        _field('Subtitle', _subtitleCtrl),
                        _field('Hook (optional)', _hookCtrl, maxLines: 2),
                        _field('Body', _bodyCtrl, maxLines: 4),
                        _field(
                          'Key Points (one per line)',
                          _keyPointsCtrl,
                          maxLines: 4,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _field(
                                'Background Image URL',
                                _imageUrlCtrl,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: _pickImage,
                                  tooltip: 'Upload Image',
                                  icon: const Icon(Icons.upload_file),
                                ),
                                if (_localImageName != null)
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      'Selected:\n$_localImageName',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        _dropdownField(
                          label: 'Image / Scene Effect',
                          value: _selectedEffect,
                          items: _effects,
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _selectedEffect = v);
                            }
                          },
                        ),
                        _dropdownField(
                          label: 'Text Effect',
                          value: _selectedTextEffect,
                          items: _textEffects,
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _selectedTextEffect = v);
                            }
                          },
                        ),
                        _dropdownField(
                          label: 'Transition Out',
                          value: _selectedTransition,
                          items: _transitions,
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _selectedTransition = v);
                            }
                          },
                        ),
                        _field('Voice Tone', _voiceToneCtrl),
                        _field('Music Style', _musicStyleCtrl),
                        _field(
                          'Duration (seconds)',
                          _durationCtrl,
                          keyboardType: TextInputType.number,
                        ),
                        _field(
                          'Animation Instructions',
                          _animationInstructionsCtrl,
                          maxLines: 3,
                        ),
                        _field(
                          'Closure Line (optional)',
                          _closureLineCtrl,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Colors.white.withValues(alpha: 0.2)),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Dual Comparison (Left & Right)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LEFT',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _field('Left Title', _leftTitleCtrl),
                                  _field('Left Subtitle', _leftSubtitleCtrl),
                                  _field(
                                    'Left Body',
                                    _leftBodyCtrl,
                                    maxLines: 3,
                                  ),
                                  _field(
                                    'Left Key Points (one per line)',
                                    _leftKeyPointsCtrl,
                                    maxLines: 3,
                                  ),
                                  _field('Left Image URL', _leftImageUrlCtrl),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RIGHT',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _field('Right Title', _rightTitleCtrl),
                                  _field('Right Subtitle', _rightSubtitleCtrl),
                                  _field(
                                    'Right Body',
                                    _rightBodyCtrl,
                                    maxLines: 3,
                                  ),
                                  _field(
                                    'Right Key Points (one per line)',
                                    _rightKeyPointsCtrl,
                                    maxLines: 3,
                                  ),
                                  _field('Right Image URL', _rightImageUrlCtrl),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tip: For comparison template, set Effect = dual_category.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Preview Scene',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _previewScene == null
                                  ? Center(
                                      child: Text(
                                        'Press "Preview" below to see this scene',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                    )
                                  : (_previewScene!.effect == 'dual_category'
                                        ? DualCategoryScene(
                                            key: _previewKey,
                                            scene: _previewScene!,
                                            isPlaying: true,
                                          )
                                        : CinematicScene(
                                            key: _previewKey,
                                            scene: _previewScene!,
                                            isPlaying: true,
                                          )),
                            ),
                          ),
                        ),

                        // bottom spacing so the buttons are tappable above the sheet edge
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _previewScene = _buildSceneFromInputs();
                            _previewKey = UniqueKey();
                          });
                        },
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('Preview'),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () {
                              final updated = _buildSceneFromInputs();
                              Navigator.pop(context, updated);
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// import 'package:cinematic/model/screen_config.dart';
// import 'package:cinematic/presentation/dualscreen/dual_category_scene_screen.dart';
// import 'package:cinematic/presentation/tempelate/cinematic_screen.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// /// ----------------------
// /// SCENE EDITOR BOTTOM SHEET (DUAL)
// /// ----------------------

// class SceneEditorSheet extends StatefulWidget {
//   final SceneConfig scene;
//   final bool isNew;

//   const SceneEditorSheet({
//     super.key,
//     required this.scene,
//     this.isNew = false,
//   });

//   @override
//   State<SceneEditorSheet> createState() => _SceneEditorSheetState();
// }

// class _SceneEditorSheetState extends State<SceneEditorSheet> {
//   // BASE
//   late TextEditingController _titleCtrl;
//   late TextEditingController _subtitleCtrl;
//   late TextEditingController _hookCtrl;
//   late TextEditingController _bodyCtrl;
//   late TextEditingController _keyPointsCtrl;
//   late TextEditingController _imageUrlCtrl;
//   late TextEditingController _voiceToneCtrl;
//   late TextEditingController _musicStyleCtrl;
//   late TextEditingController _durationCtrl;
//   late TextEditingController _animationInstructionsCtrl;
//   late TextEditingController _closureLineCtrl;

//   // NEW: LEFT
//   late TextEditingController _leftTitleCtrl;
//   late TextEditingController _leftSubtitleCtrl;
//   late TextEditingController _leftBodyCtrl;
//   late TextEditingController _leftKeyPointsCtrl;
//   late TextEditingController _leftImageUrlCtrl;

//   // NEW: RIGHT
//   late TextEditingController _rightTitleCtrl;
//   late TextEditingController _rightSubtitleCtrl;
//   late TextEditingController _rightBodyCtrl;
//   late TextEditingController _rightKeyPointsCtrl;
//   late TextEditingController _rightImageUrlCtrl;

//   late String _selectedEffect;
//   late String _selectedTextEffect;
//   late String _selectedTransition;

//   final List<String> _effects = const [
//     'zoom_in',
//     'zoom_out',
//     'pan_left',
//     'pan_right',
//     'dual_category', // dual template
//   ];

//   final List<String> _textEffects = const [
//     'fade',
//     'slide_up',
//     'slide_left',
//     'typewriter',
//   ];

//   final List<String> _transitions = const [
//     'fade',
//     'none',
//   ];

//   SceneConfig? _previewScene;
//   Key _previewKey = UniqueKey();

//   Uint8List? _localImageBytes;
//   String? _localImageName;

//   @override
//   void initState() {
//     super.initState();
//     final s = widget.scene;

//     // base
//     _titleCtrl = TextEditingController(text: s.title);
//     _subtitleCtrl = TextEditingController(text: s.subtitle);
//     _hookCtrl = TextEditingController(text: s.hook);
//     _bodyCtrl = TextEditingController(text: s.body);
//     _keyPointsCtrl = TextEditingController(text: s.keyPoints.join('\n'));
//     _imageUrlCtrl = TextEditingController(text: s.imageUrl);
//     _voiceToneCtrl = TextEditingController(text: s.voiceTone);
//     _musicStyleCtrl = TextEditingController(text: s.musicStyle);
//     _durationCtrl = TextEditingController(text: s.durationSeconds.toString());
//     _animationInstructionsCtrl =
//         TextEditingController(text: s.animationInstructions);
//     _closureLineCtrl = TextEditingController(text: s.closureLine);

//     // left
//     _leftTitleCtrl = TextEditingController(text: s.leftTitle);
//     _leftSubtitleCtrl = TextEditingController(text: s.leftSubtitle);
//     _leftBodyCtrl = TextEditingController(text: s.leftBody);
//     _leftKeyPointsCtrl =
//         TextEditingController(text: s.leftKeyPoints.join('\n'));
//     _leftImageUrlCtrl = TextEditingController(text: s.leftImageUrl);

//     // right
//     _rightTitleCtrl = TextEditingController(text: s.rightTitle);
//     _rightSubtitleCtrl = TextEditingController(text: s.rightSubtitle);
//     _rightBodyCtrl = TextEditingController(text: s.rightBody);
//     _rightKeyPointsCtrl =
//         TextEditingController(text: s.rightKeyPoints.join('\n'));
//     _rightImageUrlCtrl = TextEditingController(text: s.rightImageUrl);

//     _selectedEffect = _effects.contains(s.effect) ? s.effect : 'zoom_in';
//     _selectedTextEffect =
//         _textEffects.contains(s.textEffect) ? s.textEffect : 'fade';
//     _selectedTransition =
//         _transitions.contains(s.transitionOut) ? s.transitionOut : 'fade';

//     _localImageBytes = s.localImageBytes;
//     _localImageName = s.localImageName;
//   }

//   @override
//   void dispose() {
//     _titleCtrl.dispose();
//     _subtitleCtrl.dispose();
//     _hookCtrl.dispose();
//     _bodyCtrl.dispose();
//     _keyPointsCtrl.dispose();
//     _imageUrlCtrl.dispose();
//     _voiceToneCtrl.dispose();
//     _musicStyleCtrl.dispose();
//     _durationCtrl.dispose();
//     _animationInstructionsCtrl.dispose();
//     _closureLineCtrl.dispose();

//     _leftTitleCtrl.dispose();
//     _leftSubtitleCtrl.dispose();
//     _leftBodyCtrl.dispose();
//     _leftKeyPointsCtrl.dispose();
//     _leftImageUrlCtrl.dispose();

//     _rightTitleCtrl.dispose();
//     _rightSubtitleCtrl.dispose();
//     _rightBodyCtrl.dispose();
//     _rightKeyPointsCtrl.dispose();
//     _rightImageUrlCtrl.dispose();

//     super.dispose();
//   }

//   Future<void> _pickImage() async {
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.image,
//         allowMultiple: false,
//         withData: true,
//       );

//       if (result == null || result.files.isEmpty) {
//         return;
//       }

//       final file = result.files.single;
//       final Uint8List? safeBytes = file.bytes;

//       if (safeBytes == null) {
//         if (kDebugMode) {
//           debugPrint(
//               'Cannot read image bytes. bytes is null for file: ${file.name}');
//         }
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Cannot read image bytes on this platform')),
//         );
//         return;
//       }

//       if (!mounted) return;
//       setState(() {
//         _localImageBytes = safeBytes;
//         _localImageName = file.name;

//         if (_imageUrlCtrl.text.trim().isEmpty) {
//           _imageUrlCtrl.text = 'local://${file.name}';
//         }

//         _previewScene = _buildSceneFromInputs();
//         _previewKey = UniqueKey();
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Selected: ${file.name}')),
//       );
//     } catch (e, st) {
//       if (kDebugMode) {
//         debugPrint('Error picking image: $e\n$st');
//       }
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking image: $e')),
//       );
//     }
//   }

//   SceneConfig _buildSceneFromInputs() {
//     final duration = int.tryParse(_durationCtrl.text.trim()) ?? 8;

//     final keyPoints = _keyPointsCtrl.text
//         .split('\n')
//         .map((e) => e.trim())
//         .where((e) => e.isNotEmpty)
//         .toList();

//     final leftKeyPoints = _leftKeyPointsCtrl.text
//         .split('\n')
//         .map((e) => e.trim())
//         .where((e) => e.isNotEmpty)
//         .toList();

//     final rightKeyPoints = _rightKeyPointsCtrl.text
//         .split('\n')
//         .map((e) => e.trim())
//         .where((e) => e.isNotEmpty)
//         .toList();

//     return SceneConfig(
//       id: widget.scene.id,
//       title: _titleCtrl.text.trim(),
//       subtitle: _subtitleCtrl.text.trim(),
//       hook: _hookCtrl.text.trim(),
//       body: _bodyCtrl.text.trim(),
//       keyPoints: keyPoints,
//       imageUrl: _imageUrlCtrl.text.trim(),
//       durationSeconds: duration,
//       effect: _selectedEffect,
//       transitionOut: _selectedTransition,
//       textEffect: _selectedTextEffect,
//       voiceTone: _voiceToneCtrl.text.trim(),
//       musicStyle: _musicStyleCtrl.text.trim(),
//       animationInstructions: _animationInstructionsCtrl.text.trim(),
//       closureLine: _closureLineCtrl.text.trim(),
//       localImageBytes: _localImageBytes,
//       localImageName: _localImageName,

//       // LEFT
//       leftTitle: _leftTitleCtrl.text.trim(),
//       leftSubtitle: _leftSubtitleCtrl.text.trim(),
//       leftBody: _leftBodyCtrl.text.trim(),
//       leftKeyPoints: leftKeyPoints,
//       leftImageUrl: _leftImageUrlCtrl.text.trim(),

//       // RIGHT
//       rightTitle: _rightTitleCtrl.text.trim(),
//       rightSubtitle: _rightSubtitleCtrl.text.trim(),
//       rightBody: _rightBodyCtrl.text.trim(),
//       rightKeyPoints: rightKeyPoints,
//       rightImageUrl: _rightImageUrlCtrl.text.trim(),
//     );
//   }

//   Widget _field(
//     String label,
//     TextEditingController controller, {
//     int maxLines = 1,
//     TextInputType? keyboardType,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextField(
//         controller: controller,
//         maxLines: maxLines,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _dropdownField({
//     required String label,
//     required String value,
//     required List<String> items,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         items: items
//             .map(
//               (e) => DropdownMenuItem(
//                 value: e,
//                 child: Text(e),
//               ),
//             )
//             .toList(),
//         onChanged: onChanged,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final media = MediaQuery.of(context);
//     final bottomInset = media.viewInsets.bottom;

//     return Padding(
//       padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
//       child: SafeArea(
//         top: false,
//         child: SizedBox(
//           height: media.size.height * 0.85,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 48,
//                   height: 4,
//                   margin: const EdgeInsets.only(bottom: 12),
//                   decoration: BoxDecoration(
//                     color: Colors.white24,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               Text(
//                 widget.isNew ? 'Add Scene' : 'Edit Scene',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Base Scene',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color:
//                                 Colors.white.withValues(alpha: 0.85),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       _field('Title', _titleCtrl),
//                       _field('Subtitle', _subtitleCtrl),
//                       _field('Hook (optional)', _hookCtrl, maxLines: 2),
//                       _field('Body', _bodyCtrl, maxLines: 4),
//                       _field(
//                         'Key Points (one per line)',
//                         _keyPointsCtrl,
//                         maxLines: 4,
//                       ),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: _field(
//                               'Background Image URL',
//                               _imageUrlCtrl,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Column(
//                             children: [
//                               IconButton(
//                                 onPressed: _pickImage,
//                                 tooltip: 'Upload Image',
//                                 icon: const Icon(Icons.upload_file),
//                               ),
//                               if (_localImageName != null)
//                                 SizedBox(
//                                   width: 120,
//                                   child: Text(
//                                     'Selected:\n$_localImageName',
//                                     style: TextStyle(
//                                       fontSize: 10,
//                                       color: Colors.white
//                                           .withValues(alpha: 0.7),
//                                     ),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       _dropdownField(
//                         label: 'Image / Scene Effect',
//                         value: _selectedEffect,
//                         items: _effects,
//                         onChanged: (v) {
//                           if (v != null) {
//                             setState(() => _selectedEffect = v);
//                           }
//                         },
//                       ),
//                       _dropdownField(
//                         label: 'Text Effect',
//                         value: _selectedTextEffect,
//                         items: _textEffects,
//                         onChanged: (v) {
//                           if (v != null) {
//                             setState(() => _selectedTextEffect = v);
//                           }
//                         },
//                       ),
//                       _dropdownField(
//                         label: 'Transition Out',
//                         value: _selectedTransition,
//                         items: _transitions,
//                         onChanged: (v) {
//                           if (v != null) {
//                             setState(() => _selectedTransition = v);
//                           }
//                         },
//                       ),
//                       _field('Voice Tone', _voiceToneCtrl),
//                       _field('Music Style', _musicStyleCtrl),
//                       _field(
//                         'Duration (seconds)',
//                         _durationCtrl,
//                         keyboardType: TextInputType.number,
//                       ),
//                       _field(
//                         'Animation Instructions',
//                         _animationInstructionsCtrl,
//                         maxLines: 3,
//                       ),
//                       _field(
//                         'Closure Line (optional)',
//                         _closureLineCtrl,
//                         maxLines: 2,
//                       ),
//                       const SizedBox(height: 16),
//                       Divider(color: Colors.white.withValues(alpha: 0.2)),
//                       const SizedBox(height: 8),
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Dual Comparison (Left & Right)',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color:
//                                 Colors.white.withValues(alpha: 0.9),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'LEFT',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.white
//                                         .withValues(alpha: 0.8),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 _field('Left Title', _leftTitleCtrl),
//                                 _field('Left Subtitle', _leftSubtitleCtrl),
//                                 _field('Left Body', _leftBodyCtrl,
//                                     maxLines: 3),
//                                 _field(
//                                   'Left Key Points (one per line)',
//                                   _leftKeyPointsCtrl,
//                                   maxLines: 3,
//                                 ),
//                                 _field(
//                                   'Left Image URL',
//                                   _leftImageUrlCtrl,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'RIGHT',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.white
//                                         .withValues(alpha: 0.8),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 _field('Right Title', _rightTitleCtrl),
//                                 _field('Right Subtitle', _rightSubtitleCtrl),
//                                 _field('Right Body', _rightBodyCtrl,
//                                     maxLines: 3),
//                                 _field(
//                                   'Right Key Points (one per line)',
//                                   _rightKeyPointsCtrl,
//                                   maxLines: 3,
//                                 ),
//                                 _field(
//                                   'Right Image URL',
//                                   _rightImageUrlCtrl,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Tip: For comparison template, set Effect = dual_category.',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color:
//                                 Colors.white.withValues(alpha: 0.7),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Preview Scene',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color:
//                                 Colors.white.withValues(alpha: 0.8),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       SizedBox(
//                         height: 200,
//                         child: DecoratedBox(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(
//                               color: Colors.white.withValues(alpha: 0.12),
//                             ),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(16),
//                             child: _previewScene == null
//                                 ? Center(
//                                     child: Text(
//                                       'Press "Preview" below to see this scene',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.white
//                                             .withValues(alpha: 0.7),
//                                       ),
//                                     ),
//                                   )
//                                 : (_previewScene!.effect ==
//                                         'dual_category'
//                                     ? DualCategoryScene(
//                                         key: _previewKey,
//                                         scene: _previewScene!,
//                                         isPlaying: true,
//                                       )
//                                     : CinematicScene(
//                                         key: _previewKey,
//                                         scene: _previewScene!,
//                                         isPlaying: true,
//                                       )),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   OutlinedButton.icon(
//                     onPressed: () {
//                       setState(() {
//                         _previewScene = _buildSceneFromInputs();
//                         _previewKey = UniqueKey();
//                       });
//                     },
//                     icon: const Icon(Icons.play_circle_outline),
//                     label: const Text('Preview'),
//                   ),
//                   Row(
//                     children: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text('Cancel'),
//                       ),
//                       const SizedBox(width: 8),
//                       FilledButton(
//                         onPressed: () {
//                           final updated = _buildSceneFromInputs();
//                           Navigator.pop(context, updated);
//                         },
//                         child: const Text('Save'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
