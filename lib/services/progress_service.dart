import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/collection_names.dart';
import '../models/career_progress_model.dart';
import '../models/progress_model.dart';
import 'attendance_service.dart';
import 'career_service.dart';
import 'module_service.dart';

class ProgressService {
  ProgressService._();

  static final ProgressService instance =
  ProgressService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // CURRENT USER UID
  // ============================================================

  String get _uid {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  // ============================================================
  // DEFAULT CAREER PROGRESS
  // ============================================================

  CareerProgressModel _defaultCareerProgress() {
    return CareerProgressModel(
      studentId: _uid,
      cvReady: false,
      githubReady: false,
      projectsCompleted: 0,
      mockInterviewDone: false,
      jobsApplied: 0,
      updatedAt: null,
    );
  }

  // ============================================================
  // GET MY COMPLETE PROGRESS
  // ============================================================

  Future<ProgressModel> getMyProgress({
    required String batchId,
    required String courseId,
  }) async {
    final String uid = _uid;

    final String requiredBatchId =
    batchId.trim();

    final String requiredCourseId =
    courseId.trim();

    double attendancePercentage = 0.0;
    double assignmentAverage = 0.0;

    int totalModules = 0;
    int completedModules = 0;

    // ==========================================================
    // ATTENDANCE
    // ==========================================================

    try {
      if (requiredBatchId.isEmpty) {
        debugPrint(
          'ATTENDANCE: batchId is empty.',
        );
      } else {
        final List attendanceRecords =
        await AttendanceService.instance
            .getMyAttendance(
          batchId: requiredBatchId,
        );

        attendancePercentage =
            AttendanceService.instance
                .calculatePercentage(
              attendanceRecords.cast(),
            );

        debugPrint(
          'Student UID: $uid',
        );

        debugPrint(
          'Progress batchId: $requiredBatchId',
        );

        debugPrint(
          'Student attendance: '
              '$attendancePercentage%',
        );
      }
    } catch (e) {
      debugPrint(
        'Attendance calculation failed: $e',
      );

      attendancePercentage = 0.0;
    }

    // ==========================================================
    // ASSIGNMENTS
    // ==========================================================

    try {
      if (requiredBatchId.isEmpty) {
        debugPrint(
          'ASSIGNMENTS: batchId is empty.',
        );
      } else {
        final QuerySnapshot<
            Map<String, dynamic>>
        snapshot =
        await _firestore
            .collection(
          CollectionNames.submissions,
        )
            .where(
          'studentId',
          isEqualTo: uid,
        )
            .where(
          'batchId',
          isEqualTo: requiredBatchId,
        )
            .get();

        double obtainedMarks = 0.0;
        double totalPossibleMarks = 0.0;

        debugPrint(
          'Total submissions found: '
              '${snapshot.docs.length}',
        );

        for (final submissionDoc
        in snapshot.docs) {
          final Map<String, dynamic> data =
          submissionDoc.data();

          final dynamic marksValue =
          data['marks'];

          if (marksValue == null) {
            debugPrint(
              'Submission ${submissionDoc.id}: '
                  'marks not available yet.',
            );
            continue;
          }

          double? marks;

          if (marksValue is num) {
            marks = marksValue.toDouble();
          } else if (marksValue is String) {
            marks = double.tryParse(
              marksValue,
            );
          }

          if (marks == null) {
            continue;
          }

          final String assignmentId =
              data['assignmentId']
                  ?.toString()
                  .trim() ??
                  '';

          if (assignmentId.isEmpty) {
            continue;
          }

          try {
            final DocumentSnapshot<
                Map<String, dynamic>>
            assignmentDoc =
            await _firestore
                .collection(
              CollectionNames.assignments,
            )
                .doc(assignmentId)
                .get();

            if (!assignmentDoc.exists) {
              debugPrint(
                'Assignment not found: '
                    '$assignmentId',
              );
              continue;
            }

            final Map<String, dynamic>?
            assignmentData =
            assignmentDoc.data();

            if (assignmentData == null) {
              continue;
            }

            final dynamic totalMarksValue =
            assignmentData['totalMarks'];

            double? totalMarks;

            if (totalMarksValue is num) {
              totalMarks =
                  totalMarksValue.toDouble();
            } else if (totalMarksValue is String) {
              totalMarks =
                  double.tryParse(
                    totalMarksValue,
                  );
            }

            if (totalMarks == null ||
                totalMarks <= 0) {
              continue;
            }

            final double safeMarks =
            marks.clamp(
              0.0,
              totalMarks,
            );

            obtainedMarks += safeMarks;
            totalPossibleMarks +=
                totalMarks;
          } catch (e) {
            debugPrint(
              'Could not load assignment '
                  '$assignmentId: $e',
            );
          }
        }

        if (totalPossibleMarks > 0) {
          assignmentAverage =
              (obtainedMarks /
                  totalPossibleMarks) *
                  100;

          assignmentAverage =
              assignmentAverage
                  .clamp(0.0, 100.0)
                  .toDouble();
        } else {
          assignmentAverage = 0.0;
        }

        debugPrint(
          'Assignment performance: '
              '$assignmentAverage%',
        );
      }
    } catch (e) {
      debugPrint(
        'Assignment calculation failed: $e',
      );

      assignmentAverage = 0.0;
    }

    // ==========================================================
    // COURSE MODULES
    // ==========================================================

    if (requiredCourseId.isNotEmpty) {
      // --------------------------------------------------------
      // TOTAL MODULES
      // --------------------------------------------------------

      try {
        final modules =
        await ModuleService.instance
            .getCourseModules(
          requiredCourseId,
        );

        totalModules = modules.length;

        debugPrint(
          'Course ID: $requiredCourseId',
        );

        debugPrint(
          'Total modules: $totalModules',
        );
      } catch (e) {
        debugPrint(
          'Course modules skipped: $e',
        );

        totalModules = 0;
      }

      // --------------------------------------------------------
      // COMPLETED MODULES
      // --------------------------------------------------------

      try {
        final moduleProgress =
        await ModuleService.instance
            .getMyModuleProgress(
          requiredCourseId,
        );

        completedModules =
            moduleProgress
                .where(
                  (item) => item.completed,
            )
                .length;

        if (totalModules > 0 &&
            completedModules >
                totalModules) {
          completedModules =
              totalModules;
        }

        debugPrint(
          'Completed modules: '
              '$completedModules/'
              '$totalModules',
        );
      } catch (e) {
        debugPrint(
          'Module progress skipped: $e',
        );

        completedModules = 0;
      }
    }

    // ==========================================================
    // CAREER PROGRESS
    // ==========================================================

    CareerProgressModel careerProgress;

    try {
      final CareerProgressModel?
      careerData =
      await CareerService.instance
          .getMyCareerProgress();

      careerProgress =
          careerData ??
              _defaultCareerProgress();
    } catch (e) {
      debugPrint(
        'Career progress skipped: $e',
      );

      careerProgress =
          _defaultCareerProgress();
    }

    // ==========================================================
    // FINAL DEBUG
    // ==========================================================

    debugPrint(
      '==========================================',
    );

    debugPrint(
      '       STUDENT PROGRESS COMPLETE',
    );

    debugPrint(
      '==========================================',
    );

    debugPrint(
      'Student UID: $uid',
    );

    debugPrint(
      'Batch ID: $requiredBatchId',
    );

    debugPrint(
      'Course ID: $requiredCourseId',
    );

    debugPrint(
      'Modules: '
          '$completedModules/$totalModules',
    );

    debugPrint(
      'Attendance: '
          '$attendancePercentage%',
    );

    debugPrint(
      'Assignments: '
          '$assignmentAverage%',
    );

    debugPrint(
      'Career: '
          '${careerProgress.readinessPercentage}%',
    );

    debugPrint(
      '==========================================',
    );

    // ==========================================================
    // RETURN PROGRESS MODEL
    // ==========================================================

    return ProgressModel(
      completedModules: completedModules,
      totalModules: totalModules,
      attendancePercentage:
      attendancePercentage,
      assignmentAverage:
      assignmentAverage,
      careerProgress:
      careerProgress,
    );
  }
}