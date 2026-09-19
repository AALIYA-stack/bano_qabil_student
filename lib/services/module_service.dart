import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/collection_names.dart';
import '../models/course_module_model.dart';
import '../models/module_progress_model.dart';

class ModuleService {
  ModuleService._();

  static final ModuleService instance = ModuleService._();

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

  // ============================================================
  // GET COURSE MODULES
  // ============================================================

  Future<List<CourseModuleModel>> getCourseModules(
      String courseId,
      ) async {
    debugPrint('==========================================');
    debugPrint('MODULE QUERY START');
    debugPrint('MODULE QUERY COURSE ID = "$courseId"');
    debugPrint(
      'MODULE COLLECTION = "${CollectionNames.courseModules}"',
    );

    try {
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

      debugPrint(
        'MODULES FOUND = ${snapshot.docs.length}',
      );

      for (final doc in snapshot.docs) {
        debugPrint(
          'MODULE ID = ${doc.id}',
        );

        debugPrint(
          'MODULE DATA = ${doc.data()}',
        );
      }

      final modules = snapshot.docs
          .map(
            (doc) => CourseModuleModel.fromFirestore(doc),
      )
          .toList();

      modules.sort(
            (a, b) => a.order.compareTo(b.order),
      );

      debugPrint(
        'MODULES AFTER MODEL CONVERSION = ${modules.length}',
      );

      for (final module in modules) {
        debugPrint(
          'MODULE: ${module.id} | '
              'courseId: ${module.courseId} | '
              'title: ${module.title} | '
              'order: ${module.order} | '
              'isActive: ${module.isActive}',
        );
      }

      debugPrint('MODULE QUERY SUCCESS');
      debugPrint('==========================================');

      return modules;
    } catch (e, stackTrace) {
      debugPrint(
        'MODULE QUERY ERROR = $e',
      );

      debugPrint(
        'MODULE QUERY STACKTRACE = $stackTrace',
      );

      debugPrint('==========================================');

      rethrow;
    }
  }

  // ============================================================
  // GET MY MODULE PROGRESS
  // ============================================================

  Future<List<ModuleProgressModel>> getMyModuleProgress(
      String courseId,
      ) async {
    debugPrint('==========================================');
    debugPrint('MODULE PROGRESS QUERY START');
    debugPrint(
      'MODULE PROGRESS STUDENT UID = "$_uid"',
    );
    debugPrint(
      'MODULE PROGRESS COURSE ID = "$courseId"',
    );
    debugPrint(
      'MODULE PROGRESS COLLECTION = '
          '"${CollectionNames.moduleProgress}"',
    );

    try {
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

      debugPrint(
        'MODULE PROGRESS FOUND = ${snapshot.docs.length}',
      );

      for (final doc in snapshot.docs) {
        debugPrint(
          'PROGRESS ID = ${doc.id}',
        );

        debugPrint(
          'PROGRESS DATA = ${doc.data()}',
        );
      }

      final progress = snapshot.docs
          .map(
            (doc) => ModuleProgressModel.fromFirestore(doc),
      )
          .toList();

      debugPrint(
        'COMPLETED MODULE RECORDS = '
            '${progress.where((item) => item.completed).length}',
      );

      debugPrint('MODULE PROGRESS QUERY SUCCESS');
      debugPrint('==========================================');

      return progress;
    } catch (e, stackTrace) {
      debugPrint(
        'MODULE PROGRESS QUERY ERROR = $e',
      );

      debugPrint(
        'MODULE PROGRESS STACKTRACE = $stackTrace',
      );

      debugPrint('==========================================');

      rethrow;
    }
  }

  // ============================================================
  // MARK MODULE COMPLETED
  // ============================================================

  Future<void> markModuleCompleted({
    required String moduleId,
    required String courseId,
  }) async {
    debugPrint(
      'Marking module completed: '
          'moduleId=$moduleId, courseId=$courseId',
    );

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
        'completedAt': FieldValue.serverTimestamp(),
      });

      debugPrint(
        'Existing module progress updated.',
      );

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
      'completedAt': FieldValue.serverTimestamp(),
    });

    debugPrint(
      'New module progress created.',
    );
  }

  // ============================================================
  // MARK MODULE INCOMPLETE
  // ============================================================

  Future<void> markModuleIncomplete({
    required String moduleId,
  }) async {
    debugPrint(
      'Marking module incomplete: moduleId=$moduleId',
    );

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
      debugPrint(
        'No module progress record found.',
      );

      return;
    }

    await existing.docs.first.reference.update({
      'completed': false,
      'completedAt': null,
    });

    debugPrint(
      'Module marked incomplete.',
    );
  }
}