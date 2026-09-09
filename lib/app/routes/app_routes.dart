import 'package:flutter/material.dart';

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

  // =========================
  // Route Names
  // =========================

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

  // =========================
  // Routes
  // =========================

  static Map<String, WidgetBuilder> get routes {
    return {
      // Auth
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),

      // Student
      studentHome: (context) => const StudentShell(),
      myClasses: (context) => const MyClassesScreen(),

      // Instructor
      instructorHome: (context) =>
      const InstructorHomeScreen(),

      // Coordinator
      // coordinatorDashboard: (context) =>
      //     const CoordinatorDashboardScreen(),
    };
  }
}