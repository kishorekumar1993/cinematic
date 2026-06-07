
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const CinemaTop5App());
}

class CinemaTop5App extends StatelessWidget {
  const CinemaTop5App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CinemaTop5FromJsonScreen(),
    );
  }
}

/// ======================= DATA MODELS =======================

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

/// =================== MAIN SCREEN (JSON + TEMPLATE) ===================

class CinemaTop5FromJsonScreen extends StatefulWidget {
  const CinemaTop5FromJsonScreen({super.key});

  @override
  State<CinemaTop5FromJsonScreen> createState() =>
      _CinemaTop5FromJsonScreenState();
}

class _CinemaTop5FromJsonScreenState extends State<CinemaTop5FromJsonScreen> {
  late final TopListConfig config;

  int selectedIndex = 0; // 0..4 (rank1..rank5)
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    final map = jsonDecode(_configJson) as Map<String, dynamic>;
    config = TopListConfig.fromJson(map);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoTimer?.cancel();
    final scene = config.scenes[selectedIndex];
    _autoTimer = Timer(Duration(seconds: scene.durationSeconds), () {
      if (!mounted) return;
      setState(() {
        selectedIndex = (selectedIndex + 1) % config.scenes.length;
      });
      _startAutoPlay();
    });
  }

  void _onRankTap(int rank) {
    final idx = rank - 1; // rank 1..5 → index 0..4
    if (idx == selectedIndex) return;
    setState(() => selectedIndex = idx);
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scenes = config.scenes;
    final currentScene = scenes[selectedIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5B0507), Color(0xFF260103)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // side deco + vignette
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.45,
                    child: CustomPaint(
                      painter: _SideDecoPainter(),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: 1.2,
                        colors: [
                          Colors.white.withValues(alpha:0.04),
                          Colors.black.withValues(alpha:0.55),
                        ],
                        center: const Alignment(0, -0.2),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 24),

                  _TopRibbonBanner(title: config.title),
                  const SizedBox(height: 4),
                  Text(
                    config.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final width =
                              min(constraints.maxWidth * 0.96, 1250.0);
                          return SizedBox(
                            width: width,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: _CinemaFrame(
                                      child: _AnimatedSceneScreen(
                                        key: ValueKey(currentScene.id),
                                        scene: currentScene,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: -78,
                                  child: _BottomStarRow(
                                    scenes: scenes,
                                    selectedIndex: selectedIndex,
                                    onRankTap: _onRankTap,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 92),
                ],
              ),

              const Positioned(
                right: 30,
                bottom: 30,
                child: _ChannelLogoCircle(text: 'CHANNEL\nLOGO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================== SCENE SCREEN (POSTER + ANIMATIONS) ==================

class _AnimatedSceneScreen extends StatefulWidget {
  final MovieSceneConfig scene;

  const _AnimatedSceneScreen({
    super.key,
    required this.scene,
  });

  @override
  State<_AnimatedSceneScreen> createState() => _AnimatedSceneScreenState();
}

class _AnimatedSceneScreenState extends State<_AnimatedSceneScreen>
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
  void didUpdateWidget(covariant _AnimatedSceneScreen oldWidget) {
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
      case 'slide_left':
        _textOffsetAnim = Tween<Offset>(
          begin: const Offset(0.18, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        );
        _textOpacityAnim =
            Tween<double>(begin: 0, end: 1).animate(_controller);
        break;
      case 'slide_up':
        _textOffsetAnim = Tween<Offset>(
          begin: const Offset(0, 0.22),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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

  Widget _buildPoster() {
    if (widget.scene.imageUrl.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF202020), Color(0xFF111111)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }
    return Image.network(
      widget.scene.imageUrl,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: (_, __, ___) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF202020), Color(0xFF111111)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    return Stack(
      children: [
        // Poster with Ken Burns animation
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: FractionalTranslation(
                translation: _imageOffsetAnim.value,
                child: _buildPoster(),
              ),
            );
          },
        ),

        // global dark overlay (slightly stronger than before)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha:0.55),
                Colors.black.withValues(alpha:0.12),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),

        // bottom HUD panel – text is always clear
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 14),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Opacity(
                  opacity: _textOpacityAnim.value,
                  child: Transform.translate(
                    offset: Offset(
                      _textOffsetAnim.value.dx * 40,
                      _textOffsetAnim.value.dy * 40,
                    ),
                    child: _MovieSceneTextContent(scene: scene),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// =============== TEXT LAYOUT (IMPROVED CLARITY) ===============

class _MovieSceneTextContent extends StatelessWidget {
  final MovieSceneConfig scene;

  const _MovieSceneTextContent({required this.scene});

  @override
  Widget build(BuildContext context) {
    return Container(
      // darker, more opaque for clarity
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha:0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha:0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.7),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE + SUBTITLE row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  scene.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF4C0), Color(0xFFC89B3C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(
                  scene.subtitle,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Color(0xFF4A2400),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // hook
          Text(
            scene.hook,
            style: const TextStyle(
              color: Color(0xFF8CF5FF),
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          // body + keypoints
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scene.body,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.2,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: scene.keyPoints.map((p) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: const Color(0xFF111111),
                          border: Border.all(
                            color: const Color(0xFF9CF3FF),
                            width: 0.9,
                          ),
                        ),
                        child: Text(
                          p,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (scene.closureLine != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00FFA1), Color(0xFF008F60)],
                        ),
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
          ),
        ],
      ),
    );
  }
}

/// ======================= BOTTOM STARS (JSON DRIVEN) =======================

class _BottomStarRow extends StatelessWidget {
  final List<MovieSceneConfig> scenes;
  final int selectedIndex; // 0..4
  final void Function(int rank) onRankTap;

  const _BottomStarRow({
    required this.scenes,
    required this.selectedIndex,
    required this.onRankTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = min(constraints.maxWidth, 1150.0);
          return SizedBox(
            width: width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final rank = 5 - i; // 5..1
                final index = rank - 1;
                final scene = scenes[index];
                final isSelected = index == selectedIndex;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: i == 0 ? 0 : 6,
                      right: i == 4 ? 0 : 6,
                    ),
                    child: _RankStarWithLabel(
                      rank: rank,
                      text: scene.title,
                      isSelected: isSelected,
                      onTap: () => onRankTap(rank),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

/// ======================= TEMPLATE PIECES (unchanged) =======================

class _TopRibbonBanner extends StatelessWidget {
  final String title;
  const _TopRibbonBanner({required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 42,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF8CF), Color(0xFFCFA143)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(38),
            border: Border.all(
              color: const Color(0xFF8C5B10),
              width: 1.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xAA000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w900,
              color: Color(0xFF5A2A00),
            ),
          ),
        ),
      ),
    );
  }
}

class _CinemaFrame extends StatelessWidget {
  final Widget child;
  const _CinemaFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFEEDB97), Color(0xFFB67F29)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.9),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(7),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFE7C779), Color(0xFFC18B2C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8F1418), Color(0xFF4D0507)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: _CurtainStrip(width: 86),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: _CurtainTie(offsetX: 34),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _CurtainStrip(width: 86),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _CurtainTie(offsetX: -34),
              ),
              Positioned.fill(
                left: 85,
                right: 85,
                top: 18,
                bottom: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF101010), Color(0xFF1F1F1F)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurtainStrip extends StatelessWidget {
  final double width;
  const _CurtainStrip({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF98181B), Color(0xFF530608)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _CurtainTie extends StatelessWidget {
  final double offsetX;
  const _CurtainTie({required this.offsetX});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(offsetX, 18),
      child: Container(
        width: 26,
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF7B080B), Color(0xFF420205)],
          ),
        ),
      ),
    );
  }
}

class _RankStarWithLabel extends StatelessWidget {
  final int rank;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _RankStarWithLabel({
    required this.rank,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const goldGradient = LinearGradient(
      colors: [Color(0xFFFFF6C8), Color(0xFFC8993F)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: isSelected ? 1.05 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 60,
              child: CustomPaint(
                painter: _GoldStarPainter(isSelected: isSelected),
                child: Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Color(0xFF4A2400),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 7.0),
              decoration: BoxDecoration(
                gradient: goldGradient,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF7A4C0A),
                  width: isSelected ? 2 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:isSelected ? 0.85 : 0.65),
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  height: 1.1,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3E1E00),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelLogoCircle extends StatelessWidget {
  final String text;
  const _ChannelLogoCircle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFFF6C8), Color(0xFFC8993F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF4A2400),
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _SideDecoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF6C8), Color(0xFFC8993F)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double baseX = size.width * 0.07;
    for (int i = 0; i < 3; i++) {
      final path = Path()
        ..moveTo(baseX, size.height * 0.12)
        ..lineTo(baseX + 40, size.height * 0.3)
        ..lineTo(baseX, size.height * 0.48)
        ..lineTo(baseX + 40, size.height * 0.66);
      canvas.drawPath(path, paint);
      baseX += 16;
    }

    baseX = size.width * 0.93;
    for (int i = 0; i < 3; i++) {
      final path = Path()
        ..moveTo(baseX, size.height * 0.12)
        ..lineTo(baseX - 40, size.height * 0.3)
        ..lineTo(baseX, size.height * 0.48)
        ..lineTo(baseX - 40, size.height * 0.66);
      canvas.drawPath(path, paint);
      baseX -= 16;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GoldStarPainter extends CustomPainter {
  final bool isSelected;
  const _GoldStarPainter({required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    const n = 5;
    final outerR = size.height / 2.1;
    final innerR = outerR / 2.5;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < n * 2; i++) {
      final isOuter = i.isEven;
      final r = isOuter ? outerR : innerR;
      final angle = (pi / n) * i - pi / 2;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final fill = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF6C8), Color(0xFFC8993F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: outerR))
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = const Color(0xFF7A4C0A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.4 : 1.8;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _GoldStarPainter oldDelegate) =>
      oldDelegate.isSelected != isSelected;
}
