

  import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';


class Top5BannerSpotlightApp extends StatelessWidget {
  const Top5BannerSpotlightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BannerSpotlightScreen(),
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

/// ======================= YOUR JSON =======================

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

/// ======================= MAIN SCREEN (TEMPLATE 4) =======================

class BannerSpotlightScreen extends StatefulWidget {
  const BannerSpotlightScreen({super.key});

  @override
  State<BannerSpotlightScreen> createState() => _BannerSpotlightScreenState();
}

class _BannerSpotlightScreenState extends State<BannerSpotlightScreen>
    with SingleTickerProviderStateMixin {
  late final TopListConfig config;
  int selectedIndex = 0;
  Timer? _timer;
  late AnimationController _sceneController;

  @override
  void initState() {
    super.initState();
    final map = jsonDecode(_configJson) as Map<String, dynamic>;
    config = TopListConfig.fromJson(map);

    _sceneController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    final scene = config.scenes[selectedIndex];
    _timer = Timer(Duration(seconds: scene.durationSeconds), () {
      if (!mounted) return;
      setState(() {
        selectedIndex = (selectedIndex + 1) % config.scenes.length;
      });
      _sceneController
        ..reset()
        ..forward();
      _startTimer();
    });

    _sceneController
      ..reset()
      ..forward();
  }

  void _onRankTap(int rank) {
    final idx = rank - 1;
    if (idx == selectedIndex) return;
    setState(() => selectedIndex = idx);
    _sceneController
      ..reset()
      ..forward();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sceneController.dispose();
    super.dispose();
  }



@override
  Widget build(BuildContext context) {
    final scenes = config.scenes;
    final scene = scenes[selectedIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF05081C), Color(0xFF14021B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              children: [
                _HeaderBanner(
                  title: config.title,
                  subtitle: config.subtitle,
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = min(constraints.maxWidth, 1200.0);
                        return SizedBox(
                          width: width,
                          child: AnimatedBuilder(
                            animation: _sceneController,
                            builder: (context, child) {
                              final t = Curves.easeOutQuad
                                  .transform(_sceneController.value);
                              final scale = lerpDouble(0.96, 1.0, t)!;
                              final opacity = t;
                              return Opacity(
                                opacity: opacity,
                                child: Transform.scale(
                                  scale: scale,
                                  child: _HeroBannerCard(
                                    scene: scene,
                                    rank: selectedIndex + 1,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _BottomRankStrip(
                  scenes: scenes,
                  selectedIndex: selectedIndex,
                  onRankTap: _onRankTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ======================= HEADER =======================

class _HeaderBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderBanner({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFC857), Color(0xFFFF5E5B)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xAAFF5E5B),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha:0.88),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// ======================= HERO BANNER CARD =======================

class _HeroBannerCard extends StatelessWidget {
  final MovieSceneConfig scene;
  final int rank;

  const _HeroBannerCard({
    required this.scene,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Poster background with Ken Burns effect
            _PosterBackground(scene: scene),

            // Dark gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha:0.65),
                      Colors.black.withValues(alpha:0.15),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),

            // top-left rank badge
            Positioned(
              left: 18,
              top: 14,
              child: _RankBadge(rank: rank),
            ),

            // bottom glass info panel
            Positioned(
              left: 18,
              right: 18,
              bottom: 16,
              child: _GlassInfoPanel(scene: scene),
            ),
          ],
        ),
      ),
    );
  }
}

/// ======================= POSTER BACKGROUND =======================

class _PosterBackground extends StatefulWidget {
  final MovieSceneConfig scene;

  const _PosterBackground({required this.scene});

  @override
  State<_PosterBackground> createState() => _PosterBackgroundState();
}

class _PosterBackgroundState extends State<_PosterBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _configure();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _PosterBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.id != widget.scene.id) {
      _configure();
      _controller
        ..reset()
        ..forward();
    }
  }

  void _configure() {
    switch (widget.scene.effect) {
      case 'zoom_in':
        _scaleAnim = Tween<double>(begin: 1.08, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
        _offsetAnim = const AlwaysStoppedAnimation<Offset>(Offset.zero);
        break;
      case 'zoom_out':
        _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
        _offsetAnim = const AlwaysStoppedAnimation<Offset>(Offset.zero);
        break;
      case 'pan_left':
        _scaleAnim = const AlwaysStoppedAnimation(1.05);
        _offsetAnim = Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
        );
        break;
      case 'pan_right':
        _scaleAnim = const AlwaysStoppedAnimation(1.05);
        _offsetAnim = Tween<Offset>(
          begin: const Offset(-0.06, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
        );
        break;
      default:
        _scaleAnim = const AlwaysStoppedAnimation(1.0);
        _offsetAnim = const AlwaysStoppedAnimation<Offset>(Offset.zero);
    }
  }

  Widget _buildImage() {
    if (widget.scene.imageUrl.isEmpty) {
      return SizedBox.expand(
        child: Container(
          color: const Color(0xFF11121F),
          child: const Center(
            child: Icon(Icons.movie, color: Colors.white54, size: 40),
          ),
        ),
      );
    }
    return SizedBox.expand(
      child: Image.network(
        widget.scene.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            color: const Color(0xFF11121F),
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: FractionalTranslation(
              translation: _offsetAnim.value,
              child: _buildImage(),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// ======================= RANK BADGE =======================

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC857), Color(0xFFFF5E5B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xAAFF5E5B),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$rank',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'TOP',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================= GLASS INFO PANEL =======================

class _GlassInfoPanel extends StatelessWidget {
  final MovieSceneConfig scene;

  const _GlassInfoPanel({required this.scene});

  @override
  Widget build(BuildContext context) {
    Offset beginOffset;
    switch (scene.textEffect) {
      case 'slide_left':
        beginOffset = const Offset(0.14, 0);
        break;
      case 'slide_up':
        beginOffset = const Offset(0, 0.16);
        break;
      default:
        beginOffset = Offset.zero;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: TweenAnimationBuilder<Offset>(
          duration: const Duration(milliseconds: 450),
          tween: Tween(begin: beginOffset, end: Offset.zero),
          curve: Curves.easeOutCubic,
          builder: (context, offset, child) {
            final opacity =
                1.0 - (offset.dx.abs() + offset.dy.abs()).clamp(0.0, 0.8);
            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(offset.dx * 40, offset.dy * 40),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha:0.65),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha:0.2),
                width: 1,
              ),
            ),
            child: _InfoPanelInner(scene: scene),
          ),
        ),
      ),
    );
  }
}

class _InfoPanelInner extends StatelessWidget {
  final MovieSceneConfig scene;

  const _InfoPanelInner({required this.scene});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title + subtitle chip
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
                  fontSize: 17.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC857), Color(0xFFFF5E5B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                scene.subtitle,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10.5,
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
            color: Color(0xFF9CF3FF),
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),

        // body + tags
        SizedBox(
          height: 72,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scene.body,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: scene.keyPoints.map((p) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.black.withValues(alpha:0.6),
                        border: Border.all(
                          color: const Color(0xFF9CF3FF),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        p,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),

        // closure line
        if (scene.closureLine != null) ...[
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Color(0xFF00FFA1), Color(0xFF00C853)],
              ),
            ),
            child: Text(
              scene.closureLine!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// ======================= BOTTOM RANK STRIP =======================

class _BottomRankStrip extends StatelessWidget {
  final List<MovieSceneConfig> scenes;
  final int selectedIndex;
  final void Function(int rank) onRankTap;

  const _BottomRankStrip({
    required this.scenes,
    required this.selectedIndex,
    required this.onRankTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = min(constraints.maxWidth, 1100.0);
      return SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final rank = i + 1;
            final index = rank - 1;
            final scene = scenes[index];
            final isSelected = index == selectedIndex;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 0 : 6,
                  right: i == 4 ? 0 : 6,
                ),
                child: _RankChip(
                  rank: rank,
                  title: scene.title,
                  isSelected: isSelected,
                  onTap: () => onRankTap(rank),
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}

class _RankChip extends StatelessWidget {
  final int rank;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _RankChip({
    required this.rank,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = isSelected
        ? const LinearGradient(
            colors: [Color(0xFFFFC857), Color(0xFFFF5E5B)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF151827), Color(0xFF090A16)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final textColor = isSelected ? Colors.black : Colors.white70;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: gradient,
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha:0.18),
          ),
          boxShadow: [
            if (isSelected)
              const BoxShadow(
                color: Color(0xAAFF5E5B),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.black.withValues(alpha:0.12)
                    : const Color(0xFF20243C),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}