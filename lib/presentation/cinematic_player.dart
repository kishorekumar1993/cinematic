import 'dart:async';

import 'package:cinematic/model/screen_config.dart';
import 'package:cinematic/presentation/dualscreen/dual_banner_scene.dart';
import 'package:cinematic/presentation/dualscreen/dual_category_scene_screen.dart';
import 'package:cinematic/presentation/dualscreen/dual_mirror_sceme.dart';
import 'package:cinematic/presentation/dualscreen/dual_neo.dart';
import 'package:cinematic/presentation/dualscreen/dual_ribbon_scene.dart';
import 'package:cinematic/presentation/dualscreen/dual_smart_scene.dart';
import 'package:cinematic/presentation/dualscreen/dual_status_scene.dart';
import 'package:cinematic/presentation/dualscreen/dualrankscene.dart';
import 'package:cinematic/presentation/dualscreen/dualspotlight.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_four.dart';
import 'package:cinematic/presentation/tempelate/youtube_movie_temp_two.dart';
import 'package:cinematic/presentation/tempelate/cinematic_netflixtemp.dart';
import 'package:cinematic/presentation/tempelate/cinematic_netflixtemp_three.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_documentry_five.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_documentry_four.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_documentry_one.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_documentry_six.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_documentry_three.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_documentry_two.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_history_reveal_one.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_news_eight.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_news_five.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_news_four.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_news_nine.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_news_one.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_news_seven.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_news_six.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_news_three.dart';
import 'package:cinematic/presentation/tempelate/cinematic_scene_news_two.dart';
import 'package:cinematic/presentation/tempelate/cinematic_screen.dart';
import 'package:cinematic/presentation/tempelate/cinematic_screen_six.dart';
import 'package:cinematic/presentation/tempelate/movie_temp_one.dart';
import 'package:cinematic/presentation/topfivetemp/top_five_temp_one.dart';
import 'package:cinematic/presentation/topfivetemp/top_five_temp_two.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// CINEMATIC PLAYER
/// ----------------------

class CinematicPlayer extends StatefulWidget {
  final List<SceneConfig> scenes;
  final bool isPlaying;
  final bool loop;
  final ValueChanged<int>? onSceneChanged;

  const CinematicPlayer({
    super.key,
    required this.scenes,
    required this.isPlaying,
    this.loop = false,
    this.onSceneChanged,
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
    _scheduleNext();
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

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: scene.effect == 'dual_category'
          ? DualPrimeScene(
              key: ValueKey('dual_${scene.id}'),
              scene: scene,
              isPlaying: widget.isPlaying,
            )
          :
          // CinematicTopFiveMovieScene(
CinematicSceneSix(          //  CinematicSceneFour(
              key: ValueKey(scene.id),
              scene: scene,
              isPlaying: widget.isPlaying,
            ),
    );
  }
}

// class CinematicPlayer extends StatefulWidget {
//   final List<SceneConfig> scenes;
//   final bool isPlaying;
//   final bool loop;
//   final ValueChanged<int>? onSceneChanged;

//   const CinematicPlayer({
//     super.key,
//     required this.scenes,
//     required this.isPlaying,
//     this.loop = false,
//     this.onSceneChanged,
//   });

//   @override
//   State<CinematicPlayer> createState() => _CinematicPlayerState();
// }

// class _CinematicPlayerState extends State<CinematicPlayer> {
//   int _currentIndex = 0;
//   Timer? _timer;

//   SceneConfig get _currentScene => widget.scenes[_currentIndex];

//   @override
//   void initState() {
//     super.initState();
//     _scheduleNext();
//   }

//   @override
//   void didUpdateWidget(covariant CinematicPlayer oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.isPlaying != widget.isPlaying) {
//       if (widget.isPlaying) {
//         _scheduleNext();
//       } else {
//         _timer?.cancel();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   void _notifySceneChanged() {
//     widget.onSceneChanged?.call(_currentIndex);
//   }

//   void _scheduleNext() {
//     _timer?.cancel();
//     if (!widget.isPlaying || widget.scenes.isEmpty) return;

//     final duration =
//         Duration(seconds: _currentScene.durationSeconds.clamp(3, 120));

//     _timer = Timer(duration, () {
//       if (!mounted) return;

//       setState(() {
//         if (_currentIndex < widget.scenes.length - 1) {
//           _currentIndex++;
//         } else if (widget.loop) {
//           _currentIndex = 0;
//         }
//       });

//       _notifySceneChanged();
//       _scheduleNext();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.scenes.isEmpty) {
//       return const Center(child: Text('No scenes in archive'));
//     }

//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 800),
//       switchInCurve: Curves.easeOut,
//       switchOutCurve: Curves.easeIn,
//       child: CinematicSceneDocumentrySix(
//         key: ValueKey(_currentScene.id),
//         scene: _currentScene,
//         isPlaying: widget.isPlaying,
//       ),
//     );
//   }
// }
