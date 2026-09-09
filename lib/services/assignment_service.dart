import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/collection_names.dart';
import '../models/assignment_model.dart';

class AssignmentService {
  AssignmentService._();

  static final AssignmentService instance =
  AssignmentService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
  get _assignments {
    return _firestore.collection(
      CollectionNames.assignments,
    );
  }

  Future<List<AssignmentModel>>
  getAssignmentsForBatch(
      String batchId,
      ) async {
    if (batchId.trim().isEmpty) {
      return [];
    }

    final snapshot =
    await _assignments
        .where(
      'batchId',
      isEqualTo: batchId,
    )
        .get();

    final assignments =
    snapshot.docs
        .map(
          (doc) =>
          AssignmentModel
              .fromFirestore(doc),
    )
        .toList();

    assignments.sort((a, b) {
      final aDate = a.dueDate;
      final bDate = b.dueDate;

      if (aDate == null &&
          bDate == null) {
        return 0;
      }

      if (aDate == null) {
        return 1;
      }

      if (bDate == null) {
        return -1;
      }

      return aDate.compareTo(bDate);
    });

    return assignments;
  }

  Future<AssignmentModel?>
  getAssignmentById(
      String assignmentId,
      ) async {
    if (assignmentId.trim().isEmpty) {
      return null;
    }

    final doc =
    await _assignments
        .doc(assignmentId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return AssignmentModel.fromFirestore(
      doc,
    );
  }
}