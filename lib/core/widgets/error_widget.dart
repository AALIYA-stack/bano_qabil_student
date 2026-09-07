import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;

  final VoidCallback? onRetry;

  final String retryLabel;

  const AppErrorWidget({
    super.key,
    this.message =
    'Something went wrong. Please try again.',
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.errorBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: AppColors.error,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Oops!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            if (onRetry != null) ...[
              const SizedBox(height: 18),

              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}