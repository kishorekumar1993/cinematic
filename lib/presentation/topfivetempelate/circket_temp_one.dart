import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const CricketSpotlightApp());
}

class CricketSpotlightApp extends StatelessWidget {
  const CricketSpotlightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CricketSpotlightScreen(),
    );
  }
}

/// ========== DATA MODELS (same as your movies JSON) ===================

class PlayerSceneConfig {
  final String id;
  final String title;
  final String subtitle;
  final String hook;
  final String body;
  final List<String> keyPoints;
  final String imageUrl;
  final int durationSeconds;
  final String effect;
  final String textEffect;

  PlayerSceneConfig({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.hook,
    required this.body,
    required this.keyPoints,
    required this.imageUrl,
    required this.durationSeconds,
    required this.effect,
    required this.textEffect,
  });

  factory PlayerSceneConfig.fromJson(Map<String, dynamic> json) {
    return PlayerSceneConfig(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      hook: json['hook'],
      body: json['body'],
      keyPoints:
          (json['keyPoints'] as List<dynamic>).map((e) => e.toString()).toList(),
      imageUrl: json['imageUrl'] ?? '',
      durationSeconds: json['durationSeconds'],
      effect: json['effect'],
      textEffect: json['textEffect'],
    );
  }
}

class TopPlayerConfig {
  final String title;
  final String subtitle;
  final List<PlayerSceneConfig> players;

  TopPlayerConfig({
    required this.title,
    required this.subtitle,
    required this.players,
  });

  factory TopPlayerConfig.fromJson(Map<String, dynamic> json) {
    return TopPlayerConfig(
      title: json['title'],
      subtitle: json['subtitle'],
      players: (json['players'] as List<dynamic>)
          .map((e) => PlayerSceneConfig.fromJson(e))
          .toList(),
    );
  }
}

/// ========== CRICKET JSON ===================

const String cricketJson = r'''
{
  "title": "Top 5 Cricket Stars 2025",
  "subtitle": "World Power Rankings",
  "players": [
    {
      "id": "kohli",
      "title": "1. Virat Kohli 🇮🇳",
      "subtitle": "King of Consistency",
      "hook": "World’s best run chaser!",
      "body": "Matches: 26 | Runs: 1200+ | Avg: 56",
      "keyPoints": ["100s: 3", "MOTM: 7", "Chase King"],
      "imageUrl": "https://i.imgur.com/1bh5Yq7.jpg",
      "durationSeconds": 8,
      "effect": "zoom_in",
      "textEffect": "slide_up"
    },
    {
      "id": "afg",
      "title": "2. Rahmanullah Gurbaz 🇦🇫",
      "subtitle": "Afghan Power Hitter",
      "hook": "Fearless opening beast",
      "body": "Explosive starts every match!",
      "keyPoints": ["SR: 152", "6s per match: 3", "T20 Star"],
      "imageUrl": "https://i.imgur.com/QyL4ijE.jpg",
      "durationSeconds": 8,
      "effect": "zoom_out",
      "textEffect": "fade"
    },
    {
      "id": "pak",
      "title": "3. Babar Azam 🇵🇰",
      "subtitle": "Classic Stroke Master",
      "hook": "Elegance + Consistency",
      "body": "Top 3 ICC batsmen ranking.",
      "keyPoints": ["Cover Drive King", "Avg: 49+"],
      "imageUrl": "https://i.imgur.com/8UoFzlC.jpg",
      "durationSeconds": 8,
      "effect": "pan_right",
      "textEffect": "slide_up"
    },
    {
      "id": "eng",
      "title": "4. Jos Buttler 🏴",
      "subtitle": "T20 Finisher",
      "hook": "Unpredictable match winner!",
      "body": "Explosive death overs monster.",
      "keyPoints": ["SR: 160+", "Fearless"],
      "imageUrl": "https://i.imgur.com/Ze7nPrt.jpg",
      "durationSeconds": 8,
      "effect": "pan_left",
      "textEffect": "slide_up"
    },
    {
      "id": "aus",
      "title": "5. Travis Head 🇦🇺",
      "subtitle": "Big Match Beast",
      "hook": "Turns finals into playground!",
      "body": "Player of World Cup Final 2023.",
      "keyPoints": ["Impact Player"],
      "imageUrl": "https://i.imgur.com/2OdcD9w.jpg",
      "durationSeconds": 8,
      "effect": "zoom_in",
      "textEffect": "fade"
    }
  ]
}
''';

/// ========== MAIN SCREEN UI ===================

class CricketSpotlightScreen extends StatefulWidget {
  const CricketSpotlightScreen({super.key});

  @override
  State<CricketSpotlightScreen> createState() =>
      _CricketSpotlightScreenState();
}

class _CricketSpotlightScreenState extends State<CricketSpotlightScreen>
    with SingleTickerProviderStateMixin {
  late TopPlayerConfig config;
  int currentIndex = 0;
  Timer? timer;
  late AnimationController animCtrl;

  @override
  void initState() {
    super.initState();
    config = TopPlayerConfig.fromJson(jsonDecode(cricketJson));

    animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _startAutoCycle();
  }

  void _startAutoCycle() {
    timer?.cancel();
    final scene = config.players[currentIndex];

    timer = Timer(Duration(seconds: scene.durationSeconds), () {
      setState(() => currentIndex = (currentIndex + 1) % config.players.length);
      animCtrl
        ..reset()
        ..forward();
      _startAutoCycle();
    });

    animCtrl
      ..reset()
      ..forward();
  }

  void _selectRank(int index) {
    setState(() => currentIndex = index);
    animCtrl
      ..reset()
      ..forward();
    _startAutoCycle();
  }

  @override
  void dispose() {
    timer?.cancel();
    animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = config.players[currentIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001F38), Color(0xFF000A1B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _HeaderBanner(
                  title: config.title,
                  subtitle: config.subtitle,
                ),
                const SizedBox(height: 16),

                // CENTER POSTER
                Expanded(
                  child: AnimatedBuilder(
                    animation: animCtrl,
                    builder: (context, _) {
                      final t = animCtrl.value;
                      final scale = lerpDouble(0.95, 1, t)!;
                      final opacity = t;
                      return Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: PlayerHeroCard(
                            player: player,
                            rank: currentIndex + 1,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // RANK STRIP
                Row(
                  children: List.generate(
                    config.players.length,
                    (i) {
                      final scene = config.players[i];
                      final selected = i == currentIndex;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _selectRank(i),
                          child: _RankChip(
                            rank: i + 1,
                            title: scene.title,
                            selected: selected,
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
}

/// ========== HEADER ===================

class _HeaderBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderBanner({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha:0.4),
                blurRadius: 12,
              )
            ],
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha:0.75),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// ========== PLAYER HERO CARD ===================

class PlayerHeroCard extends StatelessWidget {
  final PlayerSceneConfig player;
  final int rank;

  const PlayerHeroCard({required this.player, required this.rank});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          // Poster Background
          Positioned.fill(
            child: Image.network(
              player.imageUrl,
              fit: BoxFit.cover,
            ),
          ),

          // Shadow overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha:0.6),
                    Colors.black.withValues(alpha:0.15)
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // Rank Badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                ),
              ),
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // INFO PANEL GLASS
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.black.withValues(alpha:0.55),
                  child: _Info(player: player),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final PlayerSceneConfig player;
  const _Info({required this.player});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          player.title,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          player.subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha:0.85),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          player.hook,
          style: const TextStyle(
            color: Color(0xFF00F4FF),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),

        // Stats
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: player.keyPoints.map((p) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                ),
              ),
              child: Text(
                p,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// ========== BOTTOM STRIP CHIP ===================

class _RankChip extends StatelessWidget {
  final int rank;
  final String title;
  final bool selected;

  const _RankChip({
    required this.rank,
    required this.title,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: selected
            ? const LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)])
            : const LinearGradient(colors: [
                Color(0xFF0D0F1B),
                Color(0xFF09101B)
              ]),
        border: Border.all(
          color: selected
              ? Colors.white
              : Colors.white.withValues(alpha:0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha:0.1),
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white70,
                fontWeight:
                    selected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
