import 'package:flutter/material.dart';

import 'animation_constants.dart';

class ScaleAnimation extends StatefulWidget {
  final Widget child;

  final Duration duration;

  final Duration delay;

  final double beginScale;

  final Curve curve;

  const ScaleAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(
      milliseconds: AnimationConstants.normal,
    ),
    this.delay = Duration.zero,
    this.beginScale = AnimationConstants.scaleStart,
    this.curve = Curves.easeOutBack,
  });

  @override
  State<ScaleAnimation> createState() =>
      _ScaleAnimationState();
}

class _ScaleAnimationState
    extends State<ScaleAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: widget.beginScale,
      end: 1,
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
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}