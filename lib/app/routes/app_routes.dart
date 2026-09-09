import 'package:flutter/material.dart';
import '../../features/instructor/screens/instructor_home_screen.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/student/my_classes_screen.dart';
import '../../features/student/student_dashboard_screen.dart';

class AppRoutes {
AppRoutes._();

// =========================
// ROUTE NAMES
// =========================

static const String splash = '/';
static const String login = '/login';
static const String register = '/register';

static const String studentHome = '/student-home';
static const String myClasses = '/my-classes';

// Future roles
static const String instructorHome = '/instructor-home';
static const String coordinatorDashboard =
'/coordinator-dashboard';

// =========================
// ROUTES
// =========================

static Map<String, WidgetBuilder> get routes {
return {
splash: (context) => const SplashScreen(),

login: (context) => const LoginScreen(),

register: (context) => const RegisterScreen(),

// Student Dashboard
studentHome: (context) =>
const StudentDashboardScreen(),

// Student My Classes
myClasses: (context) =>
const MyClassesScreen(),
instructorHome: (context) => const InstructorHomeScreen(),
};
}
}

