import 'package:flutter/material.dart';

// ============================================================
// AUTH
// ============================================================

import '../../data/seed_data/seed_data_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';

// ============================================================
// STUDENT
// ============================================================

import '../../features/instructor/screens/instrctor_shell.dart';
import '../../features/student/applications/screen/my_application_screen.dart';
import '../../features/student/student_shell.dart';
import '../../features/student/class/screen/my_classes_screen.dart';

// ============================================================
// INSTRUCTOR
// ============================================================
import '../../features/instructor/screens/instructor_attendance_screen.dart';
import '../../features/instructor/screens/instructor_students_screen.dart';
import '../../features/instructor/screens/instructor_assignments_screen.dart';
import '../../features/instructor/screens/instructor_marks_screen.dart';

// ============================================================
// SEED DATA
// ============================================================

class AppRoutes {
  AppRoutes._();

  // ============================================================
  // ROUTE NAMES
  // ============================================================

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // ------------------------------------------------------------
  // STUDENT
  // ------------------------------------------------------------

  static const String studentHome = '/student-home';

  static const String myClasses = '/my-classes';

  static const String myApplication = '/my-application';

  // ------------------------------------------------------------
  // INSTRUCTOR
  // ------------------------------------------------------------

  static const String instructorHome =
      '/instructor-home';

  static const String instructorAttendance =
      '/instructor-attendance';

  static const String instructorStudents =
      '/instructor-students';

  static const String instructorAssignments =
      '/instructor-assignments';

  static const String instructorMarks =
      '/instructor-marks';

  // ------------------------------------------------------------
  // COORDINATOR
  // ------------------------------------------------------------

  static const String coordinatorDashboard =
      '/coordinator-dashboard';

  // ------------------------------------------------------------
  // SEED DATA
  // ------------------------------------------------------------

  static const String seedData = '/seed-data';

  // ============================================================
  // ROUTES
  // ============================================================

  static Map<String, WidgetBuilder> get routes {
    return {
      // ========================================================
      // AUTH
      // ========================================================

      splash: (context) =>
      const SplashScreen(),

      login: (context) =>
      const LoginScreen(),

      register: (context) =>
      const RegisterScreen(),

      // ========================================================
      // STUDENT
      // ========================================================

      studentHome: (context) =>
      const StudentShell(),

      myClasses: (context) =>
      const MyClassesScreen(),

      myApplication: (context) =>
      const MyApplicationScreen(),

      // ========================================================
      // INSTRUCTOR
      // ========================================================

      // IMPORTANT:
      // Instructor ab direct HomeScreen ke bajaye
      // InstructorShell se open hoga.

      instructorHome: (context) =>
      const InstructorShell(),

      // Individual screens ko routes mein rehne dein.
      // Ye existing navigation/quick actions ke liye useful hain.

      instructorAttendance: (context) =>
      const InstructorAttendanceScreen(),

      instructorStudents: (context) =>
      const InstructorStudentsScreen(),

      instructorAssignments: (context) =>
      const InstructorAssignmentsScreen(),

      instructorMarks: (context) =>
      const InstructorMarksScreen(),

      // ========================================================
      // COORDINATOR
      // ========================================================

      // coordinatorDashboard: (context) =>
      //     const CoordinatorDashboardScreen(),

      // ========================================================
      // SEED DATA
      // ========================================================

      seedData: (context) =>
      const SeedDataScreen(),
    };
  }
}