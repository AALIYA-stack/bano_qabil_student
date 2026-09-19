import 'course_model.dart';
import 'batch_model.dart';
import 'user_model.dart';
import 'progress_model.dart';
import 'career_progress_model.dart';

class StudentDashboardModel {
  final UserModel user;
  final CourseModel? course;
  final BatchModel? batch;

  final double attendancePercentage;

  final int totalAssignments;
  final int pendingAssignments;
  final int submittedAssignments;
  final int lateAssignments;
  final int markedAssignments;

  final ProgressModel progress;

  final CareerProgressModel? careerProgress;

  final int unreadNotifications;

  // ============================================================
  // INSTRUCTOR
  // ============================================================

  final String instructorName;

  const StudentDashboardModel({
    required this.user,
    required this.course,
    required this.batch,
    required this.attendancePercentage,
    required this.totalAssignments,
    required this.pendingAssignments,
    required this.submittedAssignments,
    required this.lateAssignments,
    required this.markedAssignments,
    required this.progress,
    required this.careerProgress,
    required this.unreadNotifications,
    required this.instructorName,
  });

  // ============================================================
  // STUDENT
  // ============================================================

  String get studentName {
    final name = user.name.trim();

    if (name.isEmpty) {
      return 'Student';
    }

    return name;
  }

  // ============================================================
  // COURSE
  // ============================================================

  String get courseName {
    return course?.name ?? 'Course not assigned';
  }

  // ============================================================
  // CAMPUS
  // ============================================================

  String get campusName {
    if (user.campus.trim().isEmpty) {
      return 'Campus not assigned';
    }

    return user.campus;
  }

  // ============================================================
  // BATCH
  // ============================================================

  String get batchName {
    final currentBatch = batch;

    if (currentBatch == null) {
      return 'Batch not assigned';
    }

    final courseTitle = course?.name.trim() ?? '';

    if (courseTitle.isNotEmpty &&
        currentBatch.classDay.trim().isNotEmpty) {
      return '$courseTitle Batch';
    }

    if (currentBatch.id.trim().isNotEmpty) {
      return currentBatch.id;
    }

    return 'Batch assigned';
  }

  // ============================================================
  // CLASS
  // ============================================================

  String get nextClassDay {
    final day = batch?.classDay;

    if (day == null || day.trim().isEmpty) {
      return 'No class scheduled';
    }

    return day;
  }

  String get nextClassTime {
    final time = batch?.classTime;

    if (time == null || time.trim().isEmpty) {
      return '--';
    }

    return time;
  }

  String get nextClassRoom {
    final room = batch?.room;

    if (room == null || room.trim().isEmpty) {
      return '--';
    }

    return room;
  }

  // ============================================================
  // INSTRUCTOR
  // ============================================================

  String get instructorId {
    return batch?.instructorId ?? '';
  }

  String get teacherName {
    final name = instructorName.trim();

    if (name.isEmpty) {
      return 'Instructor not assigned';
    }

    return name;
  }

  // ============================================================
  // UPCOMING CLASS
  // ============================================================

  String get upcomingClassTitle {
    if (batch == null) {
      return 'No upcoming class';
    }

    if (nextClassDay == 'No class scheduled') {
      return 'No upcoming class';
    }

    return '$courseName • $nextClassDay';
  }

  String get upcomingClassTime {
    if (batch == null) {
      return '--';
    }

    final time = nextClassTime;
    final room = nextClassRoom;

    if (room == '--') {
      return time;
    }

    return '$time • $room';
  }

  // ============================================================
  // ASSIGNMENTS
  // ============================================================

  int get completedAssignments {
    return submittedAssignments;
  }

  // ============================================================
  // MODULE PROGRESS
  // ============================================================

  int get completedModules {
    return progress.completedModules;
  }

  int get totalModules {
    return progress.totalModules;
  }

  // ============================================================
  // CAREER READINESS
  // ============================================================

  int get careerReadinessPercentage {
    final career = careerProgress;

    if (career == null) {
      return 0;
    }

    return career.readinessPercentage.round();
  }
}