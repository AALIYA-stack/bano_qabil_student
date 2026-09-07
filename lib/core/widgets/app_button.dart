import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  final IconData? icon;

  final bool isLoading;

  final bool outlined;

  final bool fullWidth;

  final bool enabled;

  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.outlined = false,
    this.fullWidth = true,
    this.enabled = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled =
        !enabled || isLoading || onPressed == null;

    final Widget content = isLoading
        ? SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        color: outlined
            ? AppColors.primary
            : Colors.white,
      ),
    )
        : Row(
      mainAxisSize: fullWidth
          ? MainAxisSize.max
          : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 19,
          ),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    final double buttonHeight =
        height ?? AppDimensions.buttonHeight;

    if (outlined) {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledForegroundColor:
            AppColors.textLight,
            side: const BorderSide(
              color: AppColors.primary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMedium,
              ),
            ),
          ),
          child: content,
        ),
      );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          AppColors.textLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMedium,
            ),
          ),
        ),
        child: content,
      ),
    );
  }
}