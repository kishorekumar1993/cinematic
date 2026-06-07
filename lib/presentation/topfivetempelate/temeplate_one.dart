

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const Top5TamilMoviesApp());
}

class Top5TamilMoviesApp extends StatelessWidget {
  const Top5TamilMoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2025 Top 5 Tamil Movies',
      debugShowCheckedModeBanner: false,
      home: const Top5MoviesScreen(),
    );
  }
}

/// ------------ DATA MODELS + JSON CONFIG ----------------

class MovieSceneConfig {
  final String id;
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
  final String? closureLine;

  MovieSceneConfig({
    required this.id,
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
    this.closureLine,
  });

  factory MovieSceneConfig.fromJson(Map<String, dynamic> json) {
    return MovieSceneConfig(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      hook: json['hook'] as String,
      body: json['body'] as String,
      keyPoints: (json['keyPoints'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      imageUrl: json['imageUrl'] as String? ?? '',
      durationSeconds: json['durationSeconds'] as int,
      effect: json['effect'] as String,
      transitionOut: json['transitionOut'] as String,
      textEffect: json['textEffect'] as String,
      closureLine: json['closureLine'] as String?,
    );
  }
}

class TopListConfig {
  final String version;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final List<MovieSceneConfig> scenes;

  TopListConfig({
    required this.version,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.scenes,
  });

  factory TopListConfig.fromJson(Map<String, dynamic> json) {
    return TopListConfig(
      version: json['version'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      scenes: (json['scenes'] as List<dynamic>)
          .map((e) => MovieSceneConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

const String _configJson = r'''
{
  "version": "1.0.0",
  "title": "2025ன் டாப் 5 தமிழ் திரைப்படங்கள்",
  "subtitle": "உலகளாவிய பாக்ஸ் ஆபிஸ் வெற்றி",
  "createdAt": "2025-12-07T08:00:00.000Z",
  "scenes": [
    {
      "id": "coolie",
      "title": "1. கூலி (Coolie)",
      "subtitle": "மாபெரும் பாக்ஸ் ஆபிஸ் சாதனை",
      "hook": "ரஜினிகாந்த், லோகேஷ் கனகராஜ் கூட்டணியில் உருவான ஆக்‌ஷன் என்டர்டெய்னர்.",
      "body": "2025 ஆம் ஆண்டில் அதிக வசூல் செய்த தமிழ் திரைப்படம். இந்த ஆக்‌ஷன் நிறைந்த என்டர்டெய்னர் உலகளவில் ₹514 கோடி முதல் ₹675 கோடி வரை வசூலித்து சாதனை படைத்தது.",
      "keyPoints": [
        "இயக்குநர்: லோகேஷ் கனகராஜ்",
        "வசூல்: ₹514–675 கோடி",
        "வகை: ஆக்‌ஷன்"
      ],
      "imageUrl": "https://i.ytimg.com/vi/qeVfT2iLiu0/hq720.jpg",
      "durationSeconds": 10,
      "effect": "zoom_in",
      "transitionOut": "fade",
      "textEffect": "slide_up"
    },
    {
      "id": "good_bad_ugly",
      "title": "2. குட் பேட் அக்லி (Good Bad Ugly)",
      "subtitle": "அஜித்தின் திரில்லர் ஆக்‌ஷன்",
      "hook": "அஜித் குமார் நடிப்பில் அதிரடி ஆக்‌ஷன் காட்சிகள் நிறைந்த படம்.",
      "body": "அதிரடி மற்றும் உணர்ச்சிப்பூர்வமான கதைக்களத்துடன் வெளியான இப்படம், உலகளவில் ₹179 கோடி முதல் ₹248 கோடி வரை வசூலித்து இரண்டாவது இடத்தைப் பிடித்தது.",
      "keyPoints": [
        "இயக்குநர்: ஆதிக் ரவிச்சந்திரன்",
        "வசூல்: ₹179–248 கோடி",
        "வகை: ஆக்‌ஷன்/திரில்லர்"
      ],
      "imageUrl": "https://images.indianexpress.com/2024/05/Ajith-Kumar-in-Good-Bad-Uglys-new-poster.jpg",
      "durationSeconds": 10,
      "effect": "zoom_in",
      "transitionOut": "fade",
      "textEffect": "slide_up"
    },
    {
      "id": "dragon",
      "title": "3. டிராகன் (Dragon)",
      "subtitle": "புதுமுகத்தின் வெற்றி",
      "hook": "நகைச்சுவை மற்றும் உணர்ச்சி கலந்த குடும்ப பொழுதுபோக்குப் படம்.",
      "body": "புதுமுக நடிகரின் சிறப்பான நடிப்பால் ரசிகர்களைக் கவர்ந்த திரைப்படம். உலகளவில் சுமார் ₹150 கோடி முதல் ₹152 கோடி வரை வசூலித்தது.",
      "keyPoints": [
        "இயக்குநர்: அஸ்வத் மாரிமுத்து/பிரதீப் ரங்கநாதன் (மாற்றங்களுடன்)",
        "வசூல்: ₹150–152 கோடி",
        "வகை: ஆக்‌ஷன்/காமெடி"
      ],
      "imageUrl": "https://images.indianexpress.com/2025/02/Pradeep-Ranganathan-Dragon-trailer-10022025.jpg",
      "durationSeconds": 9,
      "effect": "zoom_out",
      "transitionOut": "fade",
      "textEffect": "fade"
    },
    {
      "id": "vidaamuyarchi",
      "title": "4. விடாமுயற்சி (Vidaamuyarchi)",
      "subtitle": "பரபரப்பான சாகசப் பயணம்",
      "hook": "அஜித் குமார் நடிப்பில் மற்றொரு மெகா ஆக்‌ஷன் எண்டர்டெய்னர்.",
      "body": "மகிழ் திருமேனி இயக்கத்தில் வெளியான இந்த ஸ்டைலிஷ் ஆக்‌ஷன் திரில்லர், உலகளவில் ₹135 கோடி முதல் ₹138 கோடி வரை வசூல் செய்தது.",
      "keyPoints": [
        "இயக்குநர்: மகிழ் திருமேனி",
        "வசூல்: ₹135–138 கோடி",
        "வகை: ஆக்‌ஷன்/திரில்லர்"
      ],
      "imageUrl": "https://imagesvs.oneindia.com/webp/img/2025/02/vidaamuyarchi-review-05-1738780075.jpg",
      "durationSeconds": 9,
      "effect": "pan_left",
      "transitionOut": "fade",
      "textEffect": "slide_up"
    },
    {
      "id": "kuberaa",
      "title": "5. குபேரா (Kuberaa)",
      "subtitle": "மல்டி ஸ்டாரர் ப்ளாக்பஸ்டர்",
      "hook": "தனுஷ், நாகார்ஜுனா, ராஷ்மிகா மந்தனா நடித்த மெகா கூட்டணிப் படம்.",
      "body": "விறுவிறுப்பான திரைக்கதை மற்றும் பிரம்மாண்ட தயாரிப்பால் கவனம் ஈர்த்தது. உலகளவில் ₹115 கோடி முதல் ₹140 கோடி வரை வசூலித்தது.",
      "keyPoints": [
        "இயக்குநர்: சேகர் கம்முலா",
        "வசூல்: ₹115–140 கோடி",
        "வகை: சாகசம்/திரில்லர்"
      ],
      "imageUrl": "https://imagesvs.oneindia.com/webp/img/2025/06/kuberaa-movie-review-01-1750388548.jpg",
      "durationSeconds": 10,
      "effect": "zoom_in",
      "transitionOut": "fade",
      "textEffect": "fade",
      "closureLine": "2025 தமிழ் சினிமாவுக்கு ஒரு வெற்றிகரமான ஆண்டாக அமைந்தது!"
    }
  ]
}
''';

/// ------------ MAIN UI SCREEN ----------------

class Top5MoviesScreen extends StatefulWidget {
  const Top5MoviesScreen({super.key});

  @override
  State<Top5MoviesScreen> createState() => _Top5MoviesScreenState();
}

class _Top5MoviesScreenState extends State<Top5MoviesScreen> {
  late final TopListConfig config;
  int selectedIndex = 0;
  Timer? _sceneTimer;

  @override
  void initState() {
    super.initState();
    final map = jsonDecode(_configJson) as Map<String, dynamic>;
    config = TopListConfig.fromJson(map);
    _restartSceneTimer();
  }

  void _restartSceneTimer() {
    _sceneTimer?.cancel();
    final current = config.scenes[selectedIndex];
    _sceneTimer = Timer(Duration(seconds: current.durationSeconds), () {
      if (!mounted) return;
      setState(() {
        selectedIndex = (selectedIndex + 1) % config.scenes.length;
      });
      _restartSceneTimer();
    });
  }

  @override
  void dispose() {
    _sceneTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scenes = config.scenes;
    final selectedScene = scenes[selectedIndex];
    final scenesReversed = scenes.reversed.toList(); // for 5 → 1

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF070B2A), Color(0xFF020313)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TopBarTitle(
                  title: config.title,
                  subtitle: config.subtitle,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: _AnimatedSceneFrame(
                            key: ValueKey(selectedScene.id),
                            scene: selectedScene,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: _RankingColumn(
                          scenesReversed: scenesReversed,
                          selectedScene: selectedScene,
                          onSceneTap: (scene) {
                            final idx = scenes.indexOf(scene);
                            setState(() => selectedIndex = idx);
                            _restartSceneTimer();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------ TOP TITLE BAR (IMPROVED) ------------------

class TopBarTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;

  const TopBarTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final themeIcon = icon ?? Icons.movie_filter_rounded;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x8000E5FF),
                blurRadius: 28,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                themeIcon,
                size: 20,
                color: const Color(0xFF001326),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  color: Color(0xFF001326),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha:0.85),
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

/// ------------------ ANIMATED MAIN FRAME ------------------

class _AnimatedSceneFrame extends StatefulWidget {
  final MovieSceneConfig scene;

  const _AnimatedSceneFrame({super.key, required this.scene});

  @override
  State<_AnimatedSceneFrame> createState() => _AnimatedSceneFrameState();
}

class _AnimatedSceneFrameState extends State<_AnimatedSceneFrame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _imageOffsetAnim;
  late Animation<Offset> _textOffsetAnim;
  late Animation<double> _textOpacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _configureAnimations();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedSceneFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.id != widget.scene.id) {
      _configureAnimations();
      _controller
        ..reset()
        ..forward();
    }
  }

  void _configureAnimations() {
    _controller.duration = Duration(seconds: widget.scene.durationSeconds);

    // IMAGE EFFECT
    switch (widget.scene.effect) {
      case 'zoom_in':
        _scaleAnim = Tween<double>(begin: 1.08, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
        _imageOffsetAnim =
            const AlwaysStoppedAnimation<Offset>(Offset.zero);
        break;
      case 'zoom_out':
        _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
        _imageOffsetAnim =
            const AlwaysStoppedAnimation<Offset>(Offset.zero);
        break;
      case 'pan_left':
        _scaleAnim = const AlwaysStoppedAnimation(1.05);
        _imageOffsetAnim = Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
        break;
      case 'pan_right':
        _scaleAnim = const AlwaysStoppedAnimation(1.05);
        _imageOffsetAnim = Tween<Offset>(
          begin: const Offset(-0.06, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
        break;
      default:
        _scaleAnim = const AlwaysStoppedAnimation(1.0);
        _imageOffsetAnim =
            const AlwaysStoppedAnimation<Offset>(Offset.zero);
    }

    // TEXT EFFECT
    switch (widget.scene.textEffect) {
      case 'slide_up':
        _textOffsetAnim = Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
        _textOpacityAnim =
            Tween<double>(begin: 0, end: 1).animate(_controller);
        break;
      case 'slide_left':
        _textOffsetAnim = Tween<Offset>(
          begin: const Offset(0.15, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
        _textOpacityAnim =
            Tween<double>(begin: 0, end: 1).animate(_controller);
        break;
      case 'fade':
      default:
        _textOffsetAnim =
            const AlwaysStoppedAnimation<Offset>(Offset.zero);
        _textOpacityAnim = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeIn),
        );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    return AspectRatio(
      // aspectRatio: 22/ 12,
      aspectRatio: 18 / 12,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00E5FF), width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0xAA00E5FF),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x8000E5FF), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                // IMAGE + EFFECT
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Transform.scale(
                      scale: _scaleAnim.value,
                      child: FractionalTranslation(
                        translation: _imageOffsetAnim.value,
                        child: _buildBackgroundImage(scene),
                      ),
                    );
                  },
                ),
                // Dark overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha:0.75),
                        Colors.black.withValues(alpha:0.20),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                ),
                // TEXT BLOCK
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return Opacity(
                        opacity: _textOpacityAnim.value,
                        child: SlideTransition(
                          position: _textOffsetAnim,
                          child: _SceneTextContent(scene: scene),
                        ),
                      );
                    },
                  ),
                ),
                // PROGRESS BAR
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 10,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 4,
                          color: Colors.white24,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _controller.value.clamp(0.0, 1.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF00F5FF),
                                    Color(0xFFFFD54F),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(MovieSceneConfig scene) {
    final Widget image = scene.imageUrl.isNotEmpty
        ? Image.network(
            scene.imageUrl,
            fit: BoxFit.cover, // 🔥 full cinematic cover
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => _fallbackGradient(),
          )
        : _fallbackGradient();

    return Stack(
      children: [
        image,

        // cinematic vignette
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha:0.65),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),

        // subtle film grain overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha:0.08),
              backgroundBlendMode: BlendMode.overlay,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallbackGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF121B3D), Color(0xFF070B1D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _SceneTextContent extends StatelessWidget {
  final MovieSceneConfig scene;

  const _SceneTextContent({required this.scene});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha:0.35),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha:0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.5),
                offset: const Offset(0, 6),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              Text(
                scene.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),

              const SizedBox(height: 6),

              /// SUBTITLE pill
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFEA00), Color(0xFFD4A000)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha:0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      scene.subtitle,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// HOOK line
              Text(
                scene.hook,
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              /// BODY + features scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scene.body,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: scene.keyPoints.map((p) {
                          return AnimatedScale(
                            duration: const Duration(milliseconds: 240),
                            scale: 1.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: Colors.black.withValues(alpha:0.35),
                                border: Border.all(
                                  color: Colors.cyanAccent.withValues(alpha:0.8),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                p,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (scene.closureLine != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00FFA1), Color(0xFF008F60)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withValues(alpha:0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Text(
                            scene.closureLine!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _RankingColumn extends StatelessWidget {
  final List<MovieSceneConfig> scenesReversed;
  final MovieSceneConfig selectedScene;
  final void Function(MovieSceneConfig scene) onSceneTap;

  const _RankingColumn({
    required this.scenesReversed,
    required this.selectedScene,
    required this.onSceneTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0x40FFFFFF),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10163A).withValues(alpha:0.97),
            const Color(0xFF090E26).withValues(alpha:0.9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4000E5FF),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel header
            Row(
              children: [
                const Icon(
                  Icons.leaderboard_rounded,
                  size: 18,
                  color: Color(0xFF00E5FF),
                ),
                const SizedBox(width: 6),
                const Text(
                  'TOP 5 RANKING',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: const Color(0xFF1E264A),
                  ),
                  child: Text(
                    '${scenesReversed.length} Movies',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x00FFFFFF),
                    Color(0x40FFFFFF),
                    Color(0x00FFFFFF),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Rank list
            Expanded(
              child: ListView.builder(
                itemCount: scenesReversed.length,
                itemBuilder: (context, index) {
                  final scene = scenesReversed[index];
                  final rankNumber = scenesReversed.length - index; // 5..1
                  final isSelected = scene.id == selectedScene.id;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => onSceneTap(scene),
                      child: _RankCard(
                        rank: rankNumber,
                        scene: scene,
                        isSelected: isSelected,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankCard extends StatelessWidget {
  final int rank;
  final MovieSceneConfig scene;
  final bool isSelected;

  const _RankCard({
    required this.rank,
    required this.scene,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isSelected ? const Color(0xFFFFD54F) : const Color(0xFF00E5FF);

    final bgGradient = isSelected
        ? const LinearGradient(
            colors: [
              Color(0xFF273468),
              Color(0xFF1C254C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Color(0xFF151A3D),
              Color(0xFF101632),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      height: 86,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2 : 1.2,
        ),
        gradient: bgGradient,
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha:isSelected ? 0.7 : 0.3),
            blurRadius: isSelected ? 18 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank badge on left
          Container(
            width: 52,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [
                        Color(0xFFFFD54F),
                        Color(0xFFFFA726),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : const LinearGradient(
                      colors: [
                        Color(0xFF001C40),
                        Color(0xFF002748),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#$rank',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isSelected
                        ? const Color(0xFF2C1A00)
                        : const Color(0xFF00E5FF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'TOP',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? const Color(0xFF3A2600)
                        : Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Text block
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    scene.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha:0.88),
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Duration info
                  Row(
                    children: [
                      Text(
                        '${scene.subtitle}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha:0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Thumbnail (right)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFF1B213F),
                ),
                child: scene.imageUrl.isNotEmpty
                    ? Image.network(
                        scene.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _ThumbFallback(rank),
                      )
                    : _ThumbFallback(rank),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbFallback extends StatelessWidget {
  final int rank;
  const _ThumbFallback(this.rank);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF00F5FF),
            Color(0xFF7C4DFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
