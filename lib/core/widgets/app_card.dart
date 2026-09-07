import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;

  final EdgeInsetsGeometry padding;

  final EdgeInsetsGeometry? margin;

  final VoidCallback? onTap;

  final Color? color;

  final Color? borderColor;

  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(
      AppDimensions.paddingMedium,
    ),
    this.margin,
    this.onTap,
    this.color,
    this.borderColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius =
    BorderRadius.circular(
      AppDimensions.radiusLarge,
    );

    final Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: radius,
        border: Border.all(
          color: borderColor ?? AppColors.border,
        ),
        boxShadow: elevation == 0
            ? null
            : const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: card,
      ),
    );
  }
}