import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../models/assignment_model.dart';

class AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final String status;
  final VoidCallback onTap;
  final int index;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.status,
    required this.onTap,
    this.index = 0,
  });

  Color get _statusColor {
    switch (status) {
      case 'submitted':
        return AppColors.info;
      case 'late':
        return AppColors.error;
      case 'marked':
        return AppColors.success;
      default:
        return AppColors.warning;
    }
  }

  String get _statusLabel {
    switch (status) {
      case 'submitted':
        return 'Submitted';
      case 'late':
        return 'Late';
      case 'marked':
        return 'Marked';
      default:
        return 'Pending';
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case 'submitted':
        return Icons.check_circle_outline_rounded;
      case 'late':
        return Icons.warning_amber_rounded;
      case 'marked':
        return Icons.verified_outlined;
      default:
        return Icons.pending_actions_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeSlideAnimation(
      delay: Duration(
        milliseconds: 80 + (index * 60),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusLarge,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.09,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading3,
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            assignment.dueDate == null
                                ? 'No due date'
                                : 'Due ${DateFormat('dd MMM yyyy, hh:mm a').format(assignment.dueDate!)}',
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style:
                            AppTextStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _statusIcon,
                            size: 14,
                            color: _statusColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _statusLabel,
                            style: TextStyle(
                              color: _statusColor,
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}