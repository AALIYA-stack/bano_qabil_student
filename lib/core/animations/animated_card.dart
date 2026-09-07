import 'package:flutter/material.dart';

import 'animation_constants.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;

  final VoidCallback? onTap;

  final Duration duration;

  final double pressedScale;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(
      milliseconds: AnimationConstants.fast,
    ),
    this.pressedScale = AnimationConstants.scalePressed,
  });

  @override
  State<AnimatedCard> createState() =>
      _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted) return;

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}