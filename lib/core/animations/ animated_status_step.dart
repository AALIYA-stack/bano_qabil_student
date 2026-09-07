import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AnimatedStatusStep extends StatelessWidget {
  final String title;

  final String? subtitle;

  final IconData icon;

  final bool completed;

  final bool active;

  final int index;

  final VoidCallback? onTap;

  const AnimatedStatusStep({
    super.key,
    required this.title,
    required this.icon,
    required this.completed,
    required this.active,
    this.subtitle,
    this.index = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = completed || active
        ? AppColors.primary
        : AppColors.textLight;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: 1,
      ),
      duration: Duration(
        milliseconds: 400 + (index * 100),
      ),
      curve: Curves.easeOutCubic,
      builder: (
          context,
          value,
          child,
          ) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              12 * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 300,
                ),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: completed
                      ? AppColors.success
                      : active
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  completed
                      ? Icons.check_rounded
                      : icon,
                  size: 21,
                  color: completed || active
                      ? Colors.white
                      : AppColors.textLight,
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                        completed || active
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: color,
                      ),
                    ),

                    if (subtitle != null &&
                        subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color:
                          AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}