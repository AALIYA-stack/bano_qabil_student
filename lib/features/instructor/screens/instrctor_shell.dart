import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme/app_colors.dart';
import 'instructor_assignments_screen.dart';
import 'instructor_attendance_screen.dart';
import 'instructor_home_screen.dart';
import 'instructor_marks_screen.dart';
import 'instructor_students_screen.dart';

class InstructorShell extends StatefulWidget {
const InstructorShell({
super.key,
});

@override
State<InstructorShell> createState() =>
_InstructorShellState();
}

class _InstructorShellState
extends State<InstructorShell> {
// ============================================================
// CURRENT TAB
// ============================================================

int _currentIndex = 0;

bool _isLoadingIndex = true;

// Instructor ke liye separate key
// taake student/coordinator ki screen mix na ho.
static const String _selectedTabKey =
'instructor_selected_tab';

// ============================================================
// INSTRUCTOR SCREENS
// ============================================================

final List<Widget> _screens = const [
// 0 - Home
InstructorHomeScreen(),

// 1 - Students
InstructorStudentsScreen(),

// 2 - Attendance
InstructorAttendanceScreen(),

// 3 - Assignments
InstructorAssignmentsScreen(),

// 4 - Marks
InstructorMarksScreen(),
];

// ============================================================
// INIT
// ============================================================

@override
void initState() {
super.initState();
_loadSelectedTab();
}

// ============================================================
// LOAD LAST SELECTED TAB
// ============================================================

Future<void> _loadSelectedTab() async {
try {
final prefs =
await SharedPreferences.getInstance();

final savedIndex =
prefs.getInt(_selectedTabKey);

if (!mounted) return;

setState(() {
if (savedIndex != null &&
savedIndex >= 0 &&
savedIndex < _screens.length) {
_currentIndex = savedIndex;
} else {
_currentIndex = 0;
}

_isLoadingIndex = false;
});
} catch (_) {
if (!mounted) return;

setState(() {
_currentIndex = 0;
_isLoadingIndex = false;
});
}
}

// ============================================================
// SAVE SELECTED TAB
// ============================================================

Future<void> _saveSelectedTab(int index) async {
try {
final prefs =
await SharedPreferences.getInstance();

await prefs.setInt(
_selectedTabKey,
index,
);
} catch (_) {
// Storage error ko ignore karenge.
}
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
// Saved tab load hone tak screen show nahi karenge.
// Isse Home ka unnecessary flash nahi hoga.

if (_isLoadingIndex) {
return const Scaffold(
body: Center(
child: CircularProgressIndicator(),
),
);
}

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

_saveSelectedTab(index);
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
// STUDENTS
// ----------------------------------------------------

NavigationDestination(
icon: Icon(
Icons.people_outline_rounded,
),
selectedIcon: Icon(
Icons.people_rounded,
),
label: 'Students',
),

// ----------------------------------------------------
// ATTENDANCE
// ----------------------------------------------------

NavigationDestination(
icon: Icon(
Icons.fact_check_outlined,
),
selectedIcon: Icon(
Icons.fact_check_rounded,
),
label: 'Attendance',
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
// MARKS
// ----------------------------------------------------

NavigationDestination(
icon: Icon(
Icons.grade_outlined,
),
selectedIcon: Icon(
Icons.grade_rounded,
),
label: 'Marks',
),
],
),
);
}
}
