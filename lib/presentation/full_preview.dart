import 'package:cinematic/model/animation_archieve.dart';
import 'package:cinematic/presentation/cinematic_player.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// FULL PREVIEW PAGE
/// ----------------------

class FullPreviewPage extends StatefulWidget {
  final AnimaticArchive archive;

  const FullPreviewPage({super.key, required this.archive});

  @override
  State<FullPreviewPage> createState() => _FullPreviewPageState();
}

class _FullPreviewPageState extends State<FullPreviewPage> {
  bool _isPlaying = true;
  int _currentIndex = 0;

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scenes = widget.archive.scenes;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _togglePlay,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: CinematicPlayer(
                  scenes: scenes,
                  isPlaying: _isPlaying,
                  loop: true,
                  onSceneChanged: (i) {
                    setState(() {
                      _currentIndex = i;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
