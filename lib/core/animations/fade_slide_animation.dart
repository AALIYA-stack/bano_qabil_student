import 'package:flutter/material.dart';

import 'animation_constants.dart';

class FadeSlideAnimation extends StatefulWidget {
  final Widget child;

  final Duration duration;

  final Duration delay;

  final Offset beginOffset;

  final Curve curve;

  final bool autoPlay;

  const FadeSlideAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(
      milliseconds: AnimationConstants.normal,
    ),
    this.delay = Duration.zero,
    this.beginOffset = const Offset(
      0,
      AnimationConstants.slideDistance,
    ),
    this.curve = Curves.easeOutCubic,
    this.autoPlay = true,
  });

  @override
  State<FadeSlideAnimation> createState() =>
      _FadeSlideAnimationState();
}

class _FadeSlideAnimationState
    extends State<FadeSlideAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late Animation<double> _fadeAnimation;

  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    if (widget.autoPlay) {
      _startAnimation();
    }
  }

  Future<void> _startAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }

    if (!mounted) return;

    _controller.forward();
  }

  void play() {
    _controller.forward(from: 0);
  }

  void reverse() {
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}