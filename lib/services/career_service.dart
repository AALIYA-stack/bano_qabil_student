import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/collection_names.dart';
import '../models/career_progress_model.dart';

class CareerService {
  CareerService._();

  static final CareerService instance =
  CareerService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    return user.uid;
  }

  DocumentReference<Map<String, dynamic>>
  get _document {
    return _firestore
        .collection(
      CollectionNames.careerProgress,
    )
        .doc(_uid);
  }

  /// Get current student's career progress.
  Future<CareerProgressModel?>
  getMyCareerProgress() async {
    final snapshot =
    await _document.get();

    if (!snapshot.exists) {
      return null;
    }

    return CareerProgressModel
        .fromFirestore(snapshot);
  }

  /// Create or update complete career progress.
  Future<void> updateCareerProgress({
    required bool cvReady,
    required bool githubReady,
    required int projectsCompleted,
    required bool mockInterviewDone,
    required int jobsApplied,
  }) async {
    final safeProjects =
    projectsCompleted.clamp(0, 3);

    final safeJobs =
    jobsApplied < 0 ? 0 : jobsApplied;

    await _document.set(
      {
        'studentId': _uid,
        'cvReady': cvReady,
        'githubReady': githubReady,
        'projectsCompleted':
        safeProjects,
        'mockInterviewDone':
        mockInterviewDone,
        'jobsApplied':
        safeJobs,
        'updatedAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Update one career checklist item.
  Future<void> updateSingleItem({
    required String field,
    required dynamic value,
  }) async {
    final allowedFields = {
      'cvReady',
      'githubReady',
      'projectsCompleted',
      'mockInterviewDone',
      'jobsApplied',
    };

    if (!allowedFields.contains(field)) {
      throw Exception(
        'Invalid career progress field.',
      );
    }

    dynamic safeValue = value;

    if (field == 'cvReady' ||
        field == 'githubReady' ||
        field == 'mockInterviewDone') {
      if (value is! bool) {
        throw Exception(
          '$field must be true or false.',
        );
      }

      safeValue = value;
    }

    if (field == 'projectsCompleted') {
      if (value is! int) {
        throw Exception(
          'Projects completed must be a number.',
        );
      }

      safeValue =
          value.clamp(0, 3);
    }

    if (field == 'jobsApplied') {
      if (value is! int) {
        throw Exception(
          'Jobs applied must be a number.',
        );
      }

      safeValue =
      value < 0 ? 0 : value;
    }

    await _document.set(
      {
        'studentId': _uid,
        field: safeValue,
        'updatedAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Reset current student's career progress.
  Future<void> resetCareerProgress() async {
    await _document.set(
      {
        'studentId': _uid,
        'cvReady': false,
        'githubReady': false,
        'projectsCompleted': 0,
        'mockInterviewDone': false,
        'jobsApplied': 0,
        'updatedAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}