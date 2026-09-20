import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _icon() {
    switch (notification.type.toLowerCase()) {
      case 'application':
        return Icons.assignment_turned_in_outlined;

      case 'assignment':
        return Icons.assignment_outlined;

      case 'class':
        return Icons.school_outlined;

      case 'marks':
        return Icons.grade_outlined;

      default:
        return Icons.notifications_outlined;
    }
  }

  Color _iconColor() {
    switch (notification.type.toLowerCase()) {
      case 'application':
        return AppColors.primary;

      case 'assignment':
        return AppColors.warning;

      case 'class':
        return AppColors.info;

      case 'marks':
        return AppColors.success;

      default:
        return AppColors.accent;
    }
  }

  String _typeLabel() {
    switch (notification.type.toLowerCase()) {
      case 'application':
        return 'Application';

      case 'assignment':
        return 'Assignment';

      case 'class':
        return 'Class';

      case 'marks':
        return 'Marks';

      default:
        return 'General';
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _iconColor();

    return FadeSlideAnimation(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.only(
            bottom: 10,
          ),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.white
                : AppColors.accentLight,
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.border
                  : AppColors.accent.withValues(
                alpha: 0.35,
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, 3),
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
                  iconColor.withValues(alpha: 0.12),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Icon(
                  _icon(),
                  color: iconColor,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 2,
                            overflow:
                            TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                              notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                              color:
                              AppColors.textPrimary,
                            ),
                          ),
                        ),

                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin:
                            const EdgeInsets.only(
                              top: 5,
                              left: 6,
                            ),
                            decoration:
                            const BoxDecoration(
                              color:
                              AppColors.accent,
                              shape:
                              BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color:
                        AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: iconColor
                                .withValues(
                              alpha: 0.10,
                            ),
                            borderRadius:
                            BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            _typeLabel(),
                            style:
                            TextStyle(
                              fontSize: 10,
                              fontWeight:
                              FontWeight.w600,
                              color: iconColor,
                            ),
                          ),
                        ),

                        const Spacer(),

                        if (notification.createdAt !=
                            null)
                          Text(
                            _formatDate(
                              notification.createdAt!,
                            ),
                            style:
                            const TextStyle(
                              fontSize: 10,
                              color:
                              AppColors.textLight,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
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