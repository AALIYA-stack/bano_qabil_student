import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../models/progress_model.dart';

class ModuleProgressCard extends StatelessWidget {
  final ProgressModel progress;
  final VoidCallback? onTap;

  const ModuleProgressCard({
    super.key,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
    progress.modulePercentage.clamp(0, 100);

    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(20),
      child: Container(
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                    AppColors.accentLight,
                    borderRadius:
                    BorderRadius.circular(
                      13,
                    ),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.accent,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Course Modules',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                          FontWeight.w700,
                          color:
                          AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Track your learning',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                          AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color:
                  AppColors.textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.completedModules} of ${progress.totalModules} completed',
                  style: const TextStyle(
                    fontSize: 13,
                    color:
                    AppColors.textSecondary,
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

            const SizedBox(height: 9),

            TweenAnimationBuilder<double>(
              tween: Tween(
                begin: 0,
                end: percentage / 100,
              ),
              duration: const Duration(
                milliseconds: 800,
              ),
              builder: (
                  context,
                  value,
                  child,
                  ) {
                return ClipRRect(
                  borderRadius:
                  BorderRadius.circular(10),
                  child:
                  LinearProgressIndicator(
                    value: value,
                    minHeight: 9,
                    backgroundColor:
                    AppColors.background,
                    valueColor:
                    const AlwaysStoppedAnimation<
                        Color>(
                      AppColors.accent,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}