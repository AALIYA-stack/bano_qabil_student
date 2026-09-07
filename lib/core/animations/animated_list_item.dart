import 'package:flutter/material.dart';

import 'animation_constants.dart';
import 'fade_slide_animation.dart';

class AnimatedListItem extends StatelessWidget {
  final Widget child;

  final int index;

  final Duration baseDelay;

  final Duration stagger;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.baseDelay = Duration.zero,
    this.stagger = const Duration(
      milliseconds: AnimationConstants.staggerDelay,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final delay = baseDelay +
        Duration(
          milliseconds:
          stagger.inMilliseconds * index,
        );

    return FadeSlideAnimation(
      delay: delay,
      child: child,
    );
  }
}