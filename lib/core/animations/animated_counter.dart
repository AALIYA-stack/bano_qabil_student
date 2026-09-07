import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  final double value;

  final String prefix;

  final String suffix;

  final int decimalPlaces;

  final Duration duration;

  final TextStyle? textStyle;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.decimalPlaces = 0,
    this.duration = const Duration(
      milliseconds: 900,
    ),
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: value,
      ),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (
          context,
          animatedValue,
          child,
          ) {
        return Text(
          '$prefix'
              '${animatedValue.toStringAsFixed(decimalPlaces)}'
              '$suffix',
          style: textStyle,
        );
      },
    );
  }
}