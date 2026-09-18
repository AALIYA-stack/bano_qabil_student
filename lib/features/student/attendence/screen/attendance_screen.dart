import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../models/attendance_model.dart';
import '../../../../services/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
  });

  @override
  State<AttendanceScreen> createState() =>
      _AttendanceScreenState();
}

class _AttendanceScreenState
    extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // SERVICE
  // ============================================================

  final AttendanceService _attendanceService =
      AttendanceService.instance;

  // ============================================================
  // STATE
  // ============================================================

  String? _batchId;

  bool _batchLoading = true;

  Object? _batchError;

  // ADDED: store the stream once instead of creating it inside build()
  Stream<List<AttendanceModel>>? _attendanceStream;

  // ============================================================
  // ANIMATION
  // ============================================================

  late final AnimationController _animationController;

  late final Animation<double> _fadeAnimation;

  late final Animation<Offset> _slideAnimation;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 700,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _loadStudentBatch();
  }

  // ============================================================
  // LOAD CURRENT STUDENT BATCH
  // ============================================================

  Future<void> _loadStudentBatch() async {
    setState(() {
      _batchLoading = true;
      _batchError = null;
    });

    try {
      final String? batchId =
          await _attendanceService.getCurrentBatchId();

      if (!mounted) {
        return;
      }

      setState(() {
        _batchId = batchId;
        _batchLoading = false;

        // ADDED: create the attendance stream exactly ONCE here,
        // instead of calling getMyAttendanceStream() inside build().
        if (batchId != null && batchId.trim().isNotEmpty) {
          _attendanceStream =
              _attendanceService.getMyAttendanceStream(
            batchId: batchId,
          );
        } else {
          _attendanceStream = null;
        }
      });

      if (batchId != null) {
        _animationController.forward();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _batchError = error;
        _batchLoading = false;
      });
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'Attendance',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    // ----------------------------------------------------------
    // LOADING BATCH
    // ----------------------------------------------------------

    if (_batchLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // ----------------------------------------------------------
    // BATCH ERROR
    // ----------------------------------------------------------

    if (_batchError != null) {
      return _buildErrorState(
        _batchError,
      );
    }

    // ----------------------------------------------------------
    // NO BATCH
    // ----------------------------------------------------------

    if (_batchId == null ||
        _batchId!.trim().isEmpty) {
      return _buildNoBatchState();
    }

    // ----------------------------------------------------------
    // ATTENDANCE STREAM
    // ----------------------------------------------------------

    return StreamBuilder<List<AttendanceModel>>(
      // CHANGED: use the cached stream instead of calling
      // _attendanceService.getMyAttendanceStream(...) here.
      stream: _attendanceStream,

      builder: (
        context,
        snapshot,
      ) {
        // ------------------------------------------------------
        // ERROR
        // ------------------------------------------------------

        if (snapshot.hasError) {
          return _buildErrorState(
            snapshot.error,
          );
        }

        // ------------------------------------------------------
        // LOADING
        // ------------------------------------------------------

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // ------------------------------------------------------
        // RECORDS
        // ------------------------------------------------------

        final List<AttendanceModel> records =
            snapshot.data ?? [];

        // ------------------------------------------------------
        // EMPTY
        // ------------------------------------------------------

        if (records.isEmpty) {
          return RefreshIndicator(
            onRefresh: _loadStudentBatch,
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height:
                      MediaQuery.of(context).size.height *
                          0.30,
                ),
                _buildEmptyState(),
              ],
            ),
          );
        }

        // ------------------------------------------------------
        // MAIN CONTENT
        // ------------------------------------------------------

        return FadeTransition(
          opacity: _fadeAnimation,

          child: SlideTransition(
            position: _slideAnimation,

            child: RefreshIndicator(
              onRefresh: _loadStudentBatch,

              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.all(
                  AppDimensions.paddingLarge,
                ),

                children: [
                  // --------------------------------------------
                  // BATCH INFO
                  // --------------------------------------------

                  _buildBatchInfoCard(),

                  const SizedBox(
                    height: 16,
                  ),

                  // --------------------------------------------
                  // SUMMARY
                  // --------------------------------------------

                  _buildSummaryCard(
                    records,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // --------------------------------------------
                  // HISTORY TITLE
                  // --------------------------------------------

                  Text(
                    'Attendance History',
                    style:
                        AppTextStyles.heading2,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // --------------------------------------------
                  // ATTENDANCE LIST
                  // --------------------------------------------

                  ...records.map(
                    (record) {
                      return _buildAttendanceCard(
                        record,
                      );
                    },
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BATCH INFO CARD
  // ============================================================

  Widget _buildBatchInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius:
            BorderRadius.circular(
          AppDimensions.radiusMedium,
        ),

        border: Border.all(
          color:
              AppColors.divider,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color:
                  AppColors.primary.withValues(
                alpha: 0.10,
              ),

              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: const Icon(
              Icons.school_outlined,
              color: AppColors.primary,
              size: 21,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Current Batch',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        AppColors.textSecondary,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  _batchId ?? 'Not assigned',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.verified_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard(
    List<AttendanceModel> records,
  ) {
    final int present =
        _attendanceService.countPresent(
      records,
    );

    final int absent =
        _attendanceService.countAbsent(
      records,
    );

    final int leave =
        _attendanceService.countLeave(
      records,
    );

    final int late =
        _attendanceService.countLate(
      records,
    );

    final int total = records.length;

    final int attended = present + late;

    final double percentage =
        _attendanceService.calculatePercentage(
      records,
    );

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(
        AppDimensions.paddingLarge,
      ),

      decoration: BoxDecoration(
        color: AppColors.primary,

        borderRadius:
            BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),

        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Overall Attendance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,

            children: [
              Text(
                '${percentage.round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              const Padding(
                padding: EdgeInsets.only(
                  bottom: 7,
                ),
                child: Text(
                  'attendance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),

            child:
                LinearProgressIndicator(
              value:
                  (percentage / 100)
                      .clamp(0.0, 1.0),

              minHeight: 8,

              backgroundColor:
                  Colors.white24,

              valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
                Colors.white,
              ),
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Present',
                  present,
                ),
              ),

              Expanded(
                child: _buildSummaryItem(
                  'Absent',
                  absent,
                ),
              ),

              Expanded(
                child: _buildSummaryItem(
                  'Late',
                  late,
                ),
              ),

              Expanded(
                child: _buildSummaryItem(
                  'Total',
                  total,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            '$attended of $total classes attended',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),

          if (leave > 0) ...[
            const SizedBox(
              height: 4,
            ),

            Text(
              '$leave leave record${leave == 1 ? '' : 's'}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY ITEM
  // ============================================================

  Widget _buildSummaryItem(
    String title,
    int value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 2,
        ),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ATTENDANCE CARD
  // ============================================================

  Widget _buildAttendanceCard(
    AttendanceModel record,
  ) {
    return Card(
      elevation: 0,

      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.paddingLarge,
        ),

        child: Row(
          children: [
            // --------------------------------------------------
            // ICON
            // --------------------------------------------------

            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color:
                    _statusColor(
                  record.status,
                ).withValues(
                  alpha: 0.10,
                ),

                borderRadius:
                    BorderRadius.circular(14),
              ),

              child: Icon(
                _statusIcon(
                  record.status,
                ),

                color:
                    _statusColor(
                  record.status,
                ),

                size: 25,
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            // --------------------------------------------------
            // DETAILS
            // --------------------------------------------------

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    _statusTitle(
                      record.status,
                    ),

                    maxLines: 1,

                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons
                            .calendar_today_outlined,
                        size: 13,
                        color:
                            AppColors
                                .textSecondary,
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      Text(
                        _formatDate(
                          record.date,
                        ),

                        style:
                            const TextStyle(
                          fontSize: 11,
                          color:
                              AppColors
                                  .textSecondary,
                        ),
                      ),
                    ],
                  ),

                  if (record.markedBy
                      .trim()
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      'Marked by: ${record.markedBy}',

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(
                        fontSize: 10,
                        color:
                            AppColors
                                .textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            // --------------------------------------------------
            // STATUS BADGE
            // --------------------------------------------------

            _buildStatusBadge(
              record.status,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATUS ICON
  // ============================================================

  IconData _statusIcon(
    String status,
  ) {
    switch (status) {
      case 'present':
        return Icons.check_circle_rounded;

      case 'absent':
        return Icons.cancel_rounded;

      case 'late':
        return Icons.schedule_rounded;

      case 'leave':
        return Icons.event_busy_rounded;

      default:
        return Icons.help_outline_rounded;
    }
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(
    String status,
  ) {
    switch (status) {
      case 'present':
        return AppColors.primary;

      case 'absent':
        return AppColors.error;

      case 'late':
        return AppColors.warning;

      case 'leave':
        return AppColors.textSecondary;

      default:
        return AppColors.textSecondary;
    }
  }

  // ============================================================
  // STATUS TITLE
  // ============================================================

  String _statusTitle(
    String status,
  ) {
    switch (status) {
      case 'present':
        return 'Attendance Present';

      case 'absent':
        return 'Attendance Absent';

      case 'late':
        return 'Attendance Late';

      case 'leave':
        return 'Leave';

      default:
        return 'Attendance';
    }
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _buildStatusBadge(
    String status,
  ) {
    final Color color =
        _statusColor(status);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Text(
        _statusLabel(status),

        style: TextStyle(
          fontSize: 10,
          fontWeight:
              FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // STATUS LABEL
  // ============================================================

  String _statusLabel(
    String status,
  ) {
    switch (status) {
      case 'present':
        return 'Present';

      case 'absent':
        return 'Absent';

      case 'late':
        return 'Late';

      case 'leave':
        return 'Leave';

      default:
        return 'Unknown';
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(
    DateTime date,
  ) {
    if (date.millisecondsSinceEpoch == 0) {
      return 'Date unavailable';
    }

    final String day =
        date.day.toString().padLeft(
      2,
      '0',
    );

    final String month =
        date.month.toString().padLeft(
      2,
      '0',
    );

    return '$day/$month/${date.year}';
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(30),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          const Icon(
            Icons.fact_check_outlined,
            size: 64,
            color:
                AppColors.textSecondary,
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            'No attendance records',
            style:
                AppTextStyles.heading2,
            textAlign:
                TextAlign.center,
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            'Your attendance records for this batch will appear here once your instructor marks them.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NO BATCH STATE
  // ============================================================

  Widget _buildNoBatchState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 76,
              height: 76,

              decoration: BoxDecoration(
                color:
                    AppColors.primary
                        .withValues(
                  alpha: 0.10,
                ),

                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),

              child: const Icon(
                Icons.school_outlined,
                size: 40,
                color:
                    AppColors.primary,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Text(
              'No batch assigned',
              style:
                  AppTextStyles.heading2,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Your attendance will appear here after a batch is assigned to your student profile.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            OutlinedButton.icon(
              onPressed:
                  _loadStudentBatch,

              icon: const Icon(
                Icons.refresh_rounded,
              ),

              label: const Text(
                'Refresh',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
    Object? error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: AppColors.error,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              'Unable to load attendance',
              style:
                  AppTextStyles.heading2,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Please check your internet connection and try again.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            if (error != null)
              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color:
                      AppColors.error
                          .withValues(
                    alpha: 0.06,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child: Text(
                  error.toString(),

                  textAlign:
                      TextAlign.center,

                  maxLines: 4,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    fontSize: 10,
                    color:
                        AppColors
                            .textSecondary,
                  ),
                ),
              ),

            const SizedBox(
              height: 16,
            ),

            ElevatedButton.icon(
              onPressed:
                  _loadStudentBatch,

              icon: const Icon(
                Icons.refresh_rounded,
              ),

              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}