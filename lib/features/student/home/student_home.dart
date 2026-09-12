import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/animations/fade_slide_animation.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/quick_action_card.dart';
import '../../../core/widgets/welcome_header.dart';
import '../../../models/student_dashboard_model.dart';
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
State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
late Future<StudentDashboardModel> _dashboardFuture;

@override
void initState() {
super.initState();
_loadDashboard();
}

// ============================================================
// LOAD DASHBOARD
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
} catch (_) {
// FutureBuilder handles the error state.
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
);
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
// Courses are already available from the StudentShell.
// We avoid inventing another route here.
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
delegate: SliverChildListDelegate(
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

const SizedBox(height: 24),

// ====================================
// CURRENT COURSE
// ====================================

const _SectionLabel(
title: 'Current Course',
),

const SizedBox(height: 10),

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
    .overallPercentage,
onTap: _openCourses,
),
),

const SizedBox(height: 18),

// ====================================
// ATTENDANCE + ASSIGNMENTS
// ====================================

const _SectionLabel(
title: 'Your Learning',
),

const SizedBox(height: 10),

Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Expanded(
child: FadeSlideAnimation(
delay:
const Duration(
milliseconds: 180,
),
child:
AttendanceSummaryCard(
percentage:
data.attendancePercentage,
onTap:
_openAttendance,
),
),
),
const SizedBox(width: 12),
Expanded(
child: FadeSlideAnimation(
delay:
const Duration(
milliseconds: 240,
),
child:
AssignmentSummaryCard(
pending: data
    .pendingAssignments,
total: data
    .totalAssignments,
onTap:
_openAssignments,
),
),
),
],
),

const SizedBox(height: 26),

// ====================================
// UPCOMING CLASS
// ====================================

const _SectionLabel(
title: 'Upcoming Class',
),

const SizedBox(height: 10),

FadeSlideAnimation(
delay: const Duration(
milliseconds: 300,
),
child: UpcomingClassCard(
day: data.nextClassDay,
time: data.nextClassTime,
room: data.nextClassRoom,
instructor:
_formatInstructor(
data.instructorId,
),
),
),

const SizedBox(height: 26),

// ====================================
// QUICK ACTIONS
// ====================================

const _SectionLabel(
title: 'Quick Actions',
),

const SizedBox(height: 10),

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
title: 'Assignments',
subtitle:
'${data.pendingAssignments} pending',
onTap:
_openAssignments,
),
_AnimatedAction(
delay: 430,
icon: Icons
    .calendar_month_outlined,
title: 'Attendance',
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
'Campus updates',
onTap:
_openNotifications,
),
_AnimatedAction(
delay: 530,
icon: Icons
    .work_outline_rounded,
title: 'Career',
subtitle:
'Get job-ready',
onTap: _openCareer,
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

const SizedBox(height: 26),

// ====================================
// JOB READY CARD
// ====================================

FadeSlideAnimation(
delay: const Duration(
milliseconds: 640,
),
child:
_JobReadyTipCard(
onTap: _openCareer,
),
),

const SizedBox(height: 18),

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
color:
AppColors.textSecondary,
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
// RESPONSIVE HELPERS
// ============================================================

int _getCrossAxisCount(BuildContext context) {
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
// INSTRUCTOR DISPLAY
// ============================================================

String _formatInstructor(String instructorId) {
final value = instructorId.trim();

if (value.isEmpty) {
return 'Instructor not assigned';
}

// Until instructor profile resolving is added to
// StudentHomeService, do not show an ugly empty value.
//
// Later this will become something like:
// "Sir Hamza"
//
// instead of the Firebase UID.

if (value.length > 24) {
return 'Instructor assigned';
}

return value;
}
}

// ============================================================
// SECTION LABEL
// ============================================================

class _SectionLabel extends StatelessWidget {
final String title;

const _SectionLabel({
required this.title,
});

@override
Widget build(BuildContext context) {
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
// ANIMATED QUICK ACTION
// ============================================================

class _AnimatedAction extends StatelessWidget {
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
Widget build(BuildContext context) {
return FadeSlideAnimation(
delay: Duration(
milliseconds: delay,
),
child: QuickActionCard(
icon: icon,
title: title,
onTap: () {
onTap();
},
),
);
}
}

// ============================================================
// JOB READY TIP
// ============================================================

class _JobReadyTipCard extends StatelessWidget {
final VoidCallback onTap;

const _JobReadyTipCard({
required this.onTap,
});

@override
Widget build(BuildContext context) {
return Material(
color: Colors.transparent,
child: InkWell(
onTap: onTap,
borderRadius:
BorderRadius.circular(18),
child: Ink(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: AppColors.accentLight,
borderRadius:
BorderRadius.circular(18),
border: Border.all(
color: AppColors.accent.withValues(
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
BorderRadius.circular(14),
),
child: const Icon(
Icons.lightbulb_outline_rounded,
color: AppColors.accent,
),
),
const SizedBox(width: 14),
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
color:
AppColors.textPrimary,
),
),
SizedBox(height: 5),
Text(
'Stay consistent with your classes, '
'complete assignments and build '
'projects to become job-ready.',
style: TextStyle(
fontSize: 12,
height: 1.45,
color:
AppColors.textSecondary,
),
),
],
),
),
const SizedBox(width: 8),
const Icon(
Icons.arrow_forward_ios_rounded,
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
// LOADING STATE
// ============================================================

class _DashboardLoading extends StatelessWidget {
const _DashboardLoading();

@override
Widget build(BuildContext context) {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
const LoadingWidget(),
const SizedBox(height: 18),
Text(
'Loading your dashboard...',
style: Theme.of(context)
    .textTheme
    .bodyMedium
    ?.copyWith(
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
// EMPTY STATE
// ============================================================

class _EmptyDashboard extends StatelessWidget {
final Future<void> Function() onRefresh;

const _EmptyDashboard({
required this.onRefresh,
});

@override
Widget build(BuildContext context) {
return RefreshIndicator(
onRefresh: onRefresh,
color: AppColors.accent,
child: ListView(
physics:
const AlwaysScrollableScrollPhysics(),
children: [
SizedBox(
height:
MediaQuery.sizeOf(context).height *
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
decoration: BoxDecoration(
color:
AppColors.accentLight,
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
const SizedBox(height: 20),
const Text(
'Your dashboard is empty',
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
const SizedBox(height: 8),
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
color:
AppColors.textSecondary,
),
),
const SizedBox(height: 22),
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
// ERROR STATE
// ============================================================

class _ErrorView extends StatelessWidget {
final Object? error;
final VoidCallback onRetry;

const _ErrorView({
required this.error,
required this.onRetry,
});

String _message() {
final value =
error?.toString().toLowerCase() ?? '';

if (value.contains('batchid') ||
value.contains('batch id')) {
return 'Your application does not have a batch assigned yet.';
}

if (value.contains('permission-denied')) {
return 'You do not have permission to access this information.';
}

if (value.contains('network')) {
return 'Please check your internet connection and try again.';
}

if (value.contains('not-found')) {
return 'Some student information could not be found.';
}

return 'We could not load your dashboard right now.';
}

@override
Widget build(BuildContext context) {
return Center(
child: SingleChildScrollView(
padding: const EdgeInsets.all(28),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Container(
width: 82,
height: 82,
decoration: BoxDecoration(
color: Colors.red.withValues(
alpha: 0.08,
),
borderRadius:
BorderRadius.circular(26),
),
child: const Icon(
Icons.cloud_off_rounded,
size: 42,
color: Colors.redAccent,
),
),

const SizedBox(height: 20),

const Text(
'Unable to load dashboard',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 20,
fontWeight:
FontWeight.w700,
color:
AppColors.textPrimary,
),
),

const SizedBox(height: 10),

Text(
_message(),
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 14,
height: 1.5,
color:
AppColors.textSecondary,
),
),

const SizedBox(height: 22),

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
