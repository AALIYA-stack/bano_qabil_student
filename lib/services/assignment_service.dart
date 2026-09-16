
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/collection_names.dart';
import '../models/assignment_model.dart';

class AssignmentService {
  AssignmentService._();

  static final AssignmentService instance =
      AssignmentService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // ASSIGNMENTS COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
  get _assignments {
    return _firestore.collection(
      CollectionNames.assignments,
    );
  }

  // ============================================================
  // ============================================================
  // CREATE ASSIGNMENT
  // ============================================================

  Future<String> createAssignment(
      AssignmentModel assignment,
      ) async {
    final doc = await _assignments.add(
      assignment.toFirestore(),
    );

    return doc.id;
  }

  // ============================================================
  // GET ASSIGNMENTS FOR BATCH
  // ============================================================
  Future<List<AssignmentModel>>
  getAssignmentsForBatch(
      String batchId,
      ) async {
    final String trimmedBatchId =
    batchId.trim();

    if (trimmedBatchId.isEmpty) {
      return [];
    }

    final QuerySnapshot<
        Map<String, dynamic>> snapshot =
    await _assignments
        .where(
      'batchId',
      isEqualTo: trimmedBatchId,
    )
        .get();

    final List<AssignmentModel> assignments =
    snapshot.docs
        .map(
          (doc) =>
          AssignmentModel.fromFirestore(
            doc,
          ),
    )
        .toList();

    // Newest due date / nearest due date first
    assignments.sort(
          (a, b) {
        final DateTime? aDate =
            a.dueDate;

        final DateTime? bDate =
            b.dueDate;

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
      },
    );

    return assignments;
  }

  // ============================================================
  // GET SINGLE ASSIGNMENT
  // ============================================================

  Future<AssignmentModel?>
  getAssignmentById(
      String assignmentId,
      ) async {
    final String trimmedId =
    assignmentId.trim();

    if (trimmedId.isEmpty) {
      return null;
    }

    final DocumentSnapshot<
        Map<String, dynamic>> doc =
    await _assignments
        .doc(trimmedId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return AssignmentModel.fromFirestore(
      doc,
    );
  }
}

