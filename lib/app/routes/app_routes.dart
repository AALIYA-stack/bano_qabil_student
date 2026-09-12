import 'package:flutter/material.dart';

// ============================================================
// AUTH
// ============================================================

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';

// ============================================================
// STUDENT
// ============================================================

import '../../features/student/applications/screen/my_application_screen.dart';
import '../../features/student/student_shell.dart';
import '../../features/student/class/screen/my_classes_screen.dart';

// ============================================================
// INSTRUCTOR
// ============================================================

import '../../features/instructor/screens/instructor_home_screen.dart';

class AppRoutes {
  AppRoutes._();

  // ============================================================
  // ROUTE NAMES
  // ============================================================

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // ------------------------------------------------------------
  // Student
  // ------------------------------------------------------------

  static const String studentHome = '/student-home';

  static const String myClasses = '/my-classes';

  static const String myApplication =
      '/my-application';

  // ------------------------------------------------------------
  // Instructor
  // ------------------------------------------------------------

  static const String instructorHome =
      '/instructor-home';

  // ------------------------------------------------------------
  // Coordinator
  // ------------------------------------------------------------

  static const String coordinatorDashboard =
      '/coordinator-dashboard';

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

      instructorHome: (context) =>
      const InstructorHomeScreen(),

      // ========================================================
      // COORDINATOR
      // ========================================================

      // coordinatorDashboard: (context) =>
      //     const CoordinatorDashboardScreen(),
    };
  }
}