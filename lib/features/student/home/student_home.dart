import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/animations/fade_slide_animation.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/quick_action_card.dart';
import '../../../core/widgets/welcome_header.dart';
import '../../../models/student_dashboard_model.dart';
import '../../../services/student_service.dart';

import '../../auth/screens/attendance/screens/attendance_screen.dart';
import '../../shared/notifications/screen/notifications_screen.dart';

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

await _dashboardFuture;
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

void _openCareer() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const CareerReadinessScreen(),
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
builder: (
context,
snapshot,
) {
// ==================================================
// LOADING
// ==================================================

if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: LoadingWidget(),
);
}

// ==================================================
// ERROR
// ==================================================

if (snapshot.hasError) {
return _ErrorView(
onRetry: _refresh,
);
}

// ==================================================
// EMPTY DATA
// ==================================================

final data = snapshot.data;

if (data == null) {
return _ErrorView(
onRetry: _refresh,
);
}

// ==================================================
// DASHBOARD
// ==================================================

return RefreshIndicator(
onRefresh: _refresh,
child: SingleChildScrollView(
physics:
const AlwaysScrollableScrollPhysics(),
padding: const EdgeInsets.fromLTRB(
20,
18,
20,
30,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// ==========================================
// WELCOME HEADER
// ==========================================

FadeSlideAnimation(
child: WelcomeHeader(
name: data.user.name,
onNotificationTap:
_openNotifications,
),
),

const SizedBox(height: 24),

// ==========================================
// CURRENT COURSE
// ==========================================

FadeSlideAnimation(
delay: const Duration(
milliseconds: 80,
),
child: CurrentCourseCard(
courseName:
data.courseName,
campus:
data.campusName,
progress: data
    .progress
    .overallPercentage,
onTap: () {},
),
),

const SizedBox(height: 16),

// ==========================================
// ATTENDANCE
// ==========================================

FadeSlideAnimation(
delay: const Duration(
milliseconds: 160,
),
child:
AttendanceSummaryCard(
percentage:
data.attendancePercentage,
onTap:
_openAttendance,
),
),

const SizedBox(height: 12),

// ==========================================
// ASSIGNMENTS
// ==========================================

FadeSlideAnimation(
delay: const Duration(
milliseconds: 240,
),
child:
AssignmentSummaryCard(
pending:
data.pendingAssignments,
total:
data.totalAssignments,
onTap: () {},
),
),

const SizedBox(height: 26),

// ==========================================
// UPCOMING CLASS TITLE
// ==========================================

const FadeSlideAnimation(
delay: Duration(
milliseconds: 300,
),
child: Text(
'Upcoming Class',
style: TextStyle(
fontSize: 18,
fontWeight:
FontWeight.w700,
color:
AppColors.textPrimary,
),
),
),

const SizedBox(height: 12),

// ==========================================
// UPCOMING CLASS
// ==========================================

FadeSlideAnimation(
delay: const Duration(
milliseconds: 350,
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
data.instructorId
    .trim()
    .isEmpty
? 'Instructor not assigned'
    : data
    .instructorId,
),
),

const SizedBox(height: 26),

// ==========================================
// QUICK ACTIONS TITLE
// ==========================================

const FadeSlideAnimation(
delay: Duration(
milliseconds: 400,
),
child: Text(
'Quick Actions',
style: TextStyle(
fontSize: 18,
fontWeight:
FontWeight.w700,
color:
AppColors.textPrimary,
),
),
),

const SizedBox(height: 12),

// ==========================================
// QUICK ACTIONS
// ==========================================

GridView.count(
crossAxisCount: 2,
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),
mainAxisSpacing: 12,
crossAxisSpacing: 12,
childAspectRatio: 1.5,
children: [
_AnimatedAction(
delay: 450,
icon: Icons
    .assignment_outlined,
title: 'Assignments',
onTap: () {},
),
_AnimatedAction(
delay: 500,
icon: Icons
    .calendar_month_outlined,
title: 'Attendance',
onTap:
_openAttendance,
),
_AnimatedAction(
delay: 550,
icon: Icons
    .notifications_none_rounded,
title: 'Notices',
onTap:
_openNotifications,
),
_AnimatedAction(
delay: 600,
icon: Icons
    .work_outline_rounded,
title: 'Career',
onTap: _openCareer,
),
],
),

const SizedBox(height: 20),

// ==========================================
// JOB-READY TIP
// ==========================================

FadeSlideAnimation(
delay: const Duration(
milliseconds: 650,
),
child: Container(
width: double.infinity,
padding:
const EdgeInsets.all(16),
decoration:
BoxDecoration(
color:
AppColors.accentLight,
borderRadius:
BorderRadius.circular(16),
),
child: const Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
Icons
    .lightbulb_outline_rounded,
color:
AppColors.accent,
),
SizedBox(width: 12),
Expanded(
child: Text(
'Stay consistent with your classes and assignments to become job-ready.',
style: TextStyle(
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
],
),
),
);
},
),
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
final VoidCallback onTap;

const _AnimatedAction({
required this.delay,
required this.icon,
required this.title,
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
onTap: onTap,
),
);
}
}

// ============================================================
// ERROR VIEW
// ============================================================

class _ErrorView extends StatelessWidget {
final VoidCallback onRetry;

const _ErrorView({
required this.onRetry,
});

@override
Widget build(BuildContext context) {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
const Icon(
Icons.cloud_off_rounded,
size: 56,
color: AppColors.textLight,
),

const SizedBox(height: 16),

const Text(
'Unable to load dashboard',
style: TextStyle(
fontSize: 18,
fontWeight:
FontWeight.w700,
color:
AppColors.textPrimary,
),
textAlign: TextAlign.center,
),

const SizedBox(height: 8),

const Text(
'Please check your internet connection and try again.',
textAlign: TextAlign.center,
style: TextStyle(
color:
AppColors.textSecondary,
),
),

const SizedBox(height: 20),

ElevatedButton.icon(
onPressed: onRetry,
icon: const Icon(
Icons.refresh_rounded,
),
label: const Text(
'Retry',
),
),
],
),
),
);
}
}

