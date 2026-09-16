import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/collection_names.dart';
import '../models/assignment_model.dart';

class AssignmentService {
  AssignmentService._();

  static final AssignmentService instance =
  AssignmentService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // ASSIGNMENTS COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>> get _assignments {
    return _firestore.collection(
      CollectionNames.assignments,
    );
  }

  // ============================================================
  // GET CURRENT USER ID
  // ============================================================

  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  // ============================================================
  // GET ASSIGNMENTS FOR BATCH
  // ============================================================

  Future<List<AssignmentModel>> getAssignmentsForBatch(
      String batchId,
      ) async {
    final String trimmedBatchId = batchId.trim();

    if (trimmedBatchId.isEmpty) {
      return [];
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await _assignments
        .where(
      'batchId',
      isEqualTo: trimmedBatchId,
    )
        .get();

    final List<AssignmentModel> assignments =
    snapshot.docs
        .map(
          (doc) => AssignmentModel.fromFirestore(doc),
    )
        .toList();

    // Nearest due date first
    assignments.sort(
          (a, b) {
        final DateTime? aDate = a.dueDate;
        final DateTime? bDate = b.dueDate;

        if (aDate == null && bDate == null) {
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

  Future<AssignmentModel?> getAssignmentById(
      String assignmentId,
      ) async {
    final String trimmedId = assignmentId.trim();

    if (trimmedId.isEmpty) {
      return null;
    }

    final DocumentSnapshot<Map<String, dynamic>> doc =
    await _assignments
        .doc(trimmedId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return AssignmentModel.fromFirestore(doc);
  }

  // ============================================================
  // CREATE ASSIGNMENT
  // ============================================================

  Future<String> createAssignment({
    required String batchId,
    required String courseId,
    required String title,
    required String description,
    required String instructions,
    required DateTime dueDate,
    required int totalMarks,
    bool isQuiz = false,
  }) async {
    final String? instructorId = currentUserId;

    if (instructorId == null) {
      throw Exception(
        'Instructor login required.',
      );
    }

    final String cleanBatchId = batchId.trim();
    final String cleanCourseId = courseId.trim();
    final String cleanTitle = title.trim();
    final String cleanDescription =
    description.trim();
    final String cleanInstructions =
    instructions.trim();

    if (cleanBatchId.isEmpty) {
      throw Exception(
        'Batch ID is missing.',
      );
    }

    if (cleanCourseId.isEmpty) {
      throw Exception(
        'Course ID is missing.',
      );
    }

    if (cleanTitle.isEmpty) {
      throw Exception(
        'Assignment title is required.',
      );
    }

    if (totalMarks <= 0) {
      throw Exception(
        'Total marks must be greater than 0.',
      );
    }

    final DocumentReference<Map<String, dynamic>>
    docRef = _assignments.doc();

    final AssignmentModel assignment =
    AssignmentModel(
      id: docRef.id,
      batchId: cleanBatchId,
      courseId: cleanCourseId,
      title: cleanTitle,
      description: cleanDescription,
      instructions: cleanInstructions,
      dueDate: dueDate,
      totalMarks: totalMarks,
      createdBy: instructorId,
      createdAt: DateTime.now(),
      isQuiz: isQuiz,
    );

    await docRef.set(
      assignment.toFirestore(),
    );

    return docRef.id;
  }

  // ============================================================
  // DELETE ASSIGNMENT
  // ============================================================

  Future<void> deleteAssignment(
      String assignmentId,
      ) async {
    final String? instructorId = currentUserId;

    if (instructorId == null) {
      throw Exception(
        'Instructor login required.',
      );
    }

    final String cleanId = assignmentId.trim();

    if (cleanId.isEmpty) {
      throw Exception(
        'Assignment ID is missing.',
      );
    }

    final DocumentSnapshot<Map<String, dynamic>>
    doc = await _assignments
        .doc(cleanId)
        .get();

    if (!doc.exists) {
      throw Exception(
        'Assignment not found.',
      );
    }

    final Map<String, dynamic> data =
        doc.data() ?? {};

    final String createdBy =
        data['createdBy']?.toString() ?? '';

    if (createdBy != instructorId) {
      throw Exception(
        'You can only delete your own assignments.',
      );
    }

    await _assignments
        .doc(cleanId)
        .delete();
  }
}