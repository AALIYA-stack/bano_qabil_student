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

  final AssignmentService _assignmentService =
      AssignmentService.instance;

  final SubmissionService _submissionService =
      SubmissionService.instance;

  final ProgressService _progressService =
      ProgressService.instance;

  final CareerService _careerService =
      CareerService.instance;

  final NotificationService _notificationService =
      NotificationService.instance;

  // ============================================================
  // GET STUDENT DASHBOARD
  // ============================================================

  Future<StudentDashboardModel> getDashboard() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    // ==========================================================
    // USER
    // ==========================================================

    final UserModel? user =
    await _authService.getCurrentUserProfile();

    if (user == null) {
      throw Exception(
        'Student profile was not found in Firestore.',
      );
    }

    // ==========================================================
    // COURSE
    // ==========================================================

    CourseModel? course;

    final String? courseId = user.courseId;

    if (courseId != null &&
        courseId.trim().isNotEmpty) {
      try {
        course = await _getCourseById(
          courseId.trim(),
        );
      } catch (_) {
        course = null;
      }
    }

    // ==========================================================
    // BATCH
    // ==========================================================

    BatchModel? batch;

    final String? batchId = user.batchId;

    if (batchId != null &&
        batchId.trim().isNotEmpty) {
      try {
        batch = await _batchService.getBatchById(
          batchId.trim(),
        );
      } catch (_) {
        batch = null;
      }
    }

    // ==========================================================
    // INSTRUCTOR NAME
    // ==========================================================

    String instructorName = '';

    if (batch != null) {
      final String instructorId =
      batch!.instructorId.trim();

      if (instructorId.isNotEmpty) {
        try {
          final DocumentSnapshot<
              Map<String, dynamic>> instructorDoc =
          await _firestore
              .collection(
            CollectionNames.users,
          )
              .doc(instructorId)
              .get();

          if (instructorDoc.exists) {
            final Map<String, dynamic>? instructorData =
            instructorDoc.data();

            instructorName =
                (instructorData?['name'] ?? '')
                    .toString()
                    .trim();

            print(
              'STUDENT INSTRUCTOR DEBUG: '
                  'ID=$instructorId | '
                  'NAME=$instructorName',
            );
          } else {
            print(
              'STUDENT INSTRUCTOR DEBUG: '
                  'Instructor document not found. '
                  'ID=$instructorId',
            );
          }
        } catch (e) {
          print(
            'STUDENT INSTRUCTOR ERROR: $e',
          );

          instructorName = '';
        }
      } else {
        print(
          'STUDENT INSTRUCTOR DEBUG: '
              'No instructor assigned to batch.',
        );
      }
    }

    // ==========================================================
    // DEFAULT CAREER
    // ==========================================================

    final defaultCareerProgress =
    CareerProgressModel(
      studentId: firebaseUser.uid,
      cvReady: false,
      githubReady: false,
      projectsCompleted: 0,
      mockInterviewDone: false,
      jobsApplied: 0,
      updatedAt: null,
    );

    // ==========================================================
    // DEFAULT PROGRESS
    // ==========================================================

    ProgressModel progress =
    ProgressModel(
      completedModules: 0,
      totalModules: 0,
      attendancePercentage: 0,
      assignmentAverage: 0,
      careerProgress: defaultCareerProgress,
    );

    double attendancePercentage = 0;

    int totalAssignments = 0;
    int pendingAssignments = 0;
    int submittedAssignments = 0;
    int lateAssignments = 0;
    int markedAssignments = 0;

    // ==========================================================
    // COURSE + BATCH DATA
    // ==========================================================

    if (batchId != null &&
        batchId.trim().isNotEmpty &&
        courseId != null &&
        courseId.trim().isNotEmpty) {
      // --------------------------------------------------------
      // PROGRESS
      // --------------------------------------------------------

      try {
        progress =
        await _progressService.getMyProgress(
          batchId: batchId.trim(),
          courseId: courseId.trim(),
        );

        attendancePercentage =
            progress.attendancePercentage;
      } catch (_) {
        progress = ProgressModel(
          completedModules: 0,
          totalModules: 0,
          attendancePercentage: 0,
          assignmentAverage: 0,
          careerProgress:
          defaultCareerProgress,
        );

        attendancePercentage = 0;
      }

      // --------------------------------------------------------
      // ASSIGNMENTS
      // --------------------------------------------------------

      try {
        final assignmentData =
        await _loadAssignmentData(
          batchId.trim(),
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

    // ==========================================================
    // CAREER
    // ==========================================================

    CareerProgressModel? careerProgress;

    try {
      careerProgress =
      await _careerService.getMyCareerProgress();
    } catch (_) {
      careerProgress = null;
    }

    if (careerProgress != null) {
      progress = progress.copyWith(
        careerProgress: careerProgress,
      );
    }

    // ==========================================================
    // NOTIFICATIONS
    // ==========================================================

    int unreadNotifications = 0;

    try {
      unreadNotifications =
      await _notificationService.getUnreadCount();
    } catch (_) {
      unreadNotifications = 0;
    }

    // ==========================================================
    // RETURN
    // ==========================================================

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
      instructorName: instructorName,
    );
  }

  // ============================================================
  // GET COURSE
  // ============================================================

  Future<CourseModel?> _getCourseById(
      String courseId,
      ) async {
    final id = courseId.trim();

    if (id.isEmpty) {
      return null;
    }

    final doc = await _firestore
        .collection(
      CollectionNames.courses,
    )
        .doc(id)
        .get();

    if (!doc.exists) {
      return null;
    }

    return CourseModel.fromFirestore(
      doc,
    );
  }

  // ============================================================
  // LOAD ASSIGNMENT DATA
  // ============================================================

  Future<_AssignmentDashboardData>
  _loadAssignmentData(
      String batchId,
      ) async {
    final id = batchId.trim();

    if (id.isEmpty) {
      return const _AssignmentDashboardData(
        total: 0,
        pending: 0,
        submitted: 0,
        late: 0,
        marked: 0,
      );
    }

    // ----------------------------------------------------------
    // ASSIGNMENTS
    // ----------------------------------------------------------

    final assignments =
    await _assignmentService
        .getAssignmentsForBatch(
      id,
    );

    // ----------------------------------------------------------
    // SUBMISSIONS
    // ----------------------------------------------------------

    final submissions =
    await _submissionService
        .getMySubmissions();

    final batchSubmissions =
    submissions.where(
          (submission) =>
      submission.batchId == id,
    ).toList();

    // ----------------------------------------------------------
    // ASSIGNMENT ID -> SUBMISSION
    // ----------------------------------------------------------

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

    // ----------------------------------------------------------
    // CHECK ASSIGNMENTS
    // ----------------------------------------------------------

    for (final assignment
    in assignments) {
      final submission =
      submissionByAssignment[
      assignment.id];

      // No submission
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

// ============================================================
// PRIVATE DATA
// ============================================================

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