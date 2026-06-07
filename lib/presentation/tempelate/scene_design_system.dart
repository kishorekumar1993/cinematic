import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';

// =============================================================================
// SCENE DESIGN SYSTEM
// Centralized design tokens and widgets for all cinematic scene templates.
// Ensures visual consistency, safe-area compliance, and Shorts/Reels readiness.
// =============================================================================

// -----------------------------------------------------------------------------
// COLOR PALETTE
// -----------------------------------------------------------------------------

class SceneColors {
  SceneColors._();

  /// Brand primaries
  static const Color gold        = Color(0xFFFACC15); // Amber-400
  static const Color goldDeep    = Color(0xFFB45309); // Amber-800
  static const Color goldLight   = Color(0xFFFDE68A); // Amber-200
  static const Color orange      = Color(0xFFF97316); // Orange-500
  static const Color white       = Colors.white;
  static const Color black       = Colors.black;

  /// News/Alert
  static const Color red         = Color(0xFFEF4444);
  static const Color redDeep     = Color(0xFF991B1B);

  /// Cool tones (for tech/news)
  static const Color blue        = Color(0xFF3B82F6);
  static const Color blueDeep    = Color(0xFF1E3A5F);

  /// Overlays
  static Color overlay(double opacity) => Colors.black.withValues(alpha: opacity);
  static Color whiteOverlay(double opacity) => Colors.white.withValues(alpha: opacity);
  static Color goldOverlay(double opacity) => gold.withValues(alpha: opacity);

  /// Category-based color grades
  static Color gradeFor(String category) {
    switch (category.toLowerCase()) {
      case 'history':
      case 'documentary':
        return const Color(0xFFFACC15).withValues(alpha: 0.08); // warm amber
      case 'news':
        return const Color(0xFF3B82F6).withValues(alpha: 0.06); // cool blue
      case 'netflix':
        return const Color(0xFFEF4444).withValues(alpha: 0.06); // Netflix red
      default:
        return Colors.transparent;
    }
  }
}

// -----------------------------------------------------------------------------
// TYPOGRAPHY SYSTEM
// All sizes are tuned for 9:16 portrait video (1080×1920 reference)
// -----------------------------------------------------------------------------

class SceneTypography {
  SceneTypography._();

  static const String _font = 'Poppins';

  // Hook frame — large centered hero text (0-3s)
  static const TextStyle hookHero = TextStyle(
    fontFamily: _font,
    fontSize: 52,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    height: 1.05,
    letterSpacing: -1.5,
  );

  // Main scene title
  static const TextStyle mainTitle = TextStyle(
    fontFamily: _font,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // Secondary / supporting title
  static const TextStyle title = TextStyle(
    fontFamily: _font,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.25,
  );

  // Subtitle / category label
  static const TextStyle subtitle = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.5,
    color: SceneColors.gold,
  );

  // Hook line (italic sub-head under title)
  static const TextStyle hookLine = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontStyle: FontStyle.italic,
    color: SceneColors.goldLight,
    height: 1.4,
  );

  // Body paragraph
  static const TextStyle body = TextStyle(
    fontFamily: _font,
    fontSize: 14.5,
    height: 1.55,
    color: Color(0xCCFFFFFF), // white 80%
  );

  // Key point bullet
  static const TextStyle keyPoint = TextStyle(
    fontFamily: _font,
    fontSize: 13.5,
    height: 1.4,
    color: Color(0xCCFFFFFF),
  );

  // Closure / punch line
  static const TextStyle closureLine = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: SceneColors.gold,
    height: 1.3,
  );

  // Tag / badge text
  static const TextStyle tag = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.8,
    color: Colors.black,
  );

  // Word-by-word large word display
  static const TextStyle wordByWord = TextStyle(
    fontFamily: _font,
    fontSize: 44,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    height: 1.1,
    letterSpacing: -0.5,
  );
}

// -----------------------------------------------------------------------------
// LAYOUT / SAFE AREA
// -----------------------------------------------------------------------------

class SceneLayout {
  SceneLayout._();

  /// Safe zone percentages for Shorts/Reels/TikTok
  static const double safeTopFraction    = 0.12; // top 12% = unsafe
  static const double safeBottomFraction = 0.22; // bottom 22% = unsafe

  /// Returns absolute safe padding for a given context
  static EdgeInsets safeInsets(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return EdgeInsets.only(
      top:    size.height * safeTopFraction,
      bottom: size.height * safeBottomFraction,
      left:   22,
      right:  22,
    );
  }

  /// Safe bottom padding (for Positioned widgets)
  static double safeBottom(BuildContext context) =>
      MediaQuery.sizeOf(context).height * safeBottomFraction;

  /// Safe top padding (for Positioned widgets)
  static double safeTop(BuildContext context) =>
      MediaQuery.sizeOf(context).height * safeTopFraction;

  /// Standard content padding inside glass panels
  static const EdgeInsets panelPadding =
      EdgeInsets.fromLTRB(20, 18, 20, 18);

  /// Max width for text content in landscape/tablet
  static const double maxContentWidth = 720;
}

// -----------------------------------------------------------------------------
// MOTION PRESETS
// -----------------------------------------------------------------------------

enum SceneMotion {
  zoomIn,
  zoomOut,
  kenBurns, // diagonal zoom+pan
  panRight,
  panLeft,
  pushUp,
  staticFrame,
}

class SceneMotionPreset {
  SceneMotionPreset._();

  /// Resolve motion enum from scene.effect string
  static SceneMotion fromString(String effect) {
    switch (effect) {
      case 'zoom_out':    return SceneMotion.zoomOut;
      case 'ken_burns':   return SceneMotion.kenBurns;
      case 'pan_right':   return SceneMotion.panRight;
      case 'pan_left':    return SceneMotion.panLeft;
      case 'push_up':     return SceneMotion.pushUp;
      case 'static':      return SceneMotion.staticFrame;
      case 'zoom_in':
      default:            return SceneMotion.zoomIn;
    }
  }

  /// Returns a configured zoom animation based on motion preset
  static Animation<double> buildZoom(
      AnimationController controller, SceneMotion motion) {
    switch (motion) {
      case SceneMotion.zoomOut:
        return Tween<double>(begin: 1.15, end: 1.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOut),
        );
      case SceneMotion.kenBurns:
        return Tween<double>(begin: 1.0, end: 1.08).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        );
      case SceneMotion.staticFrame:
        return Tween<double>(begin: 1.0, end: 1.0).animate(controller);
      default:
        return Tween<double>(begin: 1.0, end: 1.14).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOut),
        );
    }
  }

  /// Returns a configured pan animation based on motion preset
  static Animation<Offset> buildPan(
      AnimationController controller, SceneMotion motion) {
    switch (motion) {
      case SceneMotion.kenBurns:
        return Tween<Offset>(
          begin: const Offset(-0.02, -0.012),
          end:   const Offset( 0.02,  0.012),
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
      case SceneMotion.panRight:
        return Tween<Offset>(
          begin: const Offset(-0.04, 0.0),
          end:   const Offset( 0.04, 0.0),
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
      case SceneMotion.panLeft:
        return Tween<Offset>(
          begin: const Offset( 0.04, 0.0),
          end:   const Offset(-0.04, 0.0),
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
      case SceneMotion.pushUp:
        return Tween<Offset>(
          begin: const Offset(0.0,  0.03),
          end:   const Offset(0.0, -0.03),
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
      default:
        return Tween<Offset>(begin: Offset.zero, end: Offset.zero)
            .animate(controller);
    }
  }
}

// -----------------------------------------------------------------------------
// SHARED BACKGROUND BUILDER
// Eliminates duplicated image-loading code across 29+ templates
// -----------------------------------------------------------------------------

class SceneBackground extends StatelessWidget {
  final Uint8List? localImageBytes;
  final String imageUrl;
  final Animation<double>? zoom;
  final Animation<Offset>? pan;

  const SceneBackground({
    super.key,
    this.localImageBytes,
    this.imageUrl = '',
    this.zoom,
    this.pan,
  });

  Widget _imageWidget() {
    if (localImageBytes is Uint8List && localImageBytes!.isNotEmpty) {
      return Image.memory(
        localImageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(SceneColors.gold),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFF0A0A0A),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined,
          size: 48, color: Colors.white24),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget img = _imageWidget();

    if (zoom != null || pan != null) {
      // Capture the original image widget in a separate variable so the
      // AnimatedBuilder's closure does not close over the reassigned `img`
      // (which would create an infinitely self-referential widget tree).
      final Widget base = img;
      img = AnimatedBuilder(
        animation: Listenable.merge([
          if (zoom != null) zoom!,
          if (pan != null) pan!,
        ]),
        builder: (_, __) => FractionalTranslation(
          translation: pan?.value ?? Offset.zero,
          child: Transform.scale(
            scale: zoom?.value ?? 1.0,
            child: base,
          ),
        ),
      );
    }
    return img;
  }
}

// -----------------------------------------------------------------------------
// CINEMATIC OVERLAYS (Vignette, Color Grade, Letterbox)
// -----------------------------------------------------------------------------

class SceneVignette extends StatelessWidget {
  /// intensity: 0.0 (none) → 1.0 (full cinematic)
  final double intensity;
  final RadialGradient? customGradient;

  const SceneVignette({super.key, this.intensity = 0.75, this.customGradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: customGradient ??
            RadialGradient(
              center: Alignment.center,
              radius: 1.1,
              colors: [
                Colors.black.withValues(alpha: 0.0),
                Colors.black.withValues(alpha: intensity),
              ],
              stops: const [0.38, 1.0],
            ),
      ),
    );
  }
}

class SceneBottomGradient extends StatelessWidget {
  final double strength;
  const SceneBottomGradient({super.key, this.strength = 0.95});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: strength),
            Colors.black.withValues(alpha: 0.45),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

/// Optional cinematic letterbox (widescreen black bars)
class SceneLetterbox extends StatelessWidget {
  final double barFraction; // fraction of total height per bar, default 0.07
  const SceneLetterbox({super.key, this.barFraction = 0.07});

  @override
  Widget build(BuildContext context) {
    final barH = MediaQuery.sizeOf(context).height * barFraction;
    // Use Stack + Positioned instead of Column + Spacer so this widget is
    // safe in both bounded and expand contexts (Spacer requires bounded height).
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(top: 0, left: 0, right: 0, height: barH,
          child: Container(color: Colors.black)),
        Positioned(bottom: 0, left: 0, right: 0, height: barH,
          child: Container(color: Colors.black)),
      ],
    );
  }
}

/// Warm or cool color tint overlay
class SceneColorGrade extends StatelessWidget {
  final Color color;
  final double opacity;
  const SceneColorGrade({super.key, required this.color, this.opacity = 0.07});

  @override
  Widget build(BuildContext context) {
    return Container(color: color.withValues(alpha: opacity));
  }
}

// -----------------------------------------------------------------------------
// GOLD ACCENT LINE (used in many templates)
// -----------------------------------------------------------------------------

class SceneGoldAccent extends StatelessWidget {
  final double width;
  final double height;
  const SceneGoldAccent({super.key, this.width = 48, this.height = 3.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(colors: [
          SceneColors.gold,
          SceneColors.goldDeep,
        ]),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// GLASS PANEL (unified glassmorphism card)
// -----------------------------------------------------------------------------

class SceneGlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;
  final double backgroundOpacity;
  final Color borderColor;
  final BorderRadius borderRadius;
  final List<BoxShadow>? shadows;

  const SceneGlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.blurSigma = 18,
    this.backgroundOpacity = 0.78,
    this.borderColor = const Color(0x8DFACC15), // gold 55%
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding ?? SceneLayout.panelPadding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: Colors.black.withValues(alpha: backgroundOpacity),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: shadows ??
                [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.85),
                    blurRadius: 24,
                    offset: const Offset(0, 16),
                  ),
                ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// GOLD BADGE (documentary / category label)
// -----------------------------------------------------------------------------

class SceneGoldBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  const SceneGoldBadge({super.key, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
            colors: [SceneColors.gold, SceneColors.goldDeep]),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: Colors.black),
            const SizedBox(width: 5),
          ],
          Text(text, style: SceneTypography.tag),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HOOK FRAME WIDGET
// Full-screen large-text hero for the first 0-3 seconds of a scene.
// Shows a big hook text over the background, then fades out.
// -----------------------------------------------------------------------------

class SceneHookFrame extends StatelessWidget {
  /// The hook text to display (from scene.hook)
  final String hookText;

  /// Animation value 0→1 for fade-out (pass the hook phase animation)
  /// 0 = fully visible, 1 = fully faded out
  final double exitOpacity;

  const SceneHookFrame({
    super.key,
    required this.hookText,
    this.exitOpacity = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Opacity(
      opacity: (1.0 - exitOpacity).clamp(0.0, 1.0),
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.08,
          vertical: size.height * 0.15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative top line
            const SceneGoldAccent(width: 40, height: 2.5),
            const SizedBox(height: 20),
            Text(
              hookText,
              textAlign: TextAlign.center,
              style: SceneTypography.hookHero.copyWith(
                shadows: [
                  const Shadow(
                    blurRadius: 24,
                    color: Colors.black,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SceneGoldAccent(width: 40, height: 2.5),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WORD-BY-WORD REVEAL ANIMATION
// Staggers each word's opacity+slide for dynamic subtitle feel
// -----------------------------------------------------------------------------

class WordRevealText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final AnimationController controller;

  /// Fraction of controller duration to start the animation [0.0–1.0]
  final double startFraction;

  /// Fraction of controller duration over which all words animate [0.0–1.0]
  final double durationFraction;

  const WordRevealText({
    super.key,
    required this.text,
    required this.style,
    required this.controller,
    this.textAlign = TextAlign.start,
    this.startFraction = 0.1,
    this.durationFraction = 0.5,
  });

  @override
  State<WordRevealText> createState() => _WordRevealTextState();
}

class _WordRevealTextState extends State<WordRevealText> {
  late List<String> _words;
  late List<Animation<double>> _fadeAnims;
  late List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _build();
  }

  void _build() {
    _words = widget.text.split(' ').where((w) => w.isNotEmpty).toList();
    _fadeAnims = [];
    _slideAnims = [];

    final total = _words.length;
    if (total == 0) return;

    final start = widget.startFraction;
    final end   = (widget.startFraction + widget.durationFraction).clamp(0.0, 1.0);
    final range = end - start;

    // Each word gets a staggered window
    for (int i = 0; i < total; i++) {
      final wordStart = start + (range * i / total);
      final wordEnd   = (wordStart + (range / total * 1.8)).clamp(0.0, 1.0);

      final curve = CurvedAnimation(
        parent: widget.controller,
        curve: Interval(wordStart, wordEnd, curve: Curves.easeOut),
      );

      _fadeAnims.add(Tween<double>(begin: 0.0, end: 1.0).animate(curve));
      _slideAnims.add(Tween<Offset>(
        begin: const Offset(0.0, 0.25),
        end: Offset.zero,
      ).animate(curve));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        return Wrap(
          alignment: widget.textAlign == TextAlign.center
              ? WrapAlignment.center
              : WrapAlignment.start,
          spacing: 6.0,
          runSpacing: 2.0,
          children: List.generate(_words.length, (i) {
            return FadeTransition(
              opacity: _fadeAnims[i],
              child: SlideTransition(
                position: _slideAnims[i],
                child: Text(_words[i], style: widget.style),
              ),
            );
          }),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// KEY POINTS LIST (reusable bullet list with gold dots)
// -----------------------------------------------------------------------------

class SceneKeyPoints extends StatelessWidget {
  final List<String> points;
  final int maxPoints;
  const SceneKeyPoints({
    super.key,
    required this.points,
    this.maxPoints = 3,
  });

  @override
  Widget build(BuildContext context) {
    final display = points.take(maxPoints).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: display.map((kp) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: SceneColors.gold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(kp, style: SceneTypography.keyPoint)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// -----------------------------------------------------------------------------
// SAFE AREA PREVIEW GUIDE (editor-only overlay)
// Shows red bands at top 12% and bottom 22% when enabled
// -----------------------------------------------------------------------------

class SceneSafeAreaGuide extends StatelessWidget {
  final bool show;
  const SceneSafeAreaGuide({super.key, this.show = false});

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    final size = MediaQuery.sizeOf(context);
    final topH    = size.height * SceneLayout.safeTopFraction;
    final bottomH = size.height * SceneLayout.safeBottomFraction;

    return Stack(children: [
      // Top unsafe zone
      Positioned(
        top: 0, left: 0, right: 0, height: topH,
        child: Container(
          color: Colors.red.withValues(alpha: 0.25),
          child: Center(
            child: Text('UNSAFE ZONE — TOP 12%',
                style: const TextStyle(
                    fontSize: 10, color: Colors.red, letterSpacing: 1.5)),
          ),
        ),
      ),
      // Bottom unsafe zone
      Positioned(
        bottom: 0, left: 0, right: 0, height: bottomH,
        child: Container(
          color: Colors.red.withValues(alpha: 0.25),
          child: Center(
            child: Text('UNSAFE ZONE — BOTTOM 22%',
                style: const TextStyle(
                    fontSize: 10, color: Colors.red, letterSpacing: 1.5)),
          ),
        ),
      ),
    ]);
  }
}
