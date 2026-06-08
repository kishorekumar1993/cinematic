import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

// Import Documentary templates
import '../presentation/tempelate/cinematic_scene_documentry_one.dart';
import '../presentation/tempelate/cinematic_scene_documentry_two.dart';
import '../presentation/tempelate/cinematic_scene_documentry_three.dart';
import '../presentation/tempelate/cinematic_scene_documentry_four.dart';
import '../presentation/tempelate/cinematic_scene_documentry_five.dart';
import '../presentation/tempelate/cinematic_scene_documentry_six.dart';
import '../presentation/tempelate/cinematic_scene_documentry_seven.dart';

// Import News templates
import '../presentation/tempelate/cinematic_scene_news_one.dart';
import '../presentation/tempelate/cinematic_scene_news_two.dart';
import '../presentation/tempelate/cinematic_scene_news_three.dart';
import '../presentation/tempelate/cinematic_scene_news_four.dart';
import '../presentation/tempelate/cinematic_scene_news_five.dart';
import '../presentation/tempelate/cinematic_scene_news_six.dart';
import '../presentation/tempelate/cinematic_scene_news_seven.dart';
import '../presentation/tempelate/cinematic_scene_news_eight.dart';
import '../presentation/tempelate/cinematic_scene_news_nine.dart';

// Import Netflix templates
import '../presentation/tempelate/cinematic_netflixtemp.dart';
import '../presentation/tempelate/cinematic_netflixtemp_two.dart';
import '../presentation/tempelate/cinematic_netflixtemp_three.dart';

// Import Special scene templates
import '../presentation/tempelate/cinematic_scene_history_reveal_one.dart';
import '../presentation/tempelate/cinematic_scene_four.dart';
import '../presentation/tempelate/cinematic_scene_five.dart';
import '../presentation/tempelate/cinematic_screen_six.dart';
import '../presentation/tempelate/cinematic_screen_three.dart';
import '../presentation/tempelate/cinematic_screen_two.dart';
import '../presentation/tempelate/cinematic_screen.dart';
import '../presentation/tempelate/movie_temp_one.dart';
import '../presentation/tempelate/youtube_movie_temp_two.dart';

// Import Devotional templates
import '../presentation/tempelate/devotional_scene_one.dart';
import '../presentation/tempelate/devotional_scene_two.dart';
import '../presentation/tempelate/devotional_scene_three.dart';
import '../presentation/tempelate/devotional_scene_four.dart';
import '../presentation/tempelate/devotional_scene_five.dart';
import '../presentation/tempelate/devotional_scene_six.dart';
import '../presentation/tempelate/devotional_scene_seven.dart';

// Import Dual Comparison templates
import '../presentation/dualscreen/dual_category_scene_screen.dart';
import '../presentation/dualscreen/dual_mirror_sceme.dart';
import '../presentation/dualscreen/dual_neo.dart';
import '../presentation/dualscreen/dualrankscene.dart';
import '../presentation/dualscreen/dualspotlight.dart';
import '../presentation/dualscreen/dual_banner_scene.dart';
import '../presentation/dualscreen/dual_smart_scene.dart';
import '../presentation/dualscreen/dual_status_scene.dart';
import '../presentation/dualscreen/dual_ribbon_scene.dart';

// Import Top Five Ranking templates
import '../presentation/topfivetemp/top_five_temp_one.dart';
import '../presentation/topfivetemp/top_five_temp_two.dart';

// Import Tutorial templates
import '../presentation/tempelate/tutorial/tutorial_scene_one.dart';
import '../presentation/tempelate/tutorial/tutorial_scene_two.dart';
import '../presentation/tempelate/tutorial/tutorial_scene_three.dart';
import '../presentation/tempelate/tutorial/tutorial_scene_four.dart';
import '../presentation/tempelate/tutorial/tutorial_scene_five.dart';
import '../presentation/tempelate/tutorial/tutorial_scene_six.dart';
import '../presentation/tempelate/tutorial/tutorial_scene_seven.dart';
import '../presentation/tempelate/tutorial/tutorial_scene_eight.dart';

typedef SceneTemplateBuilder = Widget Function(BuildContext context, SceneConfig scene, bool isPlaying);

class SceneTemplate {
  final String id;
  final String name;
  final String category;
  final String description;
  final String thumbnailUrl;
  final SceneTemplateBuilder builder;

  SceneTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.thumbnailUrl,
    required this.builder,
  });
}

class TemplateRegistry {
  static final Map<String, SceneTemplate> _templates = {};
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;

    // --- DOCUMENTARY PACK ---
    _register(SceneTemplate(
      id: 'documentary_six',
      name: 'Immersive Documentary',
      category: 'Documentary',
      description: 'Fullscreen narrative with large centered text and description.',
      thumbnailUrl: 'https://images.pexels.com/photos/3394939/pexels-photo-3394939.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneDocumentrySix(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'documentary_one',
      name: 'Classic Documentary',
      category: 'Documentary',
      description: 'Classic presentation layout with subtle bottom details.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneDocumentryOne(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'documentary_two',
      name: 'Split Documentary',
      category: 'Documentary',
      description: 'Clean split text frame with cinematic progress bars.',
      thumbnailUrl: 'https://images.pexels.com/photos/374693/pexels-photo-374693.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneDocumentryTwo(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'documentary_three',
      name: 'Historical Biography',
      category: 'Documentary',
      description: 'Premium historic biographical narrative theme.',
      thumbnailUrl: 'https://images.pexels.com/photos/4148864/pexels-photo-4148864.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneDocumentryThree(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'documentary_four',
      name: 'Narrative Focus',
      category: 'Documentary',
      description: 'Minimalistic design emphasizing key narration points.',
      thumbnailUrl: 'https://images.pexels.com/photos/160107/pexels-photo-160107.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneDocumentryFour(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'documentary_five',
      name: 'Spotlight Biography',
      category: 'Documentary',
      description: 'Clean centered spotlight focusing on the main figure.',
      thumbnailUrl: 'https://images.pexels.com/photos/3394939/pexels-photo-3394939.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneDocumentryFive(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'documentary_seven',
      name: 'Modern History',
      category: 'Documentary',
      description: 'Dynamic typography for presenting modern facts.',
      thumbnailUrl: 'https://images.pexels.com/photos/3394939/pexels-photo-3394939.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneDocumentrySeven(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    // --- NEWS PACK ---
    _register(SceneTemplate(
      id: 'news_one',
      name: 'Breaking News Ticker',
      category: 'News',
      description: 'Classic news frame with a scrolling live ticker.',
      thumbnailUrl: 'https://images.pexels.com/photos/374693/pexels-photo-374693.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneNewsOne(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'news_two',
      name: 'News Bulletin',
      category: 'News',
      description: 'Standard news presentation panel.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneNewsTwo(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'news_three',
      name: 'Headline Accent',
      category: 'News',
      description: 'High contrast highlight theme for core news updates.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneNewsThree(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'news_four',
      name: 'Interview Layout',
      category: 'News',
      description: 'A layout designed for side-by-side interviews or quotes.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneNewsFour(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'news_five',
      name: 'Lower Third Ticker',
      category: 'News',
      description: 'News frame containing standard lower-third captions.',
      thumbnailUrl: 'https://images.pexels.com/photos/374693/pexels-photo-374693.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneNewsFive(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'news_six',
      name: 'Live Report Panel',
      category: 'News',
      description: 'Live reporter interface with red indicators and tickers.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneNewsSix(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'news_seven',
      name: 'Financial Ticker',
      category: 'News',
      description: 'Ticker layout optimized for facts, lists, or metrics.',
      thumbnailUrl: 'https://images.pexels.com/photos/160107/pexels-photo-160107.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneNewsSeven(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'news_eight',
      name: 'Flash Headline',
      category: 'News',
      description: 'Clean bold layout for rapid breaking news notifications.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneNewsEight(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'news_nine',
      name: 'Press Conference',
      category: 'News',
      description: 'Clean grid-style layout for bulletins and quotes.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneNewsNine(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    // --- NETFLIX PACK ---
    _register(SceneTemplate(
      id: 'netflix_one',
      name: 'Netflix Poster Card',
      category: 'Netflix',
      description: 'Netflix inspired dynamic title poster layout.',
      thumbnailUrl: 'https://images.pexels.com/photos/3394939/pexels-photo-3394939.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicNetflixTemp(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'netflix_two',
      name: 'Netflix Episode Card',
      category: 'Netflix',
      description: 'Sleek dark theme styled as a Netflix Episode selector.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicNetflixTempTwo(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'netflix_three',
      name: 'Netflix Credits Style',
      category: 'Netflix',
      description: 'Clean slide overlay resembling standard credit cards.',
      thumbnailUrl: 'https://images.pexels.com/photos/160107/pexels-photo-160107.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicNetflixTempThree(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    // --- DUAL SCREEN PACK ---
    _register(SceneTemplate(
      id: 'dual_category',
      name: 'Dual Comparison Classic',
      category: 'Dual Screen',
      description: 'Classic side-by-side comparison with a VS badge.',
      thumbnailUrl: 'https://images.pexels.com/photos/374693/pexels-photo-374693.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => DualCategoryScene(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    // _register(SceneTemplate(
    //   id: 'dual_prime',
    //   name: 'Dual Master Prime',
    //   category: 'Dual Screen',
    //   description: 'Symmetric premium design with visual separation pillars.',
    //   thumbnailUrl: 'https://images.pexels.com/photos/4148864/pexels-photo-4148864.jpeg?auto=compress&cs=tinysrgb&w=300',
    //   builder: (context, scene, isPlaying) => DualPrimeScene(
    //     key: ValueKey(scene.id),
    //     scene: scene,
    //     isPlaying: isPlaying,
    //   ),
    // ));

    _register(SceneTemplate(
      id: 'dual_mirror',
      name: 'Dual Mirror Layout',
      category: 'Dual Screen',
      description: 'Mirror layout ideal for positive vs negative comparisons.',
      thumbnailUrl: 'https://images.pexels.com/photos/160107/pexels-photo-160107.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => DualMirrorScene(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'dual_neo',
      name: 'Dual Neo Theme',
      category: 'Dual Screen',
      description: 'Neomorphic elements for comparing tech or specifications.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => DualNeoScene(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'dual_rank',
      name: 'Dual Rank Layout',
      category: 'Dual Screen',
      description: 'Ranking design applied directly to dual side elements.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => DualRankScene(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'dual_spotlight',
      name: 'Dual Spotlight Layout',
      category: 'Dual Screen',
      description: 'Comparison track featuring background lighting highlights.',
      thumbnailUrl: 'https://images.pexels.com/photos/3394939/pexels-photo-3394939.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => DualSpotlightScene(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'dual_banner',
      name: 'Dual Banner Layout',
      category: 'Dual Screen',
      description: 'Comparison with centered top banner highlights.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => DualBannerScene(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'dual_smart',
      name: 'Dual Smart Layout',
      category: 'Dual Screen',
      description: 'Clean modern layout suited for quick visual matches.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => DualSmartScene(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'dual_status',
      name: 'Dual Status Comparison',
      category: 'Dual Screen',
      description: 'Compares indicators, metrics, or checklist status.',
      thumbnailUrl: 'https://images.pexels.com/photos/160107/pexels-photo-160107.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => DualStatusScene(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'dual_ribbon',
      name: 'Dual Ribbon Comparison',
      category: 'Dual Screen',
      description: 'Unique layout bounded by accent ribbons.',
      thumbnailUrl: 'https://images.pexels.com/photos/374693/pexels-photo-374693.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => DualRibbonScene(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    // --- TOP FIVE PACK ---
    _register(SceneTemplate(
      id: 'top_five_one',
      name: 'Top 5 Ranking Classic',
      category: 'Rankings',
      description: 'Classic ranking style showing score metrics and trophies.',
      thumbnailUrl: 'https://images.pexels.com/photos/4148864/pexels-photo-4148864.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneTopFiveRankingOne(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'top_five_two',
      name: 'Top 5 Ranking Neon',
      category: 'Rankings',
      description: 'Glow theme optimized with particle and bounce animations.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicTopFiveV2(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    // --- SPECIAL EFFECTS / CINEMA PACK ---
    _register(SceneTemplate(
      id: 'history_reveal',
      name: 'History Reveal',
      category: 'Cinema & Reveal',
      description: 'Cinematic layout with ancient themes, typewriter text.',
      thumbnailUrl: 'https://images.pexels.com/photos/4148864/pexels-photo-4148864.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneHistoryRevealOne(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'fullscreen_quote',
      name: 'Fullscreen Quote',
      category: 'Cinema & Reveal',
      description: 'Full width visual spotlight highlighting a center quote.',
      thumbnailUrl: 'https://images.pexels.com/photos/3394939/pexels-photo-3394939.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneFive(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'movie_one',
      name: 'Movie Classic Trailer',
      category: 'Cinema & Reveal',
      description: 'Classic movie theater widescreen display.',
      thumbnailUrl: 'https://images.pexels.com/photos/3394939/pexels-photo-3394939.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => MovieTempOne(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'movie_two',
      name: 'YouTube Showcase',
      category: 'Cinema & Reveal',
      description: 'Optimized for review channels and detailed summaries.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => YoutubeMovieTempTwo(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'cinematic_four',
      name: 'Focus Highlight',
      category: 'Cinema & Reveal',
      description: 'Highlighting core details with horizontal progress grids.',
      thumbnailUrl: 'https://images.pexels.com/photos/160107/pexels-photo-160107.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneFour(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'cinematic_six',
      name: 'Vibrant Border Accent',
      category: 'Cinema & Reveal',
      description: 'A layout bordered by glowing highlights.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicSceneSix(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'simple_title',
      name: 'Classic Card Overlay',
      category: 'Cinema & Reveal',
      description: 'Simple bottom panel covering background visual.',
      thumbnailUrl: 'https://images.pexels.com/photos/374693/pexels-photo-374693.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicScreen(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'screen_two',
      name: 'Modern Panel Overlay',
      category: 'Cinema & Reveal',
      description: 'Text block positioned in the center left grid.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicScreenTwo(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'screen_three',
      name: 'Split Frame Panel',
      category: 'Cinema & Reveal',
      description: 'Right aligned panel split for complex visual narration.',
      thumbnailUrl: 'https://images.pexels.com/photos/160107/pexels-photo-160107.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => CinematicScreenThree(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

  //   _register(SceneTemplate(
  //     id: 'screen_six',
  //     name: 'Accent Tag Border',
  //     category: 'Cinema & Reveal',
  //     description: 'Widescreen card bordered by neon category tags.',
  //     thumbnailUrl: 'https://images.pexels.com/photos/4148864/pexels-photo-4148864.jpeg?auto=compress&cs=tinysrgb&w=300',
  //     builder: (context, scene, isPlaying) => CinematicScreenSix(
  //       key: ValueKey(scene.id),
  //       scene: scene,
  //       isPlaying: isPlaying,
  //     ),
  //   ));

    // --- DEVOTIONAL PACK ---
    _register(SceneTemplate(
      id: 'devotional_one',
      name: 'Sacred Verse',
      category: 'Devotional',
      description: 'Deep indigo/violet with golden mandala ring and centred scripture verse.',
      thumbnailUrl: 'https://images.pexels.com/photos/3171837/pexels-photo-3171837.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => DevotionalSceneOne(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'devotional_two',
      name: 'Sunrise Praise',
      category: 'Devotional',
      description: 'Warm amber/crimson sunrise with animated light rays and morning devotion.',
      thumbnailUrl: 'https://images.pexels.com/photos/1261728/pexels-photo-1261728.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => DevotionalSceneTwo(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'devotional_three',
      name: 'Lotus Serenity',
      category: 'Devotional',
      description: 'Teal/emerald with animated floating lotus petals for spiritual mantras.',
      thumbnailUrl: 'https://images.pexels.com/photos/1051838/pexels-photo-1051838.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => DevotionalSceneThree(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'devotional_four',
      name: 'Celestial Prayer',
      category: 'Devotional',
      description: 'Midnight blue starfield with twinkling stars and golden celestial emblem.',
      thumbnailUrl: 'https://images.pexels.com/photos/1820563/pexels-photo-1820563.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => DevotionalSceneFour(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'devotional_five',
      name: 'Divine Light',
      category: 'Devotional',
      description: 'Holy white light column with parchment panel for scripture verses.',
      thumbnailUrl: 'https://images.pexels.com/photos/267967/pexels-photo-267967.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => DevotionalSceneFive(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'devotional_six',
      name: 'Sacred Flames',
      category: 'Devotional',
      description: 'Holy fire with ember particle system for powerful declarations.',
      thumbnailUrl: 'https://images.pexels.com/photos/266436/pexels-photo-266436.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => DevotionalSceneSix(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'devotional_seven',
      name: 'Peaceful Garden',
      category: 'Devotional',
      description: 'Sage green forest light with floating pollen for peaceful meditation verses.',
      thumbnailUrl: 'https://images.pexels.com/photos/355296/pexels-photo-355296.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => DevotionalSceneSeven(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    // --- TUTORIAL PACK ---
    _register(SceneTemplate(
      id: 'tutorial_one',
      name: 'Introduction Scene',
      category: 'Tutorial',
      description: 'Clean introduction template with large bold titles and clear step indicators.',
      thumbnailUrl: 'https://images.pexels.com/photos/3183150/pexels-photo-3183150.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => TutorialSceneOne(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'tutorial_two',
      name: 'Code Snippet Layout',
      category: 'Tutorial',
      description: 'Prioritizes code display using a sleek IDE-style window layout.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => TutorialSceneTwo(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'tutorial_three',
      name: 'Step-by-Step Guide',
      category: 'Tutorial',
      description: 'Focuses on expanding key points into large, readable bullet point layouts.',
      thumbnailUrl: 'https://images.pexels.com/photos/3184325/pexels-photo-3184325.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => TutorialSceneThree(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'tutorial_four',
      name: 'Tip Highlight',
      category: 'Tutorial',
      description: 'Highlights important tutorial tips using glowing borders and animations.',
      thumbnailUrl: 'https://images.pexels.com/photos/3394939/pexels-photo-3394939.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => TutorialSceneFour(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'tutorial_five',
      name: 'Split Screen Guide',
      category: 'Tutorial',
      description: 'Visuals on one side, and text instructions clearly laid out on the other.',
      thumbnailUrl: 'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => TutorialSceneFive(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'tutorial_six',
      name: 'Terminal Output Guide',
      category: 'Tutorial',
      description: 'Ideal for tech tutorials, displaying code execution in a mock terminal.',
      thumbnailUrl: 'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => TutorialSceneSix(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'tutorial_seven',
      name: 'Roadmap Guide',
      category: 'Tutorial',
      description: 'Clean path and timeline styling for sequential tutorial steps.',
      thumbnailUrl: 'https://images.pexels.com/photos/3183150/pexels-photo-3183150.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => TutorialSceneSeven(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _register(SceneTemplate(
      id: 'tutorial_eight',
      name: 'Floating Cards',
      category: 'Tutorial',
      description: 'Immersive floating 3D cards layout suitable for displaying up to 3 core concepts.',
      thumbnailUrl: 'https://images.pexels.com/photos/3394939/pexels-photo-3394939.jpeg?auto=compress&cs=tinysrgb&w=300',
      builder: (context, scene, isPlaying) => TutorialSceneEight(
        key: ValueKey(scene.id),
        scene: scene,
        isPlaying: isPlaying,
      ),
    ));

    _initialized = true;
  }

  static void _register(SceneTemplate template) {
    _templates[template.id] = template;
  }

  static SceneTemplate? get(String id) {
    init();
    return _templates[id];
  }

  static List<SceneTemplate> getAll() {
    init();
    return _templates.values.toList();
  }
}
