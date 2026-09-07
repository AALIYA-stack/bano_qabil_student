import 'package:flutter/material.dart';

import 'animation_constants.dart';

enum SlideDirection {
  left,
  right,
  top,
  bottom,
}

class SlideAnimation extends StatefulWidget {
  final Widget child;

  final SlideDirection direction;

  final Duration duration;

  final Duration delay;

  final double distance;

  final Curve curve;

  const SlideAnimation({
    super.key,
    required this.child,
    this.direction = SlideDirection.bottom,
    this.duration = const Duration(
      milliseconds: AnimationConstants.normal,
    ),
    this.delay = Duration.zero,
    this.distance = AnimationConstants.slideDistance,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<SlideAnimation> createState() =>
      _SlideAnimationState();
}

class _SlideAnimationState
    extends State<SlideAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<Offset> _animation;

  Offset get _beginOffset {
    switch (widget.direction) {
      case SlideDirection.left:
        return Offset(-widget.distance, 0);

      case SlideDirection.right:
        return Offset(widget.distance, 0);

      case SlideDirection.top:
        return Offset(0, -widget.distance);

      case SlideDirection.bottom:
        return Offset(0, widget.distance);
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<Offset>(
      begin: _beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _start();
  }

  Future<void> _start() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }

    if (!mounted) return;

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}