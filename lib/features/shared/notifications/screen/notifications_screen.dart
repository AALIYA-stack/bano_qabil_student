import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../models/notification_model.dart';
import '../../../../services/notification_service.dart';
import '../widgets/notification_card.dart';
import 'notification_detail_screen.dart';

class NotificationsScreen
    extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [];

  bool _isLoading = true;
  String? _error;

  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Unread',
    'Read',
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications =
      await NotificationService.instance
          .getMyNotifications();

      if (!mounted) return;

      setState(() {
        _notifications = notifications;
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

  List<AppNotification> get _filteredNotifications {
    switch (_selectedFilter) {
      case 'Unread':
        return _notifications
            .where(
              (item) => !item.isRead,
        )
            .toList();

      case 'Read':
        return _notifications
            .where(
              (item) => item.isRead,
        )
            .toList();

      default:
        return _notifications;
    }
  }

  int get _unreadCount {
    return _notifications
        .where(
          (item) => !item.isRead,
    )
        .length;
  }

  Future<void> _markAllAsRead() async {
    if (_unreadCount == 0) {
      return;
    }

    try {
      await NotificationService.instance
          .markAllAsRead();

      await _loadNotifications();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications',
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
              ),
            ),
        ],
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
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              const Icon(
                Icons
                    .notifications_off_outlined,
                size: 52,
                color:
                AppColors.textSecondary,
              ),

              const SizedBox(height: 15),

              Text(
                _error!,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              ElevatedButton(
                onPressed:
                _loadNotifications,
                child: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filtered =
        _filteredNotifications;

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          FadeSlideAnimation(
            child: _buildSummary(),
          ),

          const SizedBox(height: 18),

          FadeSlideAnimation(
            delay:
            const Duration(milliseconds: 80),
            child: _buildFilters(),
          ),

          const SizedBox(height: 18),

          if (filtered.isEmpty)
            _buildEmptyState()
          else
            ...filtered
                .asMap()
                .entries
                .map(
                  (entry) {
                final index =
                    entry.key;
                final notification =
                    entry.value;

                return FadeSlideAnimation(
                  delay: Duration(
                    milliseconds:
                    130 + index * 65,
                  ),
                  child: NotificationCard(
                    notification:
                    notification,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              NotificationDetailScreen(
                                notificationId:
                                notification.id,
                              ),
                        ),
                      );

                      _loadNotifications();
                    },
                  ),
                );
              },
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Notifications',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _unreadCount == 0
                      ? 'You are all caught up!'
                      : '$_unreadCount unread notification${_unreadCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white
                        .withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection:
        Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder:
            (_, __) =>
        const SizedBox(width: 8),
        itemBuilder:
            (context, index) {
          final filter =
          _filters[index];

          return ChoiceChip(
            label: Text(filter),
            selected:
            _selectedFilter == filter,
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(
            Icons
                .notifications_none_rounded,
            size: 64,
            color:
            AppColors.textLight,
          ),

          SizedBox(height: 15),

          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
              FontWeight.w600,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'You are all caught up!',
            style: TextStyle(
              fontSize: 13,
              color:
              AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}