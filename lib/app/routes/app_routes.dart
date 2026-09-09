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
// ----------------------------------------------------------
// Splash
// ----------------------------------------------------------
splash: (context) => const SplashScreen(),

// ----------------------------------------------------------
// Authentication
// ----------------------------------------------------------
login: (context) => const LoginScreen(),

register: (context) => const RegisterScreen(),

// ----------------------------------------------------------
// STUDENT SHELL
// ----------------------------------------------------------
//
// Firebase login ke baad Student ko complete app shell milega:
//
// Home
// Courses
// Classes
// Assignments
// Progress
// Profile
//
studentHome: (context) => const StudentShell(),

// ----------------------------------------------------------
// STUDENT MY CLASSES
// ----------------------------------------------------------
myClasses: (context) => const MyClassesScreen(),

// ----------------------------------------------------------
// INSTRUCTOR
// ----------------------------------------------------------
//
// Actual Instructor screen ready hone ke baad yahan route
// register karenge.
//
// instructorHome: (context) => const InstructorHomeScreen(),

// ----------------------------------------------------------
// COORDINATOR
// ----------------------------------------------------------
//
// Actual Coordinator screen ready hone ke baad yahan route
// register karenge.
//
// coordinatorDashboard:
//     (context) => const CoordinatorDashboardScreen(),
};
}
}

