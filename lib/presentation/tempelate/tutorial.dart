import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinematic/model/screen_config.dart';

class CinematicSceneTutorial extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const CinematicSceneTutorial({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<CinematicSceneTutorial> createState() =>
      _CinematicSceneTutorialState();
}

class _CinematicSceneTutorialState
    extends State<CinematicSceneTutorial>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _zoom;
  late Animation<Offset> _pan;

  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: widget.scene.durationSeconds.clamp(5, 90),
      ),
    );

    _setupAnimations();

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  void _setupAnimations() {
    final effect = widget.scene.effect.toLowerCase();

    double zoomBegin = 1.0;
    double zoomEnd = 1.08;

    Offset panBegin = Offset.zero;
    Offset panEnd = Offset.zero;

    switch (effect) {
      case 'zoom_out':
        zoomBegin = 1.08;
        zoomEnd = 1.0;
        break;

      case 'pan_right':
        panBegin = const Offset(-0.03, 0);
        panEnd = const Offset(0.03, 0);
        break;

      case 'pan_left':
        panBegin = const Offset(0.03, 0);
        panEnd = const Offset(-0.03, 0);
        break;

      case 'zoom_in':
      default:
        zoomBegin = 1.0;
        zoomEnd = 1.08;
    }

    _zoom = Tween<double>(
      begin: zoomBegin,
      end: zoomEnd,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    _pan = Tween<Offset>(
      begin: panBegin,
      end: panEnd,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    final textCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.15,
        0.8,
        curve: Curves.easeOutCubic,
      ),
    );

    _textFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(textCurve);

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(textCurve);
  }

  @override
  void didUpdateWidget(covariant CinematicSceneTutorial oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _controller.forward(from: 0);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBackground() {
    if (widget.scene.localImageBytes != null) {
      return Image.memory(
        widget.scene.localImageBytes!,
        fit: BoxFit.cover,
      );
    }

    if (widget.scene.imageUrl.isNotEmpty) {
      return Image.network(
        widget.scene.imageUrl,
        fit: BoxFit.cover,
      );
    }

    return Container(
      color: const Color(0xFF020617),
    );
  }

  @override
@override
Widget build(BuildContext context) {
  final scene = widget.scene;

  return AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      return Stack(
        fit: StackFit.expand,
        children: [

          /// BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF020617),
                ],
              ),
            ),
          ),

          /// BACKGROUND IMAGE
          FractionalTranslation(
            translation: _pan.value,
            child: Transform.scale(
              scale: _zoom.value,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha:0.50),
                  BlendMode.darken,
                ),
                child: _buildBackground(),
              ),
            ),
          ),

          /// DARK OVERLAY
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha:0.15),
                  Colors.black.withValues(alpha:0.82),
                ],
              ),
            ),
          ),

          /// FLOATING LIGHT
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB).withValues(alpha:0.15),
              ),
            ),
          ),

          /// MAIN CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 18,
              ),
              child: FadeTransition(
                opacity: _textFade,
                child: SlideTransition(
                  position: _textSlide,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 900,
                        maxHeight: 720,
                      ),
                      child: _buildModernCompactCard(scene),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildModernCompactCard(SceneConfig scene) {
  final hasBody = scene.body.isNotEmpty;
  final hasSteps = scene.keyPoints.isNotEmpty;
  final hasCode = scene.hook.isNotEmpty;
  final hasTip = scene.closureLine.isNotEmpty;

  return ClipRRect(
    borderRadius: BorderRadius.circular(34),
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 22,
        sigmaY: 22,
      ),
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha:0.14),
              Colors.white.withValues(alpha:0.05),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha:0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.45),
              blurRadius: 35,
              offset: const Offset(0, 24),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TOP BAR
            Row(
              children: [

                /// LOGO
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2563EB),
                        Color(0xFF7C3AED),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.flutter_dash_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                /// TITLE AREA
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.blue.withValues(alpha:0.15),
                        ),
                        child: const Text(
                          "FLUTTER TUTORIAL",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Color(0xFF93C5FD),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        scene.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                          letterSpacing: -1.2,
                          color: Colors.white,
                        ),
                      ),

                      if (scene.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 8),

                        Text(
                          scene.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.white.withValues(alpha:0.72),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// BODY
            if (hasBody)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.black.withValues(alpha:0.18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha:0.05),
                  ),
                ),
                child: Text(
                  scene.body,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.8,
                    color: Colors.white.withValues(alpha:0.84),
                  ),
                ),
              ),

            if (hasBody) const SizedBox(height: 22),

            /// CONTENT AREA
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// LEFT SIDE - STEPS
                  if (hasSteps)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.white.withValues(alpha:0.05),
                          border: Border.all(
                            color: Colors.white.withValues(alpha:0.06),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF60A5FA),
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Implementation",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Expanded(
                              child: ListView.builder(
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                itemCount: scene.keyPoints.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin:
                                        const EdgeInsets.only(bottom: 14),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [

                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            gradient:
                                                const LinearGradient(
                                              colors: [
                                                Color(0xFF2563EB),
                                                Color(0xFF7C3AED),
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${index + 1}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Text(
                                            scene.keyPoints[index],
                                            style: TextStyle(
                                              fontSize: 14,
                                              height: 1.6,
                                              color: Colors.white
                                                  .withValues(alpha:0.82),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (hasSteps && hasCode)
                    const SizedBox(width: 18),

                  /// RIGHT SIDE - CODE
                  if (hasCode)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Row(
                              children: [

                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),

                                const SizedBox(width: 8),

                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),

                                const SizedBox(width: 8),

                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),

                                const Spacer(),

                                const Icon(
                                  Icons.code_rounded,
                                  color: Color(0xFF60A5FA),
                                  size: 18,
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Expanded(
                              child: SingleChildScrollView(
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                child: SelectableText(
                                  scene.hook,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    height: 1.8,
                                    color: Color(0xFFBFDBFE),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            /// TIP
            if (hasTip) ...[
              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF59E0B).withValues(alpha:0.18),
                      const Color(0xFFEA580C).withValues(alpha:0.10),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha:0.15),
                  ),
                ),
                child: Row(
                  children: [

                    const Icon(
                      Icons.lightbulb_rounded,
                      color: Colors.orange,
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        scene.closureLine,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.white.withValues(alpha:0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
  // Widget build(BuildContext context) {
  //   final scene = widget.scene;

  //   return AnimatedBuilder(
  //     animation: _controller,
  //     builder: (context, child) {
  //       return Stack(
  //         fit: StackFit.expand,
  //         children: [

  //           /// BACKGROUND
  //           Container(
  //             decoration: const BoxDecoration(
  //               gradient: LinearGradient(
  //                 begin: Alignment.topCenter,
  //                 end: Alignment.bottomCenter,
  //                 colors: [
  //                   Color(0xFF0F172A),
  //                   Color(0xFF020617),
  //                 ],
  //               ),
  //             ),
  //           ),

  //           /// IMAGE
  //           FractionalTranslation(
  //             translation: _pan.value,
  //             child: Transform.scale(
  //               scale: _zoom.value,
  //               child: ColorFiltered(
  //                 colorFilter: ColorFilter.mode(
  //                   Colors.black.withValues(alpha:0.45),
  //                   BlendMode.darken,
  //                 ),
  //                 child: _buildBackground(),
  //               ),
  //             ),
  //           ),

  //           /// OVERLAY
  //           Container(
  //             decoration: BoxDecoration(
  //               gradient: LinearGradient(
  //                 begin: Alignment.topCenter,
  //                 end: Alignment.bottomCenter,
  //                 colors: [
  //                   Colors.black.withValues(alpha:0.15),
  //                   Colors.black.withValues(alpha:0.7),
  //                 ],
  //               ),
  //             ),
  //           ),

  //           /// CONTENT
  //           SafeArea(
  //             child: FadeTransition(
  //               opacity: _textFade,
  //               child: SlideTransition(
  //                 position: _textSlide,
  //                 child: Center(
  //                   child: SingleChildScrollView(
  //                     padding: const EdgeInsets.all(24),
  //                     child: ConstrainedBox(
  //                       constraints: const BoxConstraints(
  //                         maxWidth: 850,
  //                       ),
  //                       child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(32),
  //                         child: BackdropFilter(
  //                           filter: ImageFilter.blur(
  //                             sigmaX: 20,
  //                             sigmaY: 20,
  //                           ),
  //                           child: _buildContent(scene),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Widget _buildContent(SceneConfig scene) {
  //   final hasBody = scene.body.isNotEmpty;
  //   final hasSteps = scene.keyPoints.isNotEmpty;
  //   final hasCode = scene.hook.isNotEmpty;
  //   final hasTip = scene.closureLine.isNotEmpty;

  //   return Container(
  //     padding: const EdgeInsets.all(30),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(32),
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [
  //           Colors.white.withValues(alpha:0.12),
  //           Colors.white.withValues(alpha:0.04),
  //         ],
  //       ),
  //       border: Border.all(
  //         color: Colors.white.withValues(alpha:0.08),
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha:0.45),
  //           blurRadius: 30,
  //           offset: const Offset(0, 20),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisSize: MainAxisSize.min,
  //       children: [

  //         /// TOP BADGE
  //         Container(
  //           padding: const EdgeInsets.symmetric(
  //             horizontal: 14,
  //             vertical: 8,
  //           ),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF2563EB).withValues(alpha:0.18),
  //             borderRadius: BorderRadius.circular(100),
  //             border: Border.all(
  //               color: const Color(0xFF60A5FA).withValues(alpha:0.35),
  //             ),
  //           ),
  //           child: const Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Icon(
  //                 Icons.flutter_dash_rounded,
  //                 color: Color(0xFF93C5FD),
  //                 size: 16,
  //               ),
  //               SizedBox(width: 8),
  //               Text(
  //                 "FLUTTER MASTERCLASS",
  //                 style: TextStyle(
  //                   fontSize: 11,
  //                   fontWeight: FontWeight.w700,
  //                   letterSpacing: 1.1,
  //                   color: Color(0xFFBFDBFE),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),

  //         const SizedBox(height: 26),

  //         /// TITLE
  //         Text(
  //           scene.title,
  //           style: const TextStyle(
  //             fontSize: 38,
  //             fontWeight: FontWeight.w800,
  //             color: Colors.white,
  //             height: 1.1,
  //             letterSpacing: -1.2,
  //           ),
  //         ),

  //         if (scene.subtitle.isNotEmpty) ...[
  //           const SizedBox(height: 12),

  //           Text(
  //             scene.subtitle,
  //             style: TextStyle(
  //               fontSize: 17,
  //               height: 1.5,
  //               color: Colors.white.withValues(alpha:0.72),
  //             ),
  //           ),
  //         ],

  //         const SizedBox(height: 26),

  //         /// BODY
  //         if (hasBody)
  //           Container(
  //             padding: const EdgeInsets.all(20),
  //             decoration: BoxDecoration(
  //               color: Colors.black.withValues(alpha:0.18),
  //               borderRadius: BorderRadius.circular(20),
  //               border: Border.all(
  //                 color: Colors.white.withValues(alpha:0.06),
  //               ),
  //             ),
  //             child: Text(
  //               scene.body,
  //               style: TextStyle(
  //                 fontSize: 15,
  //                 height: 1.8,
  //                 color: Colors.white.withValues(alpha:0.85),
  //               ),
  //             ),
  //           ),

  //         if (hasBody) const SizedBox(height: 26),

  //         /// STEPS
  //         if (hasSteps) ...[
  //           const Text(
  //             "Implementation Steps",
  //             style: TextStyle(
  //               fontSize: 20,
  //               fontWeight: FontWeight.w700,
  //               color: Colors.white,
  //             ),
  //           ),

  //           const SizedBox(height: 18),

  //           ...List.generate(scene.keyPoints.length, (index) {
  //             return Container(
  //               margin: const EdgeInsets.only(bottom: 14),
  //               padding: const EdgeInsets.all(18),
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(20),
  //                 color: Colors.white.withValues(alpha:0.05),
  //                 border: Border.all(
  //                   color: Colors.white.withValues(alpha:0.08),
  //                 ),
  //               ),
  //               child: Row(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [

  //                   /// STEP NUMBER
  //                   Container(
  //                     width: 36,
  //                     height: 36,
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(12),
  //                       gradient: const LinearGradient(
  //                         colors: [
  //                           Color(0xFF2563EB),
  //                           Color(0xFF7C3AED),
  //                         ],
  //                       ),
  //                     ),
  //                     child: Center(
  //                       child: Text(
  //                         "${index + 1}",
  //                         style: const TextStyle(
  //                           color: Colors.white,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ),
  //                   ),

  //                   const SizedBox(width: 16),

  //                   Expanded(
  //                     child: Text(
  //                       scene.keyPoints[index],
  //                       style: TextStyle(
  //                         fontSize: 15,
  //                         height: 1.7,
  //                         color: Colors.white.withValues(alpha:0.82),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           }),
  //         ],

  //         /// CODE
  //         if (hasCode) ...[
  //           const SizedBox(height: 24),

  //           const Row(
  //             children: [
  //               Icon(
  //                 Icons.code_rounded,
  //                 color: Color(0xFF60A5FA),
  //                 size: 22,
  //               ),
  //               SizedBox(width: 10),
  //               Text(
  //                 "Source Code",
  //                 style: TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.w700,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             ],
  //           ),

  //           const SizedBox(height: 16),

  //           Container(
  //             width: double.infinity,
  //             padding: const EdgeInsets.all(20),
  //             decoration: BoxDecoration(
  //               color: const Color(0xFF0F172A),
  //               borderRadius: BorderRadius.circular(22),
  //               border: Border.all(
  //                 color: const Color(0xFF1E293B),
  //               ),
  //             ),
  //             child: SelectableText(
  //               scene.hook,
  //               style: const TextStyle(
  //                 fontFamily: 'monospace',
  //                 fontSize: 13,
  //                 height: 1.8,
  //                 color: Color(0xFFBFDBFE),
  //               ),
  //             ),
  //           ),
  //         ],

  //         /// TIP
  //         if (hasTip) ...[
  //           const SizedBox(height: 28),

  //           Container(
  //             padding: const EdgeInsets.all(20),
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(20),
  //               gradient: LinearGradient(
  //                 colors: [
  //                   const Color(0xFFF59E0B).withValues(alpha:0.18),
  //                   const Color(0xFFEA580C).withValues(alpha:0.10),
  //                 ],
  //               ),
  //               border: Border.all(
  //                 color: Colors.orange.withValues(alpha:0.18),
  //               ),
  //             ),
  //             child: Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [

  //                 const Icon(
  //                   Icons.lightbulb_rounded,
  //                   color: Colors.orange,
  //                 ),

  //                 const SizedBox(width: 14),

  //                 Expanded(
  //                   child: Text(
  //                     scene.closureLine,
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       height: 1.7,
  //                       color: Colors.white.withValues(alpha:0.85),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

}