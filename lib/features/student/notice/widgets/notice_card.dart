import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../models/notice_model.dart';

class NoticeCard extends StatelessWidget {
  final NoticeModel notice;
  final VoidCallback onTap;

  const NoticeCard({
    super.key,
    required this.notice,
    required this.onTap,
  });

  Color _priorityColor() {
    switch (notice.priority.toLowerCase()) {
      case 'high':
        return AppColors.error;

      case 'low':
        return AppColors.textSecondary;

      default:
        return AppColors.primary;
    }
  }

  IconData _icon() {
    switch (notice.type.toLowerCase()) {
      case 'class':
        return Icons.school_outlined;

      case 'assignment':
        return Icons.assignment_outlined;

      case 'holiday':
        return Icons.event_outlined;

      case 'important':
        return Icons.priority_high_rounded;

      default:
        return Icons.campaign_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor();

    return FadeSlideAnimation(
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: Container(
          margin:
          const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color: notice.isImportant
                  ? color.withOpacity(0.35)
                  : AppColors.border,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color:
                  color.withOpacity(0.10),
                  borderRadius:
                  BorderRadius.circular(13),
                ),
                child: Icon(
                  _icon(),
                  color: color,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notice.title,
                            maxLines: 2,
                            overflow:
                            TextOverflow.ellipsis,
                            style:
                            const TextStyle(
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w700,
                              color:
                              AppColors.textPrimary,
                            ),
                          ),
                        ),

                        if (notice.isImportant)
                          const Icon(
                            Icons
                                .priority_high_rounded,
                            size: 19,
                            color:
                            AppColors.error,
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      notice.description,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color:
                        AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _TypeBadge(
                          type: notice.type,
                        ),

                        const Spacer(),

                        if (notice.createdAt !=
                            null)
                          Text(
                            _formatDate(
                              notice.createdAt!,
                            ),
                            style:
                            const TextStyle(
                              fontSize: 11,
                              color:
                              AppColors.textLight,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color:
                AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;

  const _TypeBadge({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        _label(type),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  String _label(String value) {
    switch (value.toLowerCase()) {
      case 'class':
        return 'Class';

      case 'assignment':
        return 'Assignment';

      case 'holiday':
        return 'Holiday';

      case 'important':
        return 'Important';

      default:
        return 'General';
    }
  }
}