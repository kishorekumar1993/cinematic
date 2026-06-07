import 'package:cinematic/model/screen_config.dart';
import 'package:flutter/material.dart';

/// ----------------------
/// YOUTUBE VIDEO LAUNCH CINEMATIC TEMPLATE
/// ----------------------

class YoutubeMovieTempTwo extends StatefulWidget {
  final SceneConfig scene;
  final bool isPlaying;

  const YoutubeMovieTempTwo({
    super.key,
    required this.scene,
    required this.isPlaying,
  });

  @override
  State<YoutubeMovieTempTwo> createState() =>
      _YoutubeMovieTempTwoState();
}

class _YoutubeMovieTempTwoState
    extends State<YoutubeMovieTempTwo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideFromLeft;
  late Animation<double> _slideFromRight;
  late Animation<double> _scaleButton;
  late Animation<double> _pulse;
  late Animation<double> _rotatePlay;
  late Animation<double> _particleFloat;

  @override
  void initState() {
    super.initState();

    final duration = Duration(
      seconds: widget.scene.durationSeconds.clamp(5, 120),
    );

    _controller = AnimationController(vsync: this, duration: duration);

    // Fade in everything
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Slide from left (for title)
    _slideFromLeft = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // Slide from right (for subtitle)
    _slideFromRight = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // Scale play button
    _scaleButton = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Continuous pulse for subscribe button
    _pulse = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Rotate play icon
    _rotatePlay = Tween<double>(begin: 0.0, end: 6.28).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    // Floating particles
    _particleFloat = Tween<double>(begin: 0.0, end: -50.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant YoutubeMovieTempTwo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        if (!_controller.isAnimating) {
          _controller.repeat();
        }
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

  Widget _buildBackground(SceneConfig scene) {
    if (scene.localImageBytes != null) {
      return Image.memory(
        scene.localImageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a1a1a),
                Color(0xFF0a0a0a),
              ],
            ),
          ),
        ),
      );
    }

    if (scene.imageUrl.isNotEmpty) {
      return Image.network(
        scene.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a1a1a),
                Color(0xFF0a0a0a),
              ],
            ),
          ),
        ),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(color: Colors.red),
          );
        },
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a1a1a),
            Color(0xFF0a0a0a),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // --- Background ---
            _buildBackground(scene),

            // --- Dark overlay with red tint ---
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha:0.8),
                    const Color(0xFF330000).withValues(alpha:0.6),
                    Colors.black.withValues(alpha:0.9),
                  ],
                ),
              ),
            ),

            // --- Floating particles effect ---
            ...List.generate(8, (index) {
              final offset = (index * 50.0) % 400;
              return Positioned(
                left: 50.0 + (index * 120.0) % MediaQuery.of(context).size.width,
                top: 100 + offset + _particleFloat.value,
                child: Opacity(
                  opacity: 0.15 * _fadeIn.value,
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 40 + (index * 10.0) % 30,
                    color: Colors.red.shade400,
                  ),
                ),
              );
            }),

            // --- YouTube logo style header ---
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _fadeIn.value,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha:0.6),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          scene.subtitle.isNotEmpty
                              ? scene.subtitle.toUpperCase()
                              : 'NEW VIDEO',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- Main content ---
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated play button in center
                      Transform.scale(
                        scale: _scaleButton.value,
                        child: Transform.rotate(
                          angle: _rotatePlay.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFF0000),
                                  Color(0xFFCC0000),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha:0.6),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha:0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Video title with slide animation
                      Opacity(
                        opacity: _fadeIn.value,
                        child: Transform.translate(
                          offset: Offset(_slideFromLeft.value, 0),
                          child: Text(
                            scene.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                              letterSpacing: 0.5,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha:0.8),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                                Shadow(
                                  color: Colors.red.withValues(alpha:0.4),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Hook/tagline
                      if (scene.hook.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Opacity(
                          opacity: _fadeIn.value,
                          child: Transform.translate(
                            offset: Offset(_slideFromRight.value, 0),
                            child: Text(
                              scene.hook,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: Colors.red.shade300,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha:0.8),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Body description
                      if (scene.body.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Opacity(
                          opacity: _fadeIn.value,
                          child: Text(
                            scene.body,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.white.withValues(alpha:0.85),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha:0.8),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // Subscribe button with pulse
                      Opacity(
                        opacity: _fadeIn.value,
                        child: Transform.scale(
                          scale: _pulse.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF0000),
                                  Color(0xFFCC0000),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha:0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha:0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.notifications_active,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'SUBSCRIBE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Key points as video tags
                      if (scene.keyPoints.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Opacity(
                          opacity: _fadeIn.value,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: scene.keyPoints
                                .map(
                                  (kp) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha:0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.red.withValues(alpha:0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '#',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.red,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          kp.replaceAll('#', ''),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // --- Bottom stats bar ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _fadeIn.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha:0.9),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Premiere date/time
                      if (scene.closureLine.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              scene.closureLine.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                      // Video stats icons
                      Row(
                        children: [
                          _buildStatIcon(Icons.thumb_up, '0'),
                          const SizedBox(width: 20),
                          _buildStatIcon(Icons.visibility, '0'),
                          const SizedBox(width: 20),
                          _buildStatIcon(Icons.share, '0'),
                        ],
                      ),

                      // Status indicator
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.isPlaying
                                  ? Colors.red
                                  : Colors.white54,
                              boxShadow: widget.isPlaying
                                  ? [
                                      BoxShadow(
                                        color: Colors.red.withValues(alpha:0.6),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.isPlaying ? 'LIVE' : 'PAUSED',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- YouTube branding corners ---
            Positioned(
              top: 100,
              left: 20,
              child: Opacity(
                opacity: _fadeIn.value * 0.3,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.red, width: 3),
                      top: BorderSide(color: Colors.red, width: 3),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 100,
              right: 20,
              child: Opacity(
                opacity: _fadeIn.value * 0.3,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.red, width: 3),
                      top: BorderSide(color: Colors.red, width: 3),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: 20,
              child: Opacity(
                opacity: _fadeIn.value * 0.3,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.red, width: 3),
                      bottom: BorderSide(color: Colors.red, width: 3),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: 20,
              child: Opacity(
                opacity: _fadeIn.value * 0.3,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.red, width: 3),
                      bottom: BorderSide(color: Colors.red, width: 3),
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

  Widget _buildStatIcon(IconData icon, String count) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}