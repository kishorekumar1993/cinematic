

// // lib/main.dart

import 'package:cinematic/presentation/animatic_home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CinematicApp());
}

class CinematicApp extends StatelessWidget {
  const CinematicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinematic Flutter Video Maker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF05070A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B86FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const 
      // CinematicSceneYoutubeLaunch(),
      AnimaticHomePage(),
      // home: const AnimaticHomePage(),
    );
  }
}