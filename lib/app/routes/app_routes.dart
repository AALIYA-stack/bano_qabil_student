import 'package:flutter/material.dart';

// Auth
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';

// Student
import '../../features/student/student_shell.dart';
import '../../features/student/class/screen/my_classes_screen.dart';

// Instructor
import '../../features/instructor/screens/instructor_home_screen.dart';

class AppRoutes {
  AppRoutes._();

  // ============================================================
  // ROUTE NAMES
  // ============================================================

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Student
  static const String studentHome = '/student-home';
  static const String myClasses = '/my-classes';

  // Instructor
  static const String instructorHome = '/instructor-home';

  // Coordinator
  static const String coordinatorDashboard =
      '/coordinator-dashboard';

  // ============================================================
  // ROUTES
  // ============================================================

  static Map<String, WidgetBuilder> get routes {
    return {
      // ----------------------------------------------------------
      // AUTH
      // ----------------------------------------------------------

      splash: (context) => const SplashScreen(),

      login: (context) => const LoginScreen(),

      register: (context) => const RegisterScreen(),

      // ----------------------------------------------------------
      // STUDENT
      // ----------------------------------------------------------

      studentHome: (context) => const StudentShell(),

      myClasses: (context) => const MyClassesScreen(),

      // ----------------------------------------------------------
      // INSTRUCTOR
      // ----------------------------------------------------------

      instructorHome: (context) =>
      const InstructorHomeScreen(),

      // ----------------------------------------------------------
      // COORDINATOR
      // ----------------------------------------------------------

      // coordinatorDashboard: (context) =>
      //     const CoordinatorDashboardScreen(),
    };
  }
}