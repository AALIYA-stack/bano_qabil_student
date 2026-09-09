import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;
  final int index;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideAnimation(
      delay: Duration(
        milliseconds: index * 70,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLarge,
          ),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusLarge,
              ),
              border: Border.all(
                color: AppColors.border,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.code_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    _LevelBadge(
                      level: course.level,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  course.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  course.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      size: 17,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      course.duration,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Icon(
                      Icons.event_seat_outlined,
                      size: 17,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${course.seatsLeft} seats left',
                      style: TextStyle(
                        fontSize: 12,
                        color: course.seatsLeft > 0
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                      AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View Course',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String level;

  const _LevelBadge({
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        level,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}