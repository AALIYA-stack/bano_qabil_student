import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class PerformanceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double percentage;
  final IconData icon;

  const PerformanceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.percentage,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final value =
    (percentage / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight:
                  FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 15),

          TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0,
              end: value,
            ),
            duration: const Duration(
              milliseconds: 850,
            ),
            curve: Curves.easeOutCubic,
            builder: (
                context,
                animatedValue,
                child,
                ) {
              return ClipRRect(
                borderRadius:
                BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: animatedValue,
                  minHeight: 8,
                  backgroundColor:
                  AppColors.background,
                  valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
                    AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}