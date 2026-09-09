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

  Future<void> updateCareerProgress({
    required bool cvReady,
    required bool githubReady,
    required int projectsCompleted,
    required bool mockInterviewDone,
    required int jobsApplied,
  }) async {
    await _document.set(
      {
        'studentId': _uid,
        'cvReady': cvReady,
        'githubReady': githubReady,
        'projectsCompleted':
        projectsCompleted.clamp(0, 3),
        'mockInterviewDone':
        mockInterviewDone,
        'jobsApplied':
        jobsApplied < 0
            ? 0
            : jobsApplied,
        'updatedAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updateSingleItem({
    required String field,
    required dynamic value,
  }) async {
    await _document.set(
      {
        'studentId': _uid,
        field: value,
        'updatedAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}