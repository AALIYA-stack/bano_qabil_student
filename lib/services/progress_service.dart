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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

    debugPrint('');
    debugPrint('==========================================');
    debugPrint('       PROGRESS SERVICE START');
    debugPrint('==========================================');
    debugPrint('UID: $uid');
    debugPrint('BATCH ID: $batchId');
    debugPrint('COURSE ID: $courseId');

    // ----------------------------------------------------------
    // 1. ATTENDANCE
    // ----------------------------------------------------------

    double attendancePercentage = 0.0;

    try {
      debugPrint('');
      debugPrint('1. Checking Firebase attendance...');

      final attendanceRecords =
      await AttendanceService.instance.getMyAttendance(
        batchId: batchId,
      );

      debugPrint(
        'Firebase attendance records: '
            '${attendanceRecords.length}',
      );

      final int present =
      AttendanceService.instance.countPresent(
        attendanceRecords,
      );

      final int late =
      AttendanceService.instance.countLate(
        attendanceRecords,
      );

      final int absent =
      AttendanceService.instance.countAbsent(
        attendanceRecords,
      );

      final int leave =
      AttendanceService.instance.countLeave(
        attendanceRecords,
      );

      debugPrint('Present: $present');
      debugPrint('Late: $late');
      debugPrint('Absent: $absent');
      debugPrint('Leave: $leave');
      debugPrint(
        'Total: ${attendanceRecords.length}',
      );

      attendancePercentage =
          AttendanceService.instance.calculatePercentage(
            attendanceRecords,
          );

      debugPrint(
        'FINAL ATTENDANCE: $attendancePercentage%',
      );
    } catch (e) {
      debugPrint(
        'Attendance skipped: $e',
      );

      attendancePercentage = 0.0;
    }

    // ----------------------------------------------------------
    // 2. SUBMISSIONS / ASSIGNMENTS
    // ----------------------------------------------------------

    double assignmentAverage = 0;

    try {
      debugPrint('');
      debugPrint('2. Checking submissions...');

      final snapshot = await _firestore
          .collection(CollectionNames.submissions)
          .where('studentId', isEqualTo: uid)
          .where('batchId', isEqualTo: batchId)
          .get();

      debugPrint(
        'Submission documents: ${snapshot.docs.length}',
      );

      final markedSubmissions = snapshot.docs.where((doc) {
        final marks = doc.data()['marks'];
        return marks is num;
      }).toList();

      if (markedSubmissions.isNotEmpty) {
        double totalMarks = 0;

        for (final doc in markedSubmissions) {
          final marks = doc.data()['marks'];

          if (marks is num) {
            totalMarks += marks.toDouble();
          }
        }

        assignmentAverage =
            totalMarks / markedSubmissions.length;
      }

      debugPrint(
        'Assignment average: $assignmentAverage',
      );
    } catch (e) {
      debugPrint('Submissions skipped: $e');

      assignmentAverage = 0;
    }

    // ----------------------------------------------------------
    // 3. COURSE MODULES
    // ----------------------------------------------------------

    int totalModules = 0;
    int completedModules = 0;

    if (courseId.trim().isNotEmpty) {
      try {
        debugPrint('');
        debugPrint('3. Checking course modules...');

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

      // --------------------------------------------------------
      // 4. MODULE PROGRESS
      // --------------------------------------------------------

      try {
        debugPrint('');
        debugPrint('4. Checking module progress...');

        final progress =
        await ModuleService.instance.getMyModuleProgress(
          courseId.trim(),
        );

        completedModules = progress
            .where((item) => item.completed)
            .length;

        if (totalModules > 0 &&
            completedModules > totalModules) {
          completedModules = totalModules;
        }

        debugPrint(
          'Completed modules: $completedModules',
        );
      } catch (e) {
        debugPrint(
          'Module progress skipped: $e',
        );

        completedModules = 0;
      }
    } else {
      debugPrint('Course ID is empty.');
    }

    // ----------------------------------------------------------
    // 5. CAREER PROGRESS
    // ----------------------------------------------------------

    CareerProgressModel careerProgress;

    try {
      debugPrint('');
      debugPrint('5. Checking career progress...');

      final careerData =
      await CareerService.instance.getMyCareerProgress();

      if (careerData != null) {
        careerProgress = careerData;

        debugPrint('Career progress found.');
      } else {
        careerProgress = CareerProgressModel(
          studentId: uid,
          cvReady: false,
          githubReady: false,
          projectsCompleted: 0,
          mockInterviewDone: false,
          jobsApplied: 0,
          updatedAt: null,
        );

        debugPrint(
          'Career progress document not found.',
        );
      }
    } catch (e) {
      debugPrint(
        'Career progress skipped: $e',
      );

      careerProgress = CareerProgressModel(
        studentId: uid,
        cvReady: false,
        githubReady: false,
        projectsCompleted: 0,
        mockInterviewDone: false,
        jobsApplied: 0,
        updatedAt: null,
      );
    }

    // ----------------------------------------------------------
    // FINAL RESULT
    // ----------------------------------------------------------

    debugPrint('');
    debugPrint('==========================================');
    debugPrint('       PROGRESS SERVICE COMPLETE');
    debugPrint('==========================================');
    debugPrint(
      'Modules: $completedModules / $totalModules',
    );
    debugPrint(
      'Attendance: $attendancePercentage%',
    );
    debugPrint(
      'Assignment Average: $assignmentAverage',
    );
    debugPrint('==========================================');

    return ProgressModel(
      completedModules: completedModules,
      totalModules: totalModules,
      attendancePercentage: attendancePercentage,
      assignmentAverage: assignmentAverage,
      careerProgress: careerProgress,
    );
  }
}