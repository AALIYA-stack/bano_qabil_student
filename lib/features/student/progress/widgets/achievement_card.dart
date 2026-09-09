import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;

  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.accentLight
            : AppColors.background,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? AppColors.accent
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(
              milliseconds: 300,
            ),
            child: Container(
              key: ValueKey(unlocked),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: unlocked
                    ? AppColors.accent
                    : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Icon(
                unlocked
                    ? icon
                    : Icons.lock_outline_rounded,
                color: unlocked
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    color:
                    AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color:
                    AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          if (unlocked)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
            ),
        ],
      ),
    );
  }
}