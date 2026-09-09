import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/collection_names.dart';
import '../models/course_module_model.dart';
import '../models/module_progress_model.dart';

class ModuleService {
  ModuleService._();

  static final ModuleService instance =
  ModuleService._();

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

  Future<List<CourseModuleModel>> getCourseModules(
      String courseId,
      ) async {
    final snapshot = await _firestore
        .collection(
      CollectionNames.courseModules,
    )
        .where(
      'courseId',
      isEqualTo: courseId,
    )
        .where(
      'isActive',
      isEqualTo: true,
    )
        .get();

    final modules = snapshot.docs
        .map(
          (doc) =>
          CourseModuleModel.fromFirestore(doc),
    )
        .toList();

    modules.sort(
          (a, b) => a.order.compareTo(b.order),
    );

    return modules;
  }

  Future<List<ModuleProgressModel>>
  getMyModuleProgress(
      String courseId,
      ) async {
    final snapshot = await _firestore
        .collection(
      CollectionNames.moduleProgress,
    )
        .where(
      'studentId',
      isEqualTo: _uid,
    )
        .where(
      'courseId',
      isEqualTo: courseId,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) =>
          ModuleProgressModel
              .fromFirestore(doc),
    )
        .toList();
  }

  Future<void> markModuleCompleted({
    required String moduleId,
    required String courseId,
  }) async {
    final existing = await _firestore
        .collection(
      CollectionNames.moduleProgress,
    )
        .where(
      'studentId',
      isEqualTo: _uid,
    )
        .where(
      'moduleId',
      isEqualTo: moduleId,
    )
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update({
        'completed': true,
        'completedAt':
        FieldValue.serverTimestamp(),
      });

      return;
    }

    await _firestore
        .collection(
      CollectionNames.moduleProgress,
    )
        .add({
      'studentId': _uid,
      'moduleId': moduleId,
      'courseId': courseId,
      'completed': true,
      'completedAt':
      FieldValue.serverTimestamp(),
    });
  }

  Future<void> markModuleIncomplete({
    required String moduleId,
  }) async {
    final existing = await _firestore
        .collection(
      CollectionNames.moduleProgress,
    )
        .where(
      'studentId',
      isEqualTo: _uid,
    )
        .where(
      'moduleId',
      isEqualTo: moduleId,
    )
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      return;
    }

    await existing.docs.first.reference.update({
      'completed': false,
      'completedAt': null,
    });
  }
}