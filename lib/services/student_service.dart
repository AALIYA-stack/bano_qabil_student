import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/collection_names.dart';
import '../models/student_dashboard_model.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/batch_model.dart';
import '../models/progress_model.dart';
import '../models/submission_model.dart';
import '../models/career_progress_model.dart';

import 'auth_service.dart';
import 'batch_service.dart';
import 'assignment_service.dart';
import 'submission_service.dart';
import 'progress_service.dart';
import 'career_service.dart';
import 'notification_service.dart';

class StudentHomeService {
  StudentHomeService._();

  static final StudentHomeService instance =
  StudentHomeService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final AuthService _authService =
      AuthService.instance;

  final BatchService _batchService =
      BatchService.instance;

  final AssignmentService
  _assignmentService =
      AssignmentService.instance;

  final SubmissionService
  _submissionService =
      SubmissionService.instance;

  final ProgressService _progressService =
      ProgressService.instance;

  final CareerService _careerService =
      CareerService.instance;

  final NotificationService
  _notificationService =
      NotificationService.instance;

  Future<StudentDashboardModel>
  getDashboard() async {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    // -----------------------------
    // CURRENT USER PROFILE
    // -----------------------------

    final UserModel? user =
    await _authService
        .getCurrentUserProfile();

    if (user == null) {
      throw Exception(
        'Student profile was not found.',
      );
    }

    // -----------------------------
    // COURSE
    // -----------------------------

    CourseModel? course;

    final courseId = user.courseId;

    if (courseId != null &&
        courseId.trim().isNotEmpty) {
      course =
      await _getCourseById(
        courseId,
      );
    }

    // -----------------------------
    // BATCH
    // -----------------------------

    BatchModel? batch;

    final batchId = user.batchId;

    if (batchId != null &&
        batchId.trim().isNotEmpty) {
      batch =
      await _batchService
          .getBatchById(
        batchId,
      );
    }

    // -----------------------------
    // DEFAULT PROGRESS
    // -----------------------------

    ProgressModel progress =
    const ProgressModel(
      completedModules: 0,
      totalModules: 0,
      attendancePercentage: 0,
      assignmentAverage: 0,
    );

    double attendancePercentage = 0;

    int totalAssignments = 0;
    int pendingAssignments = 0;
    int submittedAssignments = 0;
    int lateAssignments = 0;
    int markedAssignments = 0;

    // -----------------------------
    // BATCH DATA
    // -----------------------------

    if (batchId != null &&
        batchId.trim().isNotEmpty) {
      try {
        progress =
        await _progressService
            .getMyProgress(
          batchId: batchId,
        );

        attendancePercentage =
            progress.attendancePercentage;
      } catch (_) {
        progress =
        const ProgressModel(
          completedModules: 0,
          totalModules: 0,
          attendancePercentage: 0,
          assignmentAverage: 0,
        );

        attendancePercentage = 0;
      }

      try {
        final assignmentData =
        await _loadAssignmentData(
          batchId,
        );

        totalAssignments =
            assignmentData.total;

        pendingAssignments =
            assignmentData.pending;

        submittedAssignments =
            assignmentData.submitted;

        lateAssignments =
            assignmentData.late;

        markedAssignments =
            assignmentData.marked;
      } catch (_) {
        totalAssignments = 0;
        pendingAssignments = 0;
        submittedAssignments = 0;
        lateAssignments = 0;
        markedAssignments = 0;
      }
    }

    // -----------------------------
    // CAREER
    // -----------------------------

    CareerProgressModel?
    careerProgress;

    try {
      careerProgress =
      await _careerService
          .getMyCareerProgress();
    } catch (_) {
      careerProgress = null;
    }

    // -----------------------------
    // NOTIFICATIONS
    // -----------------------------

    int unreadNotifications = 0;

    try {
      unreadNotifications =
      await _notificationService
          .getUnreadCount();
    } catch (_) {
      unreadNotifications = 0;
    }

    // -----------------------------
    // FINAL DASHBOARD
    // -----------------------------

    return StudentDashboardModel(
      user: user,
      course: course,
      batch: batch,
      attendancePercentage:
      attendancePercentage,
      totalAssignments:
      totalAssignments,
      pendingAssignments:
      pendingAssignments,
      submittedAssignments:
      submittedAssignments,
      lateAssignments:
      lateAssignments,
      markedAssignments:
      markedAssignments,
      progress: progress,
      careerProgress:
      careerProgress,
      unreadNotifications:
      unreadNotifications,
    );
  }

  // ==================================================
  // COURSE
  // ==================================================

  Future<CourseModel?> _getCourseById(
      String courseId,
      ) async {
    if (courseId.trim().isEmpty) {
      return null;
    }

    final doc =
    await _firestore
        .collection(
      CollectionNames.courses,
    )
        .doc(courseId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return CourseModel.fromFirestore(
      doc,
    );
  }

  // ==================================================
  // ASSIGNMENT DATA
  // ==================================================

  Future<_AssignmentDashboardData>
  _loadAssignmentData(
      String batchId,
      ) async {
    final assignments =
    await _assignmentService
        .getAssignmentsForBatch(
      batchId,
    );

    final submissions =
    await _submissionService
        .getMySubmissions();

    final batchSubmissions =
    submissions
        .where(
          (submission) =>
      submission.batchId ==
          batchId,
    )
        .toList();

    final Map<String, SubmissionModel>
    submissionByAssignment = {};

    for (final submission
    in batchSubmissions) {
      submissionByAssignment[
      submission.assignmentId] =
          submission;
    }

    int pending = 0;
    int submitted = 0;
    int late = 0;
    int marked = 0;

    for (final assignment
    in assignments) {
      final submission =
      submissionByAssignment[
      assignment.id];

      if (submission == null) {
        pending++;
        continue;
      }

      if (submission.isSubmitted) {
        submitted++;
      }

      if (submission.isLate) {
        late++;
      }

      if (submission.isMarked) {
        marked++;
      }
    }

    return _AssignmentDashboardData(
      total: assignments.length,
      pending: pending,
      submitted: submitted,
      late: late,
      marked: marked,
    );
  }
}

// ======================================================
// PRIVATE ASSIGNMENT DATA
// ======================================================

class _AssignmentDashboardData {
  final int total;
  final int pending;
  final int submitted;
  final int late;
  final int marked;

  const _AssignmentDashboardData({
    required this.total,
    required this.pending,
    required this.submitted,
    required this.late,
    required this.marked,
  });
}