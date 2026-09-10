import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';

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
  // FIREBASE
  // ============================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // ANIMATION
  // ============================================================

  late final AnimationController
  _animationController;

  late final Animation<double>
  _fadeAnimation;

  late final Animation<Offset>
  _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(
            milliseconds: 700,
          ),
        );

    _fadeAnimation =
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // ATTENDANCE STREAM
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
  _attendanceStream() {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('attendance')
        .where(
      'studentId',
      isEqualTo: user.uid,
    )
        .snapshots();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      AppColors.background,

      appBar: AppBar(
        title: const Text(
          'Attendance',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _attendanceStream(),

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
              child:
              CircularProgressIndicator(),
            );
          }

          // ------------------------------------------------------
          // DOCUMENTS
          // ------------------------------------------------------

          final documents =
              snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return _buildEmptyState();
          }

          // ------------------------------------------------------
          // SORT BY DATE
          // ------------------------------------------------------

          final sortedDocuments =
          List<QueryDocumentSnapshot<
              Map<String, dynamic>>>.from(
            documents,
          );

          sortedDocuments.sort(
                (a, b) {
              final DateTime dateA =
              _getDate(
                a.data()['date'],
              );

              final DateTime dateB =
              _getDate(
                b.data()['date'],
              );

              return dateB.compareTo(dateA);
            },
          );

          return FadeTransition(
            opacity: _fadeAnimation,

            child: SlideTransition(
              position: _slideAnimation,

              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },

                child: ListView(
                  physics:
                  const AlwaysScrollableScrollPhysics(),

                  padding:
                  const EdgeInsets.all(
                    AppDimensions
                        .paddingLarge,
                  ),

                  children: [
                    _buildSummaryCard(
                      sortedDocuments,
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Text(
                      'Attendance History',
                      style:
                      AppTextStyles.heading2,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    ...sortedDocuments.map(
                          (document) {
                        return _buildAttendanceCard(
                          document,
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
      ),
    );
  }

  // ============================================================
  // GET DATE
  // ============================================================

  DateTime _getDate(
      dynamic value,
      ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ??
          DateTime.now();
    }

    return DateTime.now();
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard(
      List<QueryDocumentSnapshot<
          Map<String, dynamic>>>
      documents,
      ) {
    int present = 0;
    int absent = 0;
    int leave = 0;
    int late = 0;

    for (final document in documents) {
      final Map<String, dynamic> data =
      document.data();

      final String status =
      (data['status'] ?? '')
          .toString()
          .toLowerCase();

      if (status == 'present') {
        present++;
      } else if (status == 'absent') {
        absent++;
      } else if (status == 'leave') {
        leave++;
      } else if (status == 'late') {
        late++;
      }
    }

    final int total =
        present + absent + leave + late;

    final int attended =
        present + late;

    final double percentage =
    total == 0
        ? 0
        : (attended / total) * 100;

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
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Text(
                '${percentage.round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              const Padding(
                padding: EdgeInsets.only(
                  bottom: 6,
                ),
                child: Text(
                  'attendance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
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
                  present.toString(),
                ),
              ),

              Expanded(
                child: _buildSummaryItem(
                  'Absent',
                  absent.toString(),
                ),
              ),

              Expanded(
                child: _buildSummaryItem(
                  'Late',
                  late.toString(),
                ),
              ),

              Expanded(
                child: _buildSummaryItem(
                  'Total',
                  total.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY ITEM
  // ============================================================

  Widget _buildSummaryItem(
      String title,
      String value,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
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
      QueryDocumentSnapshot<
          Map<String, dynamic>>
      document,
      ) {
    final Map<String, dynamic> data =
    document.data();

    final DateTime attendanceDate =
    _getDate(data['date']);

    final String date =
    _formatDate(attendanceDate);

    final String batchId =
    (data['batchId'] ?? '')
        .toString();

    final String status =
    (data['status'] ?? 'unknown')
        .toString()
        .toLowerCase();

    final String markedBy =
    (data['markedBy'] ?? '')
        .toString();

    final bool isPresent =
        status == 'present';

    final bool isLate =
        status == 'late';

    final bool isLeave =
        status == 'leave';

    return Card(
      elevation: 0,

      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: Padding(
        padding:
        const EdgeInsets.all(
          AppDimensions.paddingLarge,
        ),

        child: Row(
          children: [
            // ----------------------------------------------------
            // ICON
            // ----------------------------------------------------

            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color:
                AppColors.accentLight,

                borderRadius:
                BorderRadius.circular(
                  14,
                ),
              ),

              child: Icon(
                _statusIcon(status),

                color:
                _statusColor(status),

                size: 25,
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            // ----------------------------------------------------
            // DETAILS
            // ----------------------------------------------------

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    _statusTitle(status),

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
                    height: 4,
                  ),

                  Text(
                    batchId.isEmpty
                        ? 'Batch not assigned'
                        : 'Batch: $batchId',

                    maxLines: 1,

                    overflow:
                    TextOverflow.ellipsis,

                    style:
                    const TextStyle(
                      fontSize: 11,
                      color:
                      AppColors
                          .textSecondary,
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
                        date,
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

                  if (markedBy.isNotEmpty) ...[
                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      'Marked by: $markedBy',
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

            // ----------------------------------------------------
            // STATUS
            // ----------------------------------------------------

            _buildStatusBadge(
              status,
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
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color:
        _statusColor(status)
            .withValues(
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
          color:
          _statusColor(status),
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
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),

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
              'Your attendance records will appear here.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                AppColors.textSecondary,
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
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            if (error != null)
              Text(
                error.toString(),
                textAlign:
                TextAlign.center,
                maxLines: 3,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  fontSize: 10,
                  color:
                  AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}