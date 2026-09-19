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

  // ============================================================
  // LOAD NOTICE
  // ============================================================

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notice Details',
        ),
      ),
      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding:
          const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign:
            TextAlign.center,
          ),
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
      padding:
      const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          FadeSlideAnimation(
            child: Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(20),
              decoration:
              BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(
                  20,
                ),
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
                  // ==================================================
                  // TITLE
                  // ==================================================

                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
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
                        const Padding(
                          padding:
                          EdgeInsets.only(
                            left: 8,
                          ),
                          child: Icon(
                            Icons
                                .priority_high_rounded,
                            color:
                            AppColors
                                .error,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // ==================================================
                  // TYPE + PRIORITY
                  // ==================================================

                  Row(
                    children: [
                      _Badge(
                        text: _capitalize(
                          notice.type,
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      _Badge(
                        text: _capitalize(
                          notice.priority,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  const Divider(),

                  const SizedBox(
                    height: 18,
                  ),

                  // ==================================================
                  // DESCRIPTION
                  // ==================================================

                  Text(
                    notice.description,
                    style:
                    const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color:
                      AppColors
                          .textPrimary,
                    ),
                  ),

                  // ==================================================
                  // DATE
                  // ==================================================

                  if (notice.createdAt !=
                      null) ...[
                    const SizedBox(
                      height: 24,
                    ),
                    Text(
                      'Published: ${_formatDate(notice.createdAt!)}',
                      style:
                      const TextStyle(
                        fontSize: 12,
                        color: AppColors
                            .textSecondary,
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

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(
      DateTime date,
      ) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ============================================================
  // TEXT FORMAT
  // ============================================================

  String _capitalize(
      String value,
      ) {
    final String text =
    value.trim();

    if (text.isEmpty) {
      return '';
    }

    return text[0].toUpperCase() +
        text.substring(1);
  }
}

// ================================================================
// BADGE
// ================================================================

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
      decoration:
      BoxDecoration(
        color:
        AppColors.accentLight,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style:
        const TextStyle(
          fontSize: 11,
          fontWeight:
          FontWeight.w600,
          color:
          AppColors.primary,
        ),
      ),
    );
  }
}