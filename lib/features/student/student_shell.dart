import 'package:bano_qabil_student_app/features/student/progress/screen/progress_screen.dart';
import 'package:bano_qabil_student_app/features/student/timetable/screen/timetable_screen.dart';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../shared/profile/screen/profile_screen.dart';
import 'assignments/screen/assignments_screen.dart';
import 'courses/screen/course_list_screen.dart';
import 'home/student_home.dart';

class StudentShell extends StatefulWidget {
const StudentShell({
super.key,
});

@override
State<StudentShell> createState() =>
_StudentShellState();
}

class _StudentShellState
extends State<StudentShell> {
int _currentIndex = 0;

// ============================================================
// STUDENT SCREENS
// ============================================================

final List<Widget> _screens = const [
// 0 - Home
StudentHomeScreen(),

// 1 - Courses
CourseListScreen(),

// 2 - Classes
TimetableScreen(),

// 3 - Assignments
AssignmentsScreen(),

// 4 - Progress
ProgressScreen(),

// 5 - Profile
ProfileScreen(),
];

@override
Widget build(BuildContext context) {
return Scaffold(
body: IndexedStack(
index: _currentIndex,
children: _screens,
),

// ========================================================
// BOTTOM NAVIGATION
// ========================================================

bottomNavigationBar: NavigationBar(
selectedIndex: _currentIndex,

onDestinationSelected: (index) {
setState(() {
_currentIndex = index;
});
},

backgroundColor:
AppColors.surface,

indicatorColor:
AppColors.accentLight,

destinations: const [
// ----------------------------------------------------
// HOME
// ----------------------------------------------------

NavigationDestination(
icon: Icon(
Icons.home_outlined,
),
selectedIcon: Icon(
Icons.home_rounded,
),
label: 'Home',
),

// ----------------------------------------------------
// COURSES
// ----------------------------------------------------

NavigationDestination(
icon: Icon(
Icons.school_outlined,
),
selectedIcon: Icon(
Icons.school_rounded,
),
label: 'Courses',
),

// ----------------------------------------------------
// CLASSES
// ----------------------------------------------------

NavigationDestination(
icon: Icon(
Icons.calendar_month_outlined,
),
selectedIcon: Icon(
Icons.calendar_month_rounded,
),
label: 'Classes',
),

// ----------------------------------------------------
// ASSIGNMENTS
// ----------------------------------------------------

NavigationDestination(
icon: Icon(
Icons.assignment_outlined,
),
selectedIcon: Icon(
Icons.assignment_rounded,
),
label: 'Assignments',
),

// ----------------------------------------------------
// PROGRESS
// ----------------------------------------------------

NavigationDestination(
icon: Icon(
Icons.insights_outlined,
),
selectedIcon: Icon(
Icons.insights_rounded,
),
label: 'Progress',
),

// ----------------------------------------------------
// PROFILE
// ----------------------------------------------------

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
),
);
}
}

