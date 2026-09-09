import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../models/notice_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/notice_service.dart';
import 'notice_detail_screen.dart';
import '../widgets/notice_card.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({
    super.key,
  });

  @override
  State<NoticesScreen> createState() =>
      _NoticesScreenState();
}

class _NoticesScreenState
    extends State<NoticesScreen> {
  final AuthService _authService =
      AuthService.instance;

  List<NoticeModel> _allNotices = [];
  List<NoticeModel> _filteredNotices = [];

  bool _isLoading = true;
  String? _error;

  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Important',
    'Class',
    'Assignment',
    'Holiday',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile =
      await _authService
          .getCurrentUserProfile();

      if (profile == null) {
        throw Exception(
          'Student profile not found.',
        );
      }

      final notices =
      await NoticeService.instance
          .getMyNotices(
        courseId: profile.courseId,
        batchId: profile.batchId,
        campusId: profile.campus,
      );

      if (!mounted) return;

      setState(() {
        _allNotices = notices;
        _applyFilter();
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

  void _applyFilter() {
    if (_selectedFilter == 'All') {
      _filteredNotices =
          List.from(_allNotices);
      return;
    }

    if (_selectedFilter == 'Important') {
      _filteredNotices =
          _allNotices.where(
                (notice) => notice.isImportant,
          ).toList();

      return;
    }

    _filteredNotices =
        _allNotices.where(
              (notice) =>
          notice.type.toLowerCase() ==
              _selectedFilter.toLowerCase(),
        ).toList();
  }

  void _changeFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notices',
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
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.campaign_outlined,
                size: 50,
                color:
                AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadNotices,
                child: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotices,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const FadeSlideAnimation(
            child: Text(
              'Campus Announcements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color:
                AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 5),

          const FadeSlideAnimation(
            delay: Duration(milliseconds: 60),
            child: Text(
              'Stay updated with the latest information.',
              style: TextStyle(
                fontSize: 13,
                color:
                AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 18),

          FadeSlideAnimation(
            delay:
            const Duration(milliseconds: 100),
            child: SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection:
                Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder:
                    (_, _) =>
                const SizedBox(
                  width: 8,
                ),
                itemBuilder:
                    (context, index) {
                  final filter =
                  _filters[index];

                  final selected =
                      filter ==
                          _selectedFilter;

                  return ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    onSelected: (_) =>
                        _changeFilter(
                          filter,
                        ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 18),

          if (_filteredNotices.isEmpty)
            const Padding(
              padding:
              EdgeInsets.only(top: 80),
              child: Column(
                children: [
                  Icon(
                    Icons
                        .notifications_none_rounded,
                    size: 60,
                    color:
                    AppColors.textLight,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'No notices available',
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
                      color:
                      AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._filteredNotices
                .asMap()
                .entries
                .map(
                  (entry) {
                final index =
                    entry.key;
                final notice =
                    entry.value;

                return FadeSlideAnimation(
                  delay: Duration(
                    milliseconds:
                    150 + (index * 70),
                  ),
                  child: NoticeCard(
                    notice: notice,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              NoticeDetailScreen(
                                noticeId:
                                notice.id,
                              ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}