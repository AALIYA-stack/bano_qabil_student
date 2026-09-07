import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppNetworkImage extends StatelessWidget {
  final String? url;

  final double? width;

  final double? height;

  final BoxFit fit;

  final BorderRadius? borderRadius;

  final Widget? placeholder;

  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasUrl =
        url != null && url!.trim().isNotEmpty;

    Widget image;

    if (!hasUrl) {
      image = _fallback();
    } else {
      image = Image.network(
        url!,
        width: width,
        height: height,
        fit: fit,

        loadingBuilder:
            (context, child, progress) {
          if (progress == null) {
            return child;
          }

          return placeholder ??
              _loading();
        },

        errorBuilder:
            (context, error, stackTrace) {
          return errorWidget ?? _fallback();
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _loading() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.textLight,
      ),
    );
  }
}