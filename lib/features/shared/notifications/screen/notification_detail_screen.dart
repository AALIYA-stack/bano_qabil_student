import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../models/notification_model.dart';
import '../../../../services/notification_service.dart';

class NotificationDetailScreen
    extends StatefulWidget {
  final String notificationId;

  const NotificationDetailScreen({
    super.key,
    required this.notificationId,
  });

  @override
  State<NotificationDetailScreen>
  createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends State<NotificationDetailScreen> {
  AppNotification? _notification;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotification();
  }

  Future<void> _loadNotification() async {
    try {
      final notification =
      await NotificationService.instance
          .getNotificationById(
        widget.notificationId,
      );

      if (notification != null &&
          !notification.isRead) {
        await NotificationService.instance
            .markAsRead(
          notification.id,
        );
      }

      if (!mounted) return;

      setState(() {
        _notification = notification;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        );
        _isLoading = false;
      });
    }
  }

  IconData _icon(String type) {
    switch (type.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notification',
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final notification =
        _notification;

    if (notification == null) {
      return const Center(
        child: Text(
          'Notification not found.',
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: FadeSlideAnimation(
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors
                        .accentLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _icon(
                      notification.type,
                    ),
                    size: 34,
                    color:
                    AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Text(
                notification.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors
                        .accentLight,
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    notification.type,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Divider(),

              const SizedBox(height: 22),

              Text(
                notification.message,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.7,
                  color:
                  AppColors.textPrimary,
                ),
              ),

              if (notification.createdAt !=
                  null) ...[
                const SizedBox(height: 28),
                Text(
                  'Received on ${_formatDate(notification.createdAt!)}',
                  style:
                  const TextStyle(
                    fontSize: 12,
                    color:
                    AppColors.textSecondary,
                  ),
                ),
              ],
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