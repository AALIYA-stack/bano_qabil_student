import 'package:flutter/material.dart';

class AnimatedProgress extends StatelessWidget {
  final double value;

  final Duration duration;

  final double height;

  final double borderRadius;

  final Color? backgroundColor;

  final Color? valueColor;

  const AnimatedProgress({
    super.key,
    required this.value,
    this.duration = const Duration(
      milliseconds: 900,
    ),
    this.height = 8,
    this.borderRadius = 20,
    this.backgroundColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0.0, 100.0) / 100;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: safeValue,
      ),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (
          context,
          animatedValue,
          child,
          ) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(
            borderRadius,
          ),
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: height,
            backgroundColor:
            backgroundColor ??
                Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              valueColor ??
                  Theme.of(context)
                      .colorScheme
                      .primary,
            ),
          ),
        );
      },
    );
  }
}