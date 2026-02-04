import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedLogo extends StatefulWidget {
  final bool isPlaying;
  final Color primaryColor;
  final Color accentColor;

  const AnimatedLogo({
    super.key,
    this.isPlaying = false,
    this.primaryColor = Colors.white,
    this.accentColor = const Color(0xFFFF003C),
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.animateTo(0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isPlaying ? _pulseAnimation.value : 1.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Omni',
                style: GoogleFonts.righteous(
                  fontSize: 24,
                  color: widget.primaryColor,
                  shadows: widget.isPlaying
                      ? [
                          Shadow(
                            color: widget.accentColor.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
              ),
              Text(
                'Player',
                style: GoogleFonts.righteous(
                  fontSize: 24,
                  color: widget.accentColor,
                  shadows: widget.isPlaying
                      ? [
                          Shadow(
                            color: widget.accentColor.withValues(alpha: 0.8),
                            blurRadius: 15,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
