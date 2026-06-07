import 'dart:async';

import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/model/template_registry.dart';
import 'package:cinematic/presentation/tempelate/scene_design_system.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// CINEMATIC PLAYER
/// ----------------------
/// Wraps the template builder with:
/// - Scene auto-advance timer
/// - AnimatedSwitcher cross-fade between scenes
/// - Optional safe-area guide overlay (for editor preview only)

class CinematicPlayer extends StatefulWidget {
  final List<SceneConfig> scenes;
  final bool isPlaying;
  final bool loop;
  final ValueChanged<int>? onSceneChanged;

  /// When true, shows red safe-area bands (top 12%, bottom 22%) for preview.
  /// Never enable this in export/production mode.
  final bool showSafeAreaGuide;

  const CinematicPlayer({
    super.key,
    required this.scenes,
    required this.isPlaying,
    this.loop = false,
    this.onSceneChanged,
    this.showSafeAreaGuide = false,
  });

  @override
  State<CinematicPlayer> createState() => _CinematicPlayerState();
}

class _CinematicPlayerState extends State<CinematicPlayer> {
  int _currentIndex = 0;
  Timer? _timer;

  SceneConfig get _currentScene => widget.scenes[_currentIndex];

  @override
  void initState() {
    super.initState();
    // Defer timer start to after the first frame to avoid layout assertion
    // races when the widget tree is still being laid out for the first time.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scheduleNext();
    });
  }

  @override
  void didUpdateWidget(covariant CinematicPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _scheduleNext();
      } else {
        _timer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _notifySceneChanged() {
    widget.onSceneChanged?.call(_currentIndex);
  }

  void _scheduleNext() {
    _timer?.cancel();
    if (!widget.isPlaying || widget.scenes.isEmpty) return;

    final duration = Duration(
      seconds: _currentScene.durationSeconds.clamp(3, 120),
    );

    _timer = Timer(duration, () {
      if (!mounted) return;

      setState(() {
        if (_currentIndex < widget.scenes.length - 1) {
          _currentIndex++;
        } else if (widget.loop) {
          _currentIndex = 0;
        }
      });

      _notifySceneChanged();
      _scheduleNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scenes.isEmpty) {
      return const Center(child: Text('No scenes in archive'));
    }

    final scene = _currentScene;

    // Resolve template dynamically
    final templateId = scene.templateId.isNotEmpty
        ? scene.templateId
        : (scene.effect == 'dual_category' ? 'dual_category' : 'documentary_six');

    final template = TemplateRegistry.get(templateId) ??
        TemplateRegistry.get('documentary_six')!;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Main template scene
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          child: SizedBox.expand(
            key: ValueKey(_currentIndex),
            child: template.builder(context, scene, widget.isPlaying),
          ),
        ),

        // Safe-area guide overlay (editor-only)
        SceneSafeAreaGuide(show: widget.showSafeAreaGuide),
      ],
    );
  }
}
