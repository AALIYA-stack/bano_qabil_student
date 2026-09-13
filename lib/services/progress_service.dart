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

  static final ProgressService instance = ProgressService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  // ============================================================
  // GET MY COMPLETE PROGRESS
  // ============================================================

  Future<ProgressModel> getMyProgress({
    required String batchId,
    required String courseId,
  }) async {
    final uid = _uid;

    double attendancePercentage = 0.0;

    double assignmentAverage = 0.0;

    int totalModules = 0;
    int completedModules = 0;

    // ============================================================
    // 1. ATTENDANCE
    // ============================================================

    try {
      final attendanceRecords =
      await AttendanceService.instance.getMyAttendance(
        batchId: batchId,
      );

      attendancePercentage =
          AttendanceService.instance.calculatePercentage(
            attendanceRecords,
          );

      debugPrint(
        'Student attendance: $attendancePercentage%',
      );
    } catch (e) {
      debugPrint(
        'Attendance skipped: $e',
      );

      attendancePercentage = 0.0;
    }

    // ============================================================
    // 2. ASSIGNMENT PERFORMANCE
    // ============================================================
    //
    // Correct formula:
    //
    // Total obtained marks
    // -------------------- x 100
    // Total possible marks
    //
    // Example:
    // 80/100 + 15/20
    // = 95/120
    // = 79.17%
    //
    // ============================================================

    try {
      final snapshot = await _firestore
          .collection(
        CollectionNames.submissions,
      )
          .where(
        'studentId',
        isEqualTo: uid,
      )
          .where(
        'batchId',
        isEqualTo: batchId,
      )
          .get();

      double obtainedMarks = 0.0;
      double totalPossibleMarks = 0.0;

      for (final submissionDoc in snapshot.docs) {
        final data = submissionDoc.data();

        final marksValue = data['marks'];

        if (marksValue == null) {
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

        final assignmentId =
            data['assignmentId']?.toString().trim() ?? '';

        if (assignmentId.isEmpty) {
          continue;
        }

        try {
          final assignmentDoc = await _firestore
              .collection(
            CollectionNames.assignments,
          )
              .doc(assignmentId)
              .get();

          if (!assignmentDoc.exists) {
            continue;
          }

          final assignmentData =
          assignmentDoc.data();

          if (assignmentData == null) {
            continue;
          }

          final totalMarksValue =
          assignmentData['totalMarks'];

          double? totalMarks;

          if (totalMarksValue is num) {
            totalMarks =
                totalMarksValue.toDouble();
          } else if (totalMarksValue is String) {
            totalMarks =
                double.tryParse(totalMarksValue);
          }

          if (totalMarks == null ||
              totalMarks <= 0) {
            continue;
          }

          obtainedMarks += marks.clamp(
            0,
            totalMarks,
          );

          totalPossibleMarks += totalMarks;
        } catch (e) {
          debugPrint(
            'Could not load assignment '
                '$assignmentId: $e',
          );
        }
      }

      if (totalPossibleMarks > 0) {
        assignmentAverage =
            (obtainedMarks / totalPossibleMarks) *
                100;

        assignmentAverage =
            assignmentAverage.clamp(0, 100);
      }

      debugPrint(
        'Assignment performance: '
            '$assignmentAverage%',
      );
    } catch (e) {
      debugPrint(
        'Assignment calculation skipped: $e',
      );

      assignmentAverage = 0.0;
    }

    // ============================================================
    // 3. COURSE MODULES
    // ============================================================

    if (courseId.trim().isNotEmpty) {
      try {
        final modules =
        await ModuleService.instance.getCourseModules(
          courseId.trim(),
        );

        totalModules = modules.length;

        debugPrint(
          'Total modules: $totalModules',
        );
      } catch (e) {
        debugPrint(
          'Course modules skipped: $e',
        );

        totalModules = 0;
      }

      // ==========================================================
      // 4. MODULE PROGRESS
      // ==========================================================

      try {
        final moduleProgress =
        await ModuleService.instance
            .getMyModuleProgress(
          courseId.trim(),
        );

        completedModules =
            moduleProgress
                .where(
                  (item) => item.completed,
            )
                .length;

        if (totalModules > 0 &&
            completedModules > totalModules) {
          completedModules = totalModules;
        }

        debugPrint(
          'Completed modules: '
              '$completedModules/$totalModules',
        );
      } catch (e) {
        debugPrint(
          'Module progress skipped: $e',
        );

        completedModules = 0;
      }
    }

    // ============================================================
    // 5. CAREER READINESS
    // ============================================================

    CareerProgressModel careerProgress;

    try {
      final careerData =
      await CareerService.instance
          .getMyCareerProgress();

      careerProgress =
          careerData ??
              CareerProgressModel(
                studentId: uid,
                cvReady: false,
                githubReady: false,
                projectsCompleted: 0,
                mockInterviewDone: false,
                jobsApplied: 0,
                updatedAt: null,
              );
    } catch (e) {
      debugPrint(
        'Career progress skipped: $e',
      );

      careerProgress =
          CareerProgressModel(
            studentId: uid,
            cvReady: false,
            githubReady: false,
            projectsCompleted: 0,
            mockInterviewDone: false,
            jobsApplied: 0,
            updatedAt: null,
          );
    }

    // ============================================================
    // FINAL
    // ============================================================

    debugPrint('');
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
      'Modules: $completedModules/$totalModules',
    );
    debugPrint(
      'Attendance: $attendancePercentage%',
    );
    debugPrint(
      'Assignments: $assignmentAverage%',
    );
    debugPrint(
      'Career: '
          '${careerProgress.readinessPercentage}%',
    );
    debugPrint(
      '==========================================',
    );

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