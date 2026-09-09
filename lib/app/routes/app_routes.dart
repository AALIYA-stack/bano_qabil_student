import 'package:flutter/material.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';

import '../../features/student/class/screen/my_classes_screen.dart';
import '../../features/student/student_shell.dart';

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

// Future roles
static const String instructorHome = '/instructor-home';
static const String coordinatorDashboard =
'/coordinator-dashboard';

// ============================================================
// ROUTES
// ============================================================

static Map<String, WidgetBuilder> get routes {
return {
// --------------------------------------------------------
// Splash
// --------------------------------------------------------
splash: (context) => const SplashScreen(),

// --------------------------------------------------------
// Authentication
// --------------------------------------------------------
login: (context) => const LoginScreen(),

register: (context) => const RegisterScreen(),

// --------------------------------------------------------
// STUDENT SHELL
// --------------------------------------------------------
//
// Login ke baad student ko complete shell milega:
//
// Home
// Courses
// Classes
// Assignments
// Progress
// Profile
//
studentHome: (context) => const StudentShell(),

// --------------------------------------------------------
// Student My Classes
// --------------------------------------------------------
myClasses: (context) => const MyClassesScreen(),
};
}
}
