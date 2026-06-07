import 'dart:async';
import 'dart:convert';

import 'package:cinematic/model/animation_archieve.dart';
import 'package:cinematic/model/sample_data.dart';
import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/presentation/cinematic_player.dart';
import 'package:cinematic/presentation/full_preview.dart';
import 'package:cinematic/presentation/scene_thumblain.dart';
import 'package:cinematic/presentation/screen_editor.dart';
import 'package:cinematic/presentation/bulk_generator_sheet.dart';
import 'package:cinematic/video/frame_video_exporter.dart';
import 'package:cinematic/video/video_export_service.dart';
import 'package:cinematic/video/video_export_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// HOME PAGE
/// ----------------------

class AnimaticHomePage extends StatefulWidget {
  const AnimaticHomePage({super.key});

  @override
  State<AnimaticHomePage> createState() => _AnimaticHomePageState();
}

class _AnimaticHomePageState extends State<AnimaticHomePage> {
  AnimaticArchive? _archive;
  bool _isPlaying = true;

  int _currentSceneIndex = 0; // for info panel on the right
  double _currentAspectRatio = 16 / 9;

  @override
  void initState() {
    super.initState();
    _loadSampleArchive();
  }

  Widget _buildAspectRatioSelector(BuildContext context) {
    final theme = Theme.of(context);
    final formats = [
      {'label': '16:9 Widescreen', 'value': 16 / 9, 'icon': Icons.tv},
      {'label': '9:16 Shorts', 'value': 9 / 16, 'icon': Icons.stay_current_portrait},
      {'label': '1:1 Square', 'value': 1.0, 'icon': Icons.crop_square},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: formats.map((f) {
          final isSelected = (f['value'] as double) == _currentAspectRatio;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              avatar: Icon(
                f['icon'] as IconData,
                size: 14,
                color: isSelected ? Colors.black : Colors.white70,
              ),
              label: Text(f['label'] as String, style: const TextStyle(fontSize: 11)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentAspectRatio = f['value'] as double;
                  });
                }
              },
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _openBulkGenerator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const BulkGeneratorSheet();
      },
    ).then((result) {
      if (result != null && result is AnimaticArchive && mounted) {
        setState(() {
          _archive = result;
          _currentSceneIndex = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully loaded bulk generated project: "${result.title}"'),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    });
  }

  void _loadSampleArchive() {
    final map = jsonDecode(sampleArchiveJson) as Map<String, dynamic>;
    setState(() {
      _archive = AnimaticArchive.fromJson(map);
      _currentSceneIndex = 0;
    });
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _openFullPreview() {
    if (_archive == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FullPreviewPage(archive: _archive!)),
    );
  }

  void _showArchiveJson() {
    if (_archive == null) return;

    final jsonStr = const JsonEncoder.withIndent(
      '  ',
    ).convert(_archive!.toJson());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Animatic Archive JSON',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: SelectableText(
                        jsonStr,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLoadJsonDialog() {
    final controller = TextEditingController(text: sampleArchiveJson);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF181B24),
        title: const Text('Paste Animatic Archive JSON'),
        content: SizedBox(
          width: 500,
          child: TextField(
            controller: controller,
            maxLines: 15,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Paste JSON here',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              try {
                final map = jsonDecode(controller.text) as Map<String, dynamic>;
                final archive = AnimaticArchive.fromJson(map);
                setState(() {
                  _archive = archive;
                  _currentSceneIndex = 0;
                });
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Invalid JSON: $e')));
              }
            },
            child: const Text('Load'),
          ),
        ],
      ),
    );
  }

  /// SAFELY open the SceneEditorSheet after the current frame.
  /// This avoids calling showModalBottomSheet during build/init.
  // Future<T?> _openSceneEditorSafely<T>(Widget Function() builder) async {
  //   // schedule after frame to avoid "called during build" issues
  //   final completer = Completer<T?>();
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     if (!mounted) {
  //       completer.complete(null);
  //       return;
  //     }
  //     try {
  //       final result = await showModalBottomSheet<T>(
  //         context: context,
  //         isScrollControlled: true,
  //         backgroundColor: const Color(0xFF11131B),
  //         shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  //         ),
  //         builder: (_) => builder(),
  //       );
  //       completer.complete(result);
  //     } catch (e) {
  //       // if anything goes wrong, complete with null but log in debug
  //       if (kDebugMode) {
  //         debugPrint('Error showing SceneEditorSheet: $e');
  //       }
  //       completer.complete(null);
  //     }
  //   });
  //   return completer.future;
  // }

  Future<T?> _openSceneEditorSafely<T>(
    Widget Function(BuildContext) builder,
  ) async {
    if (!mounted) return null;

    // Always wait till frame is done
    await Future.delayed(Duration(milliseconds: 10));

    try {
      return await showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF11131B),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: builder,
      );
    } catch (e) {
      if (kDebugMode) debugPrint("Modal error: $e");
      return null;
    }
  }

  void _editScene(int index) {
    if (_archive == null) return;
    final scene = _archive!.scenes[index];

    _openSceneEditorSafely<SceneConfig?>(
      (ctx) => SceneEditorSheet(scene: scene, isNew: false),
    ).then((updated) {
      if (updated != null && mounted) {
        setState(() => _archive!.scenes[index] = updated);
      }
    });

    // use the safe helper
    // _openSceneEditorSafely<SceneConfig?>(
    //   () => SceneEditorSheet(scene: scene, isNew: false),
    // ).then((updated) {
    //   if (updated != null) {
    //     if (!mounted) return;
    //     setState(() {
    //       _archive!.scenes[index] = updated;
    //     });
    //   }
    // });
  }

  void _addScene() {
    final now = DateTime.now().millisecondsSinceEpoch.toString();

    _archive ??= AnimaticArchive(
      version: '1.0.0',
      title: 'My Cinematic',
      createdAt: DateTime.now(),
      scenes: [],
    );

    final newScene = SceneConfig(
      id: 'scene_$now',
      title: 'New Scene',
      subtitle: 'Subtitle here',
      hook: '',
      body: '',
      keyPoints: const [],
      imageUrl:
          'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg',
      durationSeconds: 8,
      effect: 'zoom_in',
      transitionOut: 'fade',
      textEffect: 'fade',
      voiceTone: '',
      musicStyle: '',
      animationInstructions: '',
      closureLine: '',
    );

    // _openSceneEditorSafely<SceneConfig?>(
    //   () => SceneEditorSheet(scene: newScene, isNew: true),
    // ).then((updated) {
    //   if (updated != null) {
    //     if (!mounted) return;
    //     setState(() {
    //       _archive!.scenes.add(updated);
    //     });
    //   }
    // });
    _openSceneEditorSafely<SceneConfig?>(
      (ctx) => SceneEditorSheet(scene: newScene, isNew: true),
    ).then((updated) {
      if (updated != null && mounted) {
        setState(() => _archive!.scenes.add(updated));
      }
    });
  }
// final GlobalKey previewKey = GlobalKey();

// final exporter = FrameVideoExporter();


  int _recordingSessionId = 0;

  Future<void> _startRecording() async {
    final totalDuration = _archive?.scenes.fold<int>(0, (sum, scene) => sum + scene.durationSeconds) ?? 5;

    setState(() {
      _recordingSessionId++;
      _isRecording = true;
      _isPlaying = true;
      _statusMessage = 'Recording...';
    });

    try {
      // Small delay to ensure the widget is fully laid out and CinematicPlayer resets to scene 0
      await Future.delayed(const Duration(milliseconds: 200));

      await _exporter.startRecording(
        repaintKey: _previewKey,
        fps: 30,           // frames per second
        durationSeconds: totalDuration,
      );
    } catch (e) {
      debugPrint('Recording error: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _isPlaying = false;
          _statusMessage = 'Ready';
        });
      }
    }
  }
  final GlobalKey _previewKey = GlobalKey();
  final FrameVideoExporter _exporter = FrameVideoExporter();

  bool _isRecording = false;
  String _statusMessage = 'Ready';

  Future<void> _stopRecording() async {
    setState(() {
      _statusMessage = 'Stopping & downloading...';
    });

    try {
      await _exporter.stopRecording();
    } catch (e) {
      debugPrint('Stop error: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'Stop error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _isPlaying = false;
          _statusMessage = 'Ready';
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final archive = _archive;

    return Scaffold(
      appBar: AppBar(
        title: Text(archive?.title ?? 'Cinematic Flutter Video Maker'),
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Bulk Video Generator',
            onPressed: _openBulkGenerator,
            icon: const Icon(Icons.auto_awesome_motion, color: Colors.cyanAccent),
          ),
          IconButton(
            tooltip: 'Load JSON',
            onPressed: _showLoadJsonDialog,
            icon: const Icon(Icons.cloud_download),
          ),
          IconButton(
            tooltip: 'Show Archive JSON',
            onPressed: _showArchiveJson,
            icon: const Icon(Icons.code),
          ),

//      IconButton(
//   tooltip: 'Start Recording',
//   onPressed: () async {
//     try {
//       setState(() {
//         _isPlaying = true;
//       });
//       await Future.delayed(
//   const Duration(seconds: 1),
// );


//       await exporter.startRecording(
//         repaintKey: previewKey,
//         fps: 30,
//         durationSeconds: 15,
//       );

//       print("Recording Completed");
//     } catch (e) {
//       print(e);
//     }
//   },
//   icon: const Icon(
//     Icons.fiber_manual_record,
//     color: Colors.red,
//   ),
// ),
// IconButton(
//   tooltip: 'Stop Recording',
//   onPressed: () async {
//     try {
//       await exporter.stopRecording();

//       print("Frames Downloaded");
//     } catch (e) {
//       print(e);
//     }
//   },
//   icon: const Icon(Icons.stop),
// ),


   IconButton(
                  tooltip: 'Start Recording',
                  onPressed: _isRecording ? null : _startRecording,
                  icon: const Icon(
                    Icons.fiber_manual_record,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                const SizedBox(width: 20),
                // Stop Recording button
                IconButton(
                  tooltip: 'Stop Recording',
                  onPressed: _isRecording ? _stopRecording : null,
                  icon: const Icon(Icons.stop, size: 48),
                ),

          IconButton(
            tooltip: 'Add Scene',
            onPressed: _addScene,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            tooltip: 'Full Preview',
            onPressed: archive == null ? null : _openFullPreview,
            icon: const Icon(Icons.slideshow),
          ),
          IconButton(
            tooltip: _isPlaying ? 'Pause' : 'Play',
            onPressed: _togglePlay,
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: archive == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _showLoadJsonDialog,
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Load Animatic JSON'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _loadSampleArchive,
                    icon: const Icon(Icons.movie_creation_outlined),
                    label: const Text('Load Sample Flutter Cinematic'),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;

                if (!isWide) {
                  final currentScene =
                      archive.scenes[_currentSceneIndex.clamp(
                        0,
                        archive.scenes.length - 1,
                      )];

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1E2240), Color(0xFF090C18)],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.movie_filter_outlined, size: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      archive.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${archive.scenes.length} scenes • Tap a scene to edit',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: _openFullPreview,
                                icon: const Icon(Icons.fullscreen),
                                label: const Text('Preview'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: _showLoadJsonDialog,
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: const Text('Load JSON'),
                          ),
                        ),
                      ),
                      _buildAspectRatioSelector(context),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: AspectRatio(
                          aspectRatio: _currentAspectRatio,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0x66141A33), Color(0x22090C18)],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  blurRadius: 24,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child:  RepaintBoundary(
  key: _previewKey,
  child: CinematicPlayer(
    key: ValueKey('player_session_$_recordingSessionId'),
    scenes: archive.scenes,
    isPlaying: _isPlaying,
    loop: true,
    onSceneChanged: (i) {
      setState(() {
        _currentSceneIndex = i;
      });
    },
  ),
),
                              //   child: CinematicPlayer(
                              //   scenes: archive.scenes,
                              //   isPlaying: _isPlaying,
                              //   loop: true,
                              //   onSceneChanged: (i) {
                              //     setState(() {
                              //       _currentSceneIndex = i;
                              //     });
                              //   },
                              // ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Current Scene: ${currentScene.title}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D0F16),
                          border: Border(
                            top: BorderSide(
                              color: Colors.white.withValues(alpha: 0.08),
                              width: 1,
                            ),
                          ),
                        ),
                        child: SizedBox(
                          height: 104,
                          child: ReorderableListView.builder(
                            scrollDirection: Axis.horizontal,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }
                                final item = archive.scenes.removeAt(oldIndex);
                                archive.scenes.insert(newIndex, item);
                              });
                            },
                            itemBuilder: (context, index) {
                              final scene = archive.scenes[index];
                              return ReorderableDelayedDragStartListener(
                                key: ValueKey('horiz_${scene.id}'),
                                index: index,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _editScene(index),
                                        child: SceneThumbnail(
                                          scene: scene,
                                          index: index,
                                          isActive: index == _currentSceneIndex,
                                        ),
                                      ),
                                      Positioned(
                                        right: 2,
                                        top: 2,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              archive.scenes.removeAt(index);
                                              if (_currentSceneIndex >= archive.scenes.length) {
                                                _currentSceneIndex = archive.scenes.length - 1;
                                              }
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: const BoxDecoration(
                                              color: Colors.redAccent,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, size: 8, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            itemCount: archive.scenes.length,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final currentScene =
                    archive.scenes[_currentSceneIndex.clamp(
                      0,
                      archive.scenes.length - 1,
                    )];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 260,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: const Color(0xFF101320),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.06),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.timeline_rounded, size: 24),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Scenes Timeline',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${archive.scenes.length} scenes configured',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _showLoadJsonDialog,
                                    icon: const Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 20,
                                    ),
                                    tooltip: 'Load JSON',
                                  ),
                                  IconButton(
                                    onPressed: _addScene,
                                    icon: const Icon(Icons.add_circle_outline),
                                    tooltip: 'Add Scene',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF070913),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.06,
                                      ),
                                    ),
                                  ),
                                  child: ReorderableListView.builder(
                                    padding: const EdgeInsets.all(8),
                                    onReorder: (oldIndex, newIndex) {
                                      setState(() {
                                        if (newIndex > oldIndex) {
                                          newIndex -= 1;
                                        }
                                        final item = archive.scenes.removeAt(oldIndex);
                                        archive.scenes.insert(newIndex, item);
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      final scene = archive.scenes[index];
                                      return ReorderableDelayedDragStartListener(
                                        key: ValueKey('vert_${scene.id}'),
                                        index: index,
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () => _editScene(index),
                                                child: SceneThumbnail(
                                                  scene: scene,
                                                  index: index,
                                                  isActive: index == _currentSceneIndex,
                                                ),
                                              ),
                                              Positioned(
                                                right: 6,
                                                top: 6,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      archive.scenes.removeAt(index);
                                                      if (_currentSceneIndex >= archive.scenes.length) {
                                                        _currentSceneIndex = archive.scenes.length - 1;
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: const BoxDecoration(
                                                      color: Colors.redAccent,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(Icons.delete, size: 10, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 6,
                                                top: 6,
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withValues(alpha:0.5),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(Icons.drag_indicator, size: 10, color: Colors.white70),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: archive.scenes.length,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                12,
                                18,
                                12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF1E2240),
                                    Color(0xFF090C18),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.movie_creation_outlined,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          archive.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Preview your cinematic animatic with smooth Ken Burns motion & text effects.',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  FilledButton.tonalIcon(
                                    onPressed: _openFullPreview,
                                    icon: const Icon(Icons.slideshow),
                                    label: const Text('Full Preview'),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton.filledTonal(
                                    onPressed: _togglePlay,
                                    icon: Icon(
                                      _isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildAspectRatioSelector(context),
                            Expanded(
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: _currentAspectRatio,
                                  child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(26),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0x66141A33),
                                        Color(0x22090C18),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.12,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.7,
                                        ),
                                        blurRadius: 26,
                                        offset: const Offset(0, 22),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(26),
                                    child: RepaintBoundary(
  key: _previewKey,
  child: CinematicPlayer(
    key: ValueKey('player_session_$_recordingSessionId'),
    scenes: archive.scenes,
    isPlaying: _isPlaying,
    loop: true,
    onSceneChanged: (i) {
      setState(() {
        _currentSceneIndex = i;
      });
    },
  ),
),
                                  ),
                                ),
                              ),
                            ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 260,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF0C0F19),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Scene',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentScene.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (currentScene.subtitle.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  currentScene.subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 18,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${currentScene.durationSeconds}s • ${currentScene.effect.replaceAll('_', ' ')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (currentScene.voiceTone.isNotEmpty ||
                                  currentScene.musicStyle.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: Colors.white.withValues(alpha: 0.03),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (currentScene.voiceTone.isNotEmpty)
                                        Text(
                                          'Voice: ${currentScene.voiceTone}',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      if (currentScene.musicStyle.isNotEmpty)
                                        Text(
                                          'Music: ${currentScene.musicStyle}',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 10),
                              if (currentScene.keyPoints.isNotEmpty) ...[
                                Text(
                                  'Key Points',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: currentScene.keyPoints
                                          .map(
                                            (kp) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 2,
                                              ),
                                              child: Text(
                                                '• $kp',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.8),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ] else
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'Add key points\nfor this scene in editor.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}