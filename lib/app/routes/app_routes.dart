import 'package:flutter/material.dart';

// ============================================================
// AUTH
// ============================================================

import '../../../data/seed_data/seed_data_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';

// ============================================================
// STUDENT
// ============================================================

import '../../features/student/applications/screen/my_application_screen.dart';
import '../../features/student/class/screen/my_classes_screen.dart';
import '../../features/student/student_shell.dart';

// ============================================================
// INSTRUCTOR
// ============================================================

import '../../features/instructor/screens/instrctor_shell.dart';
import '../../features/instructor/screens/instructor_attendance_screen.dart';
import '../../features/instructor/screens/instructor_assignments_screen.dart';
import '../../features/instructor/screens/instructor_marks_screen.dart';
import '../../features/instructor/screens/instructor_students_screen.dart';

// ============================================================
// COORDINATOR
// ============================================================

import '../../features/coordinator/screens/coordinator_shell.dart';
import '../../features/coordinator/screens/coordinator_applications_screen.dart';
import '../../features/coordinator/screens/coordinator_batches_screen.dart';
import '../../features/coordinator/screens/coordinator_assign_instructor_screen.dart';
import '../../features/coordinator/screens/coordinator_notices_screen.dart';
import '../../features/coordinator/screens/coordinator_report_screen.dart';

// ============================================================
// NOTIFICATIONS
// ============================================================
//
// Agar aapki notifications screen ka actual path different hai,
// to sirf is import ko apne existing path ke according change karein.
//

import '../../features/shared/notifications/screen/notifications_screen.dart';

// ============================================================
// APP ROUTES
// ============================================================

class AppRoutes {
  AppRoutes._();

  // ============================================================
  // AUTH
  // ============================================================

  static const String splash = '/';

  static const String login = '/login';

  static const String register = '/register';

  // ============================================================
  // STUDENT
  // ============================================================

  static const String studentHome =
      '/student-home';

  static const String myClasses =
      '/my-classes';

  static const String myApplication =
      '/my-application';

  // ============================================================
  // INSTRUCTOR
  // ============================================================

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

  // ============================================================
  // COORDINATOR
  // ============================================================

  static const String coordinatorDashboard =
      '/coordinator-dashboard';

  static const String coordinatorApplications =
      '/coordinator-applications';

  static const String coordinatorBatches =
      '/coordinator-batches';

  static const String coordinatorAssignInstructor =
      '/coordinator-assign-instructor';

  static const String coordinatorNotices =
      '/coordinator-notices';

  static const String coordinatorReport =
      '/coordinator-report';

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  static const String notifications =
      '/notifications';

  // ============================================================
  // SEED DATA
  // ============================================================

  static const String seedData =
      '/seed-data';

  // ============================================================
  // ROUTES MAP
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

      // Student direct HomeScreen ke bajaye
      // StudentShell se open hoga.

      studentHome: (context) =>
      const StudentShell(),

      myClasses: (context) =>
      const MyClassesScreen(),

      myApplication: (context) =>
      const MyApplicationScreen(),

      // ========================================================
      // INSTRUCTOR
      // ========================================================

      // Instructor direct HomeScreen ke bajaye
      // InstructorShell se open hoga.

      instructorHome: (context) =>
      const InstructorShell(),

      // Individual Instructor screens
      // existing navigation / quick actions ke liye.

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

      // Coordinator direct DashboardScreen ke bajaye
      // CoordinatorShell se open hoga.

      coordinatorDashboard: (context) =>
      const CoordinatorShell(),

      // --------------------------------------------------------
      // Coordinator Individual Screens
      // --------------------------------------------------------

      coordinatorApplications: (context) =>
      const CoordinatorApplicationsScreen(),

      coordinatorBatches: (context) =>
      const CoordinatorBatchesScreen(),

      coordinatorAssignInstructor: (context) =>
      const CoordinatorAssignInstructorScreen(),

      coordinatorNotices: (context) =>
      const CoordinatorNoticesScreen(),

      coordinatorReport: (context) =>
      const CoordinatorReportScreen(),

      // ========================================================
      // NOTIFICATIONS
      // ========================================================

      notifications: (context) =>
      const NotificationsScreen(),

      // ========================================================
      // SEED DATA
      // ========================================================

      seedData: (context) =>
      const SeedDataScreen(),
    };
  }
}