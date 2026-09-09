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
  });

  String get courseName {
    return course?.name ??
        'Course not assigned';
  }

  String get campusName {
    if (user.campus.trim().isEmpty) {
      return 'Campus not assigned';
    }

    return user.campus;
  }

  String get nextClassDay {
    final day = batch?.classDay;

    if (day == null ||
        day.trim().isEmpty) {
      return 'No class scheduled';
    }

    return day;
  }

  String get nextClassTime {
    final time = batch?.classTime;

    if (time == null ||
        time.trim().isEmpty) {
      return '--';
    }

    return time;
  }

  String get nextClassRoom {
    final room = batch?.room;

    if (room == null ||
        room.trim().isEmpty) {
      return '--';
    }

    return room;
  }

  String get instructorId {
    return batch?.instructorId ?? '';
  }
}