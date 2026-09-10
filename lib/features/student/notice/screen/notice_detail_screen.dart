import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../models/notice_model.dart';
import '../../../../services/notice_service.dart';

class NoticeDetailScreen
    extends StatefulWidget {
  final String noticeId;

  const NoticeDetailScreen({
    super.key,
    required this.noticeId,
  });

  @override
  State<NoticeDetailScreen> createState() =>
      _NoticeDetailScreenState();
}

class _NoticeDetailScreenState
    extends State<NoticeDetailScreen> {
  NoticeModel? _notice;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotice();
  }

  Future<void> _loadNotice() async {
    try {
      final notice =
      await NoticeService.instance
          .getNoticeById(
        widget.noticeId,
      );

      if (!mounted) return;

      setState(() {
        _notice = notice;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notice Details',
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
        child: Text(
          _error!,
          textAlign: TextAlign.center,
        ),
      );
    }

    final notice = _notice;

    if (notice == null) {
      return const Center(
        child: Text(
          'Notice not found.',
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          FadeSlideAnimation(
            child: Container(
              padding:
              const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(20),
                border: Border.all(
                  color: notice.isImportant
                      ? AppColors.error
                      : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notice.title,
                          style:
                          const TextStyle(
                            fontSize: 23,
                            fontWeight:
                            FontWeight.w700,
                            color: AppColors
                                .textPrimary,
                          ),
                        ),
                      ),

                      if (notice.isImportant)
                        const Icon(
                          Icons
                              .priority_high_rounded,
                          color:
                          AppColors.error,
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      _Badge(
                        text: notice.type,
                      ),
                      const SizedBox(width: 8),
                      _Badge(
                        text: notice.priority,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Divider(),

                  const SizedBox(height: 18),

                  Text(
                    notice.description,
                    style:
                    const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color:
                      AppColors.textPrimary,
                    ),
                  ),

                  if (notice.createdAt !=
                      null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Published: ${_formatDate(notice.createdAt!)}',
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
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}