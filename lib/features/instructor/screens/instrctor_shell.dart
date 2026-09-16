import 'package:flutter/material.dart';

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
  int _currentIndex = 0;

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