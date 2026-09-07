import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../services/auth_service.dart';

class StudentDashboardScreen extends StatefulWidget {
const StudentDashboardScreen({super.key});

@override
State<StudentDashboardScreen> createState() =>
_StudentDashboardScreenState();
}

class _StudentDashboardScreenState
extends State<StudentDashboardScreen>
with SingleTickerProviderStateMixin {
// =========================================================
// STATE
// =========================================================

String _studentName = 'Student';
String _studentCity = '';

bool _isLoading = true;

// Temporary values.
// Later these will come from Firestore.
double _courseProgress = 0.0;
int _attendance = 0;
int _assignments = 0;
int _completedAssignments = 0;

// =========================================================
// ANIMATION
// =========================================================

late final AnimationController _animationController;

late final Animation<double> _fadeAnimation;

late final Animation<Offset> _slideAnimation;

@override
void initState() {
super.initState();

_animationController = AnimationController(
vsync: this,
duration: const Duration(
milliseconds: 900,
),
);

_fadeAnimation = CurvedAnimation(
parent: _animationController,
curve: Curves.easeOutCubic,
);

_slideAnimation = Tween<Offset>(
begin: const Offset(0, 0.08),
end: Offset.zero,
).animate(
CurvedAnimation(
parent: _animationController,
curve: Curves.easeOutCubic,
),
);

_loadStudentProfile();
}

@override
void dispose() {
_animationController.dispose();
super.dispose();
}

// =========================================================
// FIREBASE PROFILE
// =========================================================

Future<void> _loadStudentProfile() async {
try {
if (mounted) {
setState(() {
_isLoading = true;
});
}

final document =
await AuthService.instance.getCurrentUserProfile();

if (!mounted) return;

if (document != null && document.exists) {
final data = document.data();

setState(() {
_studentName =
(data?['name'] ?? 'Student').toString();

_studentCity =
(data?['city'] ?? '').toString();

_isLoading = false;
});
} else {
setState(() {
_studentName = 'Student';
_studentCity = '';
_isLoading = false;
});
}

_animationController.forward(
from: 0,
);
} catch (_) {
if (!mounted) return;

setState(() {
_isLoading = false;
});

_animationController.forward(
from: 0,
);

_showMessage(
'Unable to load your profile. Please try again.',
isError: true,
);
}
}

// =========================================================
// LOGOUT
// =========================================================

Future<void> _logout() async {
final shouldLogout = await showDialog<bool>(
context: context,
builder: (context) {
return AlertDialog(
title: const Text(
'Logout',
),
content: const Text(
'Are you sure you want to logout?',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(
context,
false,
);
},
child: const Text(
'Cancel',
),
),
ElevatedButton(
onPressed: () {
Navigator.pop(
context,
true,
);
},
child: const Text(
'Logout',
),
),
],
);
},
);

if (shouldLogout != true) {
return;
}

await AuthService.instance.logout();

if (!mounted) return;

Navigator.pushNamedAndRemoveUntil(
context,
AppRoutes.login,
(route) => false,
);
}

// =========================================================
// MESSAGE
// =========================================================

void _showMessage(
String message, {
bool isError = false,
}) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
behavior: SnackBarBehavior.floating,
duration: const Duration(
seconds: 2,
),
),
);
}

// =========================================================
// COMING SOON
// =========================================================

void _comingSoon(String feature) {
_showMessage(
'$feature will be available soon.',
);
}

// =========================================================
// BUILD
// =========================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.background,

// =====================================================
// APP BAR
// =====================================================

appBar: AppBar(
automaticallyImplyLeading: false,
elevation: 0,

title: Row(
children: [
Container(
width: 38,
height: 38,
decoration: BoxDecoration(
color: AppColors.accentLight,
borderRadius: BorderRadius.circular(
12,
),
),
child: Icon(
Icons.school_rounded,
color: AppColors.primary,
size: 22,
),
),

const SizedBox(width: 10),

const Text(
'Bano Qabil',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
],
),

actions: [
IconButton(
tooltip: 'Notifications',
onPressed: () {
_comingSoon('Notifications');
},
icon: const Icon(
Icons.notifications_none_rounded,
),
),

IconButton(
tooltip: 'Logout',
onPressed: _isLoading ? null : _logout,
icon: const Icon(
Icons.logout_rounded,
),
),

const SizedBox(width: 4),
],
),

// =====================================================
// BODY
// =====================================================

body: _isLoading
? const Center(
child: CircularProgressIndicator(),
)
    : RefreshIndicator(
onRefresh: _loadStudentProfile,
child: SingleChildScrollView(
physics:
const AlwaysScrollableScrollPhysics(),
padding: const EdgeInsets.all(
AppDimensions.paddingLarge,
),
child: FadeTransition(
opacity: _fadeAnimation,
child: SlideTransition(
position: _slideAnimation,
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_buildWelcomeCard(),

const SizedBox(height: 24),

_buildSectionTitle(
'My Course',
),

const SizedBox(height: 12),

_buildCourseCard(),

const SizedBox(height: 24),

_buildSectionTitle(
'Quick Access',
),

const SizedBox(height: 12),

_buildQuickAccessGrid(),

const SizedBox(height: 24),

_buildSectionTitle(
'Learning Overview',
),

const SizedBox(height: 12),

_buildOverviewCard(),

const SizedBox(height: 24),

_buildJobReadyCard(),

const SizedBox(height: 20),
],
),
),
),
),
),

// =====================================================
// BOTTOM NAVIGATION
// =====================================================

bottomNavigationBar:
_buildBottomNavigationBar(),
);
}

// =========================================================
// WELCOME CARD
// =========================================================

Widget _buildWelcomeCard() {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(
AppDimensions.paddingLarge,
),
decoration: BoxDecoration(
color: AppColors.primary,
borderRadius: BorderRadius.circular(
AppDimensions.radiusLarge,
),
boxShadow: const [
BoxShadow(
color: AppColors.shadow,
blurRadius: 16,
offset: Offset(
0,
7,
),
),
],
),
child: Row(
children: [
// Profile icon
Container(
width: 60,
height: 60,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(
18,
),
),
child: Icon(
Icons.person_rounded,
color: AppColors.primary,
size: 34,
),
),

const SizedBox(width: 16),

// Student information
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Welcome back 👋',
style: TextStyle(
color: Colors.white70,
fontSize: 13,
),
),

const SizedBox(height: 4),

Text(
_studentName,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
color: Colors.white,
fontSize: 21,
fontWeight: FontWeight.w800,
),
),

if (_studentCity.isNotEmpty) ...[
const SizedBox(height: 5),

Row(
children: [
const Icon(
Icons.location_on_outlined,
color: Colors.white70,
size: 14,
),
const SizedBox(width: 4),
Expanded(
child: Text(
_studentCity,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
color:
Colors.white70,
fontSize: 12,
),
),
),
],
),
],
],
),
),
],
),
);
}

// =========================================================
// SECTION TITLE
// =========================================================

Widget _buildSectionTitle(
String title,
) {
return Text(
title,
style: AppTextStyles.heading2,
);
}

// =========================================================
// COURSE CARD
// =========================================================

Widget _buildCourseCard() {
return Card(
elevation: 0,
child: InkWell(
borderRadius: BorderRadius.circular(
AppDimensions.radiusMedium,
),
onTap: () {
_comingSoon('Course Details');
},
child: Padding(
padding: const EdgeInsets.all(
AppDimensions.paddingLarge,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 54,
height: 54,
decoration: BoxDecoration(
color:
AppColors.accentLight,
borderRadius:
BorderRadius.circular(
16,
),
),
child: Icon(
Icons.code_rounded,
color: AppColors.primary,
size: 29,
),
),

const SizedBox(width: 14),

const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
'My IT Course',
style: TextStyle(
fontSize: 17,
fontWeight:
FontWeight.w800,
),
),
SizedBox(height: 4),
Text(
'Bano Qabil Training Program',
style: TextStyle(
fontSize: 12,
color: AppColors
    .textSecondary,
),
),
],
),
),

Container(
padding:
const EdgeInsets
    .symmetric(
horizontal: 10,
vertical: 6,
),
decoration:
BoxDecoration(
color:
AppColors.accentLight,
borderRadius:
BorderRadius.circular(
20,
),
),
child: const Text(
'Active',
style: TextStyle(
fontSize: 11,
fontWeight:
FontWeight.w700,
),
),
),
],
),

const SizedBox(height: 22),

Row(
mainAxisAlignment:
MainAxisAlignment
    .spaceBetween,
children: [
const Text(
'Course Progress',
style: TextStyle(
fontSize: 14,
fontWeight:
FontWeight.w700,
),
),
Text(
'${(_courseProgress * 100).round()}%',
style: const TextStyle(
fontSize: 14,
fontWeight:
FontWeight.w800,
),
),
],
),

const SizedBox(height: 9),

ClipRRect(
borderRadius:
BorderRadius.circular(
10,
),
child:
LinearProgressIndicator(
value: _courseProgress,
minHeight: 8,
),
),

const SizedBox(height: 14),

Row(
children: const [
Icon(
Icons.calendar_today_outlined,
size: 15,
color:
AppColors.textSecondary,
),
SizedBox(width: 6),
Text(
'Next class: Not scheduled',
style: TextStyle(
fontSize: 12,
color:
AppColors.textSecondary,
),
),
],
),
],
),
),
),
);
}

// =========================================================
// QUICK ACCESS
// =========================================================

Widget _buildQuickAccessGrid() {
final items = [
(
'My Classes',
Icons.school_outlined,
),
(
'Attendance',
Icons.fact_check_outlined,
),
(
'Assignments',
Icons.assignment_outlined,
),
(
'Job Ready',
Icons.work_outline_rounded,
),
];

return GridView.builder(
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),
itemCount: items.length,
gridDelegate:
const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
crossAxisSpacing: 12,
mainAxisSpacing: 12,
childAspectRatio: 1.25,
),
itemBuilder: (
context,
index,
) {
final item = items[index];

return Card(
elevation: 0,
child: InkWell(
borderRadius:
BorderRadius.circular(
AppDimensions.radiusMedium,
),
onTap: () {
_comingSoon(item.$1);
},
child: Padding(
padding:
const EdgeInsets.all(
14,
),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Container(
width: 46,
height: 46,
decoration: BoxDecoration(
color:
AppColors.accentLight,
borderRadius:
BorderRadius.circular(
14,
),
),
child: Icon(
item.$2,
color:
AppColors.primary,
size: 25,
),
),

const SizedBox(height: 9),

Text(
item.$1,
textAlign:
TextAlign.center,
style: const TextStyle(
fontSize: 13,
fontWeight:
FontWeight.w700,
),
),
],
),
),
),
);
},
);
}

// =========================================================
// OVERVIEW
// =========================================================

Widget _buildOverviewCard() {
return Card(
elevation: 0,
child: Padding(
padding: const EdgeInsets.symmetric(
vertical: 20,
horizontal: 8,
),
child: Row(
children: [
Expanded(
child: _buildStatItem(
icon:
Icons.check_circle_outline,
title: 'Attendance',
value: '$_attendance%',
),
),

_buildVerticalDivider(),

Expanded(
child: _buildStatItem(
icon:
Icons.assignment_outlined,
title: 'Assignments',
value: '$_assignments',
),
),

_buildVerticalDivider(),

Expanded(
child: _buildStatItem(
icon:
Icons.task_alt_rounded,
title: 'Completed',
value:
'$_completedAssignments',
),
),
],
),
),
);
}

Widget _buildVerticalDivider() {
return Container(
width: 1,
height: 55,
color: AppColors.border,
);
}

Widget _buildStatItem({
required IconData icon,
required String title,
required String value,
}) {
return Column(
children: [
Icon(
icon,
color: AppColors.primary,
size: 25,
),

const SizedBox(height: 7),

Text(
value,
style: const TextStyle(
fontSize: 17,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 2),

Text(
title,
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 10,
color: AppColors.textSecondary,
),
),
],
);
}

// =========================================================
// JOB READY CARD
// =========================================================

Widget _buildJobReadyCard() {
return Card(
elevation: 0,
child: InkWell(
borderRadius: BorderRadius.circular(
AppDimensions.radiusMedium,
),
onTap: () {
_comingSoon('Job Readiness');
},
child: Padding(
padding: const EdgeInsets.all(
AppDimensions.paddingLarge,
),
child: Row(
children: [
Container(
width: 52,
height: 52,
decoration: BoxDecoration(
color: AppColors.accentLight,
borderRadius:
BorderRadius.circular(
15,
),
),
child: Icon(
Icons.work_outline_rounded,
color: AppColors.primary,
size: 28,
),
),

const SizedBox(width: 14),

const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Job Readiness',
style: TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w800,
),
),
SizedBox(height: 4),
Text(
'Track your journey towards becoming job-ready.',
maxLines: 2,
style: TextStyle(
fontSize: 12,
color:
AppColors.textSecondary,
),
),
],
),
),

Icon(
Icons.arrow_forward_ios_rounded,
size: 17,
color: AppColors.textSecondary,
),
],
),
),
),
);
}

// =========================================================
// BOTTOM NAVIGATION
// =========================================================

Widget _buildBottomNavigationBar() {
return NavigationBar(
selectedIndex: 0,

onDestinationSelected: (
index,
) {
switch (index) {
case 0:
break;

case 1:
_comingSoon('Classes');
break;

case 2:
_comingSoon('Assignments');
break;

case 3:
_comingSoon('Profile');
break;
}
},

destinations: const [
NavigationDestination(
icon: Icon(
Icons.dashboard_outlined,
),
selectedIcon: Icon(
Icons.dashboard_rounded,
),
label: 'Home',
),

NavigationDestination(
icon: Icon(
Icons.school_outlined,
),
selectedIcon: Icon(
Icons.school_rounded,
),
label: 'Classes',
),

NavigationDestination(
icon: Icon(
Icons.assignment_outlined,
),
selectedIcon: Icon(
Icons.assignment_rounded,
),
label: 'Tasks',
),

NavigationDestination(
icon: Icon(
Icons.person_outline_rounded,
),
selectedIcon: Icon(
Icons.person_rounded,
),
label: 'Profile',
),
],
);
}
}

