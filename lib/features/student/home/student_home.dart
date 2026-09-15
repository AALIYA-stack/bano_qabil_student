import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/animations/fade_slide_animation.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/quick_action_card.dart';
import '../../../core/widgets/welcome_header.dart';
import '../../../models/student_dashboard_model.dart';
import '../../../services/seed_service.dart';
import '../../../services/student_service.dart';

import '../../auth/screens/attendance/screens/attendance_screen.dart';
import '../../shared/notifications/screen/notifications_screen.dart';

import '../assignments/screen/assignments_screen.dart';
import '../assignments/widgets/assignment_summary_card.dart';
import '../attendence/widget/attendance_summary_card.dart';
import '../career/screen/career_readiness_screen.dart';
import '../class/widget/upcoming_class_card.dart';
import '../courses/widgets/current_course_card.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({
    super.key,
  });

  @override
  State<StudentHomeScreen> createState() =>
      _StudentHomeScreenState();
}

class _StudentHomeScreenState
    extends State<StudentHomeScreen> {
  late Future<StudentDashboardModel> _dashboardFuture;

  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // ============================================================
  // LOAD
  // ============================================================

  void _loadDashboard() {
    _dashboardFuture =
        StudentHomeService.instance.getDashboard();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    setState(() {
      _loadDashboard();
    });

    try {
      await _dashboardFuture;
    } catch (_) {}
  }

  // ============================================================
  // SEED DEMO STUDENTS
  // ============================================================

  Future<void> _seedDemoStudents() async {
    if (_isSeeding) return;

    setState(() {
      _isSeeding = true;
    });

    try {
      await SeedService.instance.seedOnlyStudents();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              '12 demo students seeded successfully!',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

      await _refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Seed failed: $e',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSeeding = false;
        });
      }
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    ).then((_) {
      if (mounted) {
        _loadDashboard();
        setState(() {});
      }
    });
  }

  void _openAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AttendanceScreen(),
      ),
    );
  }

  void _openAssignments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AssignmentsScreen(),
      ),
    );
  }

  void _openCareer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CareerReadinessScreen(),
      ),
    );
  }

  void _openMyApplication() {
    Navigator.pushNamed(
      context,
      AppRoutes.myApplication,
    );
  }

  void _openCourses() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Open Courses from the bottom navigation.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ========================================================
      // TEMPORARY SEED BUTTON
      // ========================================================

      floatingActionButton: FloatingActionButton.extended(
        onPressed:
        _isSeeding ? null : _seedDemoStudents,
        icon: _isSeeding
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(
          Icons.cloud_upload_outlined,
        ),
        label: Text(
          _isSeeding
              ? 'Seeding...'
              : 'Seed Demo Data',
        ),
      ),

      body: SafeArea(
        child: FutureBuilder<StudentDashboardModel>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            // ==================================================
            // LOADING
            // ==================================================

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const _DashboardLoading();
            }

            // ==================================================
            // ERROR
            // ==================================================

            if (snapshot.hasError) {
              return _ErrorView(
                error: snapshot.error,
                onRetry: _refresh,
              );
            }

            // ==================================================
            // EMPTY
            // ==================================================

            final data = snapshot.data;

            if (data == null) {
              return _EmptyDashboard(
                onRefresh: _refresh,
              );
            }

            // ==================================================
            // DASHBOARD
            // ==================================================

            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.accent,
              backgroundColor: AppColors.surface,
              displacement: 20,
              child: CustomScrollView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      32,
                    ),
                    sliver: SliverList(
                      delegate:
                      SliverChildListDelegate(
                        [
                          // ====================================
                          // WELCOME
                          // ====================================

                          FadeSlideAnimation(
                            child: WelcomeHeader(
                              name: data.user.name,
                              onNotificationTap:
                              _openNotifications,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          // ====================================
                          // NOTIFICATION BADGE
                          // ====================================

                          if (data.unreadNotifications > 0)
                            _NotificationBanner(
                              count:
                              data.unreadNotifications,
                              onTap:
                              _openNotifications,
                            ),

                          if (data.unreadNotifications > 0)
                            const SizedBox(
                              height: 18,
                            ),

                          // ====================================
                          // CURRENT COURSE
                          // ====================================

                          const _SectionLabel(
                            title: 'Current Course',
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          FadeSlideAnimation(
                            delay: const Duration(
                              milliseconds: 100,
                            ),
                            child: CurrentCourseCard(
                              courseName:
                              data.courseName,
                              campus:
                              data.campusName,
                              progress: data
                                  .progress
                                  .modulePercentage,
                              onTap:
                              _openCourses,
                            ),
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          // ====================================
                          // PROGRESS OVERVIEW
                          // ====================================

                          const _SectionLabel(
                            title:
                            'Progress Overview',
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          _ProgressOverviewCard(
                            progress:
                            data.progress,
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          // ====================================
                          // LEARNING
                          // ====================================

                          const _SectionLabel(
                            title: 'Your Learning',
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child:
                                FadeSlideAnimation(
                                  delay:
                                  const Duration(
                                    milliseconds: 180,
                                  ),
                                  child:
                                  AttendanceSummaryCard(
                                    percentage: data
                                        .attendancePercentage,
                                    onTap:
                                    _openAttendance,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child:
                                FadeSlideAnimation(
                                  delay:
                                  const Duration(
                                    milliseconds: 240,
                                  ),
                                  child:
                                  AssignmentSummaryCard(
                                    pending:
                                    data.pendingAssignments,
                                    total:
                                    data.totalAssignments,
                                    onTap:
                                    _openAssignments,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          _LearningStatusRow(
                            lateAssignments:
                            data.lateAssignments,
                            markedAssignments:
                            data.markedAssignments,
                            submittedAssignments:
                            data.submittedAssignments,
                          ),

                          // ====================================
                          // LOW ATTENDANCE WARNING
                          // ====================================

                          if (data.attendancePercentage <
                              80 &&
                              data.attendancePercentage >
                                  0) ...[
                            const SizedBox(
                              height: 12,
                            ),
                            _AttendanceWarning(
                              percentage:
                              data.attendancePercentage,
                              onTap:
                              _openAttendance,
                            ),
                          ],

                          const SizedBox(
                            height: 26,
                          ),

                          // ====================================
                          // UPCOMING CLASS
                          // ====================================

                          const _SectionLabel(
                            title: 'Upcoming Class',
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          FadeSlideAnimation(
                            delay: const Duration(
                              milliseconds: 300,
                            ),
                            child:
                            UpcomingClassCard(
                              day:
                              data.nextClassDay,
                              time:
                              data.nextClassTime,
                              room:
                              data.nextClassRoom,
                              instructor:
                              _formatInstructor(
                                data.instructorId,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 26,
                          ),

                          // ====================================
                          // QUICK ACTIONS
                          // ====================================

                          const _SectionLabel(
                            title: 'Quick Actions',
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          GridView.count(
                            crossAxisCount:
                            _getCrossAxisCount(
                              context,
                            ),
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio:
                            _getChildAspectRatio(
                              context,
                            ),
                            children: [
                              _AnimatedAction(
                                delay: 380,
                                icon: Icons
                                    .assignment_outlined,
                                title:
                                'Assignments',
                                subtitle:
                                '${data.pendingAssignments} pending',
                                onTap:
                                _openAssignments,
                              ),
                              _AnimatedAction(
                                delay: 430,
                                icon: Icons
                                    .calendar_month_outlined,
                                title:
                                'Attendance',
                                subtitle:
                                '${data.attendancePercentage.toStringAsFixed(0)}% present',
                                onTap:
                                _openAttendance,
                              ),
                              _AnimatedAction(
                                delay: 480,
                                icon: Icons
                                    .notifications_none_rounded,
                                title: 'Notices',
                                subtitle:
                                data.unreadNotifications >
                                    0
                                    ? '${data.unreadNotifications} unread'
                                    : 'Campus updates',
                                onTap:
                                _openNotifications,
                              ),
                              _AnimatedAction(
                                delay: 530,
                                icon: Icons
                                    .work_outline_rounded,
                                title: 'Career',
                                subtitle:
                                '${data.progress.careerReadinessPercentage.toStringAsFixed(0)}% ready',
                                onTap:
                                _openCareer,
                              ),
                              _AnimatedAction(
                                delay: 580,
                                icon: Icons
                                    .description_outlined,
                                title:
                                'My Application',
                                subtitle:
                                'View application',
                                onTap:
                                _openMyApplication,
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 26,
                          ),

                          // ====================================
                          // CAREER READINESS
                          // ====================================

                          _CareerReadinessCard(
                            percentage: data
                                .progress
                                .careerReadinessPercentage,
                            isJobReady: data
                                .progress
                                .isJobReady,
                            onTap:
                            _openCareer,
                          ),

                          const SizedBox(
                            height: 18,
                          ),

                          // ====================================
                          // JOB READY TIP
                          // ====================================

                          FadeSlideAnimation(
                            delay: const Duration(
                              milliseconds: 640,
                            ),
                            child:
                            _JobReadyTipCard(
                              onTap:
                              _openCareer,
                            ),
                          ),

                          const SizedBox(
                            height: 18,
                          ),

                          // ====================================
                          // FOOTER
                          // ====================================

                          FadeSlideAnimation(
                            delay: const Duration(
                              milliseconds: 700,
                            ),
                            child: const Center(
                              child: Text(
                                'Keep learning. Keep building. '
                                    'Keep moving forward.',
                                textAlign:
                                TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors
                                      .textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // RESPONSIVE
  // ============================================================

  int _getCrossAxisCount(
      BuildContext context,
      ) {
    final width =
        MediaQuery.sizeOf(context).width;

    if (width >= 900) {
      return 4;
    }

    return 2;
  }

  double _getChildAspectRatio(
      BuildContext context,
      ) {
    final width =
        MediaQuery.sizeOf(context).width;

    if (width >= 900) {
      return 1.35;
    }

    return 1.45;
  }

  // ============================================================
  // INSTRUCTOR
  // ============================================================

  String _formatInstructor(
      String instructorId,
      ) {
    final value =
    instructorId.trim();

    if (value.isEmpty) {
      return 'Instructor not assigned';
    }

    if (value.length > 24) {
      return 'Instructor assigned';
    }

    return value;
  }
}

// ============================================================
// SECTION LABEL
// ============================================================

class _SectionLabel
    extends StatelessWidget {
  final String title;

  const _SectionLabel({
    required this.title,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ============================================================
// NOTIFICATION BANNER
// ============================================================

class _NotificationBanner
    extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _NotificationBanner({
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(14),
        child: Ink(
          padding:
          const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius:
            BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.accent
                  .withValues(
                alpha: 0.15,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons
                      .notifications_active_outlined,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Text(
                  '$count new notification${count == 1 ? '' : 's'}',
                  style:
                  const TextStyle(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PROGRESS OVERVIEW
// ============================================================

class _ProgressOverviewCard
    extends StatelessWidget {
  final dynamic progress;

  const _ProgressOverviewCard({
    required this.progress,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final double module =
    _safePercentage(
      progress.modulePercentage,
    );

    final double attendance =
    _safePercentage(
      progress.attendancePercentage,
    );

    final double assignment =
    _safePercentage(
      progress.assignmentAverage,
    );

    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.accent
              .withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: Column(
        children: [
          _ProgressLine(
            title: 'Course Progress',
            value: module,
            icon:
            Icons.menu_book_outlined,
          ),
          const SizedBox(
            height: 14,
          ),
          _ProgressLine(
            title: 'Attendance',
            value: attendance,
            icon:
            Icons.calendar_today_outlined,
          ),
          const SizedBox(
            height: 14,
          ),
          _ProgressLine(
            title: 'Assignments',
            value: assignment,
            icon:
            Icons.assignment_outlined,
          ),
        ],
      ),
    );
  }

  double _safePercentage(
      dynamic value,
      ) {
    if (value is num) {
      return value
          .toDouble()
          .clamp(0, 100);
    }

    return 0;
  }
}

// ============================================================
// PROGRESS LINE
// ============================================================

class _ProgressLine
    extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;

  const _ProgressLine({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius:
            BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.accent,
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
              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                children: [
                  Text(
                    title,
                    style:
                    const TextStyle(
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${value.toStringAsFixed(0)}%',
                    style:
                    const TextStyle(
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w700,
                      color:
                      AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 7,
              ),
              ClipRRect(
                borderRadius:
                BorderRadius.circular(20),
                child:
                LinearProgressIndicator(
                  value: value / 100,
                  minHeight: 6,
                  backgroundColor:
                  AppColors.accentLight,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// LEARNING STATUS
// ============================================================

class _LearningStatusRow
    extends StatelessWidget {
  final int lateAssignments;
  final int markedAssignments;
  final int submittedAssignments;

  const _LearningStatusRow({
    required this.lateAssignments,
    required this.markedAssignments,
    required this.submittedAssignments,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatus(
            icon:
            Icons.upload_file_outlined,
            label: 'Submitted',
            value:
            submittedAssignments
                .toString(),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: _MiniStatus(
            icon:
            Icons.check_circle_outline,
            label: 'Marked',
            value:
            markedAssignments
                .toString(),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: _MiniStatus(
            icon:
            Icons.schedule_outlined,
            label: 'Late',
            value:
            lateAssignments
                .toString(),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MINI STATUS
// ============================================================

class _MiniStatus
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStatus({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.accent,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w700,
              color:
              AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color:
              AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ATTENDANCE WARNING
// ============================================================

class _AttendanceWarning
    extends StatelessWidget {
  final double percentage;
  final VoidCallback onTap;

  const _AttendanceWarning({
    required this.percentage,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(14),
        child: Ink(
          padding:
          const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
            Colors.orange.withValues(
              alpha: 0.08,
            ),
            borderRadius:
            BorderRadius.circular(14),
            border: Border.all(
              color:
              Colors.orange.withValues(
                alpha: 0.20,
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  'Your attendance is '
                      '${percentage.toStringAsFixed(0)}%. '
                      'Try to attend upcoming classes regularly.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color:
                    AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CAREER READINESS CARD
// ============================================================

class _CareerReadinessCard
    extends StatelessWidget {
  final double percentage;
  final bool isJobReady;
  final VoidCallback onTap;

  const _CareerReadinessCard({
    required this.percentage,
    required this.isJobReady,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final safePercentage =
    percentage.clamp(0, 100);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: Ink(
          padding:
          const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.accent
                  .withValues(
                alpha: 0.10,
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment:
                  Alignment.center,
                  children: [
                    SizedBox(
                      width: 68,
                      height: 68,
                      child:
                      CircularProgressIndicator(
                        value:
                        safePercentage /
                            100,
                        strokeWidth: 7,
                        backgroundColor:
                        AppColors
                            .accentLight,
                        color:
                        AppColors.accent,
                      ),
                    ),
                    Text(
                      '${safePercentage.toStringAsFixed(0)}%',
                      style:
                      const TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w800,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      isJobReady
                          ? 'You are Job-Ready 🎉'
                          : 'Career Readiness',
                      style:
                      const TextStyle(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w700,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      isJobReady
                          ? 'Great work! Keep building your career.'
                          : 'Complete your career checklist to become job-ready.',
                      style:
                      const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors
                            .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 15,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// QUICK ACTION
// ============================================================

class _AnimatedAction
    extends StatelessWidget {
  final int delay;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AnimatedAction({
    required this.delay,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return FadeSlideAnimation(
      delay: Duration(
        milliseconds: delay,
      ),
      child: QuickActionCard(
        icon: icon,
        title: title,
        onTap: onTap,
      ),
    );
  }
}

// ============================================================
// JOB READY TIP
// ============================================================

class _JobReadyTipCard
    extends StatelessWidget {
  final VoidCallback onTap;

  const _JobReadyTipCard({
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding:
          const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.accent
                  .withValues(
                alpha: 0.12,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child: const Icon(
                  Icons
                      .lightbulb_outline_rounded,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(
                width: 14,
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your job-ready journey',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w700,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Stay consistent with your classes, '
                          'complete assignments and build '
                          'projects to become job-ready.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: AppColors
                            .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 15,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOADING
// ============================================================

class _DashboardLoading
    extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(
      BuildContext context,
      ) {
    return const Center(
      child: Padding(
        padding:
        EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            LoadingWidget(),
            SizedBox(
              height: 18,
            ),
            Text(
              'Loading your dashboard...',
              style: TextStyle(
                fontSize: 14,
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

// ============================================================
// EMPTY
// ============================================================

class _EmptyDashboard
    extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyDashboard({
    required this.onRefresh,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.accent,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
            MediaQuery.sizeOf(context)
                .height *
                0.72,
            child: Center(
              child: Padding(
                padding:
                const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration:
                      BoxDecoration(
                        color: AppColors
                            .accentLight,
                        borderRadius:
                        BorderRadius.circular(
                          26,
                        ),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        size: 42,
                        color:
                        AppColors.accent,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Your dashboard is empty',
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w700,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      'Your course, batch and learning '
                          'information will appear here '
                          'once your student account is '
                          'properly enrolled.',
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors
                            .textSecondary,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    OutlinedButton.icon(
                      onPressed: onRefresh,
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label:
                      const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ErrorView
    extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  String _message() {
    return error?.toString() ??
        'Unknown dashboard error';
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Center(
      child: SingleChildScrollView(
        padding:
        const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color:
                Colors.red.withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 42,
                color:
                Colors.redAccent,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Unable to load dashboard',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.w700,
                color:
                AppColors.textPrimary,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                BorderRadius.circular(12),
                border: Border.all(
                  color:
                  Colors.red.withValues(
                    alpha: 0.20,
                  ),
                ),
              ),
              child: SelectableText(
                _message(),
                textAlign:
                TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color:
                  AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(
              height: 22,
            ),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label:
              const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}