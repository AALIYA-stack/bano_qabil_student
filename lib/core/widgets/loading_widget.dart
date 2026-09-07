import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  final bool fullScreen;

  final double indicatorSize;

  const LoadingWidget({
    super.key,
    this.message,
    this.fullScreen = false,
    this.indicatorSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: const CircularProgressIndicator(
            strokeWidth: 2.8,
            color: AppColors.primary,
          ),
        ),

        if (message != null) ...[
          const SizedBox(height: 14),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Center(
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: content,
      ),
    );
  }
}