import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class CareerChecklistTile
    extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool completed;
  final VoidCallback onChanged;

  const CareerChecklistTile({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.completed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 300,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed
            ? AppColors.accentLight
            : Colors.white,
        borderRadius:
        BorderRadius.circular(17),
        border: Border.all(
          color: completed
              ? AppColors.accent
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(
              milliseconds: 300,
            ),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: completed
                  ? AppColors.success
                  : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed
                  ? Icons.check_rounded
                  : icon,
              color: completed
                  ? Colors.white
                  : AppColors.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
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

          Switch(
            value: completed,
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}