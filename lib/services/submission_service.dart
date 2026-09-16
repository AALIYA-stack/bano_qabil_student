import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../core/constants/collection_names.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';

class SubmissionService {
  SubmissionService._();

  static final SubmissionService instance =
  SubmissionService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  // ============================================================
  // CURRENT USER
  // ============================================================

  User get currentUser {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    return user;
  }

  String get _uid {
    return currentUser.uid;
  }

  // ============================================================
  // SUBMISSIONS COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
  get _submissions {
    return _firestore.collection(
      CollectionNames.submissions,
    );
  }

  // ============================================================
  // GET ONE SUBMISSION - STUDENT
  // ============================================================

  Future<SubmissionModel?> getMySubmission(
      String assignmentId,
      ) async {
    final String trimmedId =
    assignmentId.trim();

    if (trimmedId.isEmpty) {
      return null;
    }

    final QuerySnapshot<Map<String, dynamic>>
    snapshot = await _submissions
        .where(
      'assignmentId',
      isEqualTo: trimmedId,
    )
        .where(
      'studentId',
      isEqualTo: _uid,
    )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return SubmissionModel.fromFirestore(
      snapshot.docs.first,
    );
  }

  // ============================================================
  // GET ALL MY SUBMISSIONS - STUDENT
  // ============================================================

  Future<List<SubmissionModel>>
  getMySubmissions() async {
    final QuerySnapshot<Map<String, dynamic>>
    snapshot = await _submissions
        .where(
      'studentId',
      isEqualTo: _uid,
    )
        .get();

    final List<SubmissionModel>
    submissions = snapshot.docs
        .map(
          (doc) =>
          SubmissionModel.fromFirestore(doc),
    )
        .toList();

    submissions.sort(
          (a, b) {
        final DateTime? aDate =
            a.submittedAt;

        final DateTime? bDate =
            b.submittedAt;

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

        return bDate.compareTo(aDate);
      },
    );

    return submissions;
  }

  // ============================================================
  // GET SUBMISSIONS FOR BATCH - INSTRUCTOR
  // ============================================================

  Future<List<SubmissionModel>>
  getSubmissionsForBatch(
      String batchId,
      ) async {
    final String trimmedBatchId =
    batchId.trim();

    if (trimmedBatchId.isEmpty) {
      return <SubmissionModel>[];
    }

    final QuerySnapshot<Map<String, dynamic>>
    snapshot = await _submissions
        .where(
      'batchId',
      isEqualTo: trimmedBatchId,
    )
        .get();

    final List<SubmissionModel>
    submissions = snapshot.docs
        .map(
          (doc) =>
          SubmissionModel.fromFirestore(doc),
    )
        .toList();

    submissions.sort(
          (a, b) {
        final DateTime? aDate =
            a.submittedAt;

        final DateTime? bDate =
            b.submittedAt;

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

        return bDate.compareTo(aDate);
      },
    );

    return submissions;
  }

  // ============================================================
  // GET SUBMISSIONS FOR ASSIGNMENT - INSTRUCTOR
  // ============================================================

  Future<List<SubmissionModel>>
  getSubmissionsForAssignment(
      String assignmentId,
      ) async {
    final String trimmedAssignmentId =
    assignmentId.trim();

    if (trimmedAssignmentId.isEmpty) {
      return <SubmissionModel>[];
    }

    final QuerySnapshot<Map<String, dynamic>>
    snapshot = await _submissions
        .where(
      'assignmentId',
      isEqualTo: trimmedAssignmentId,
    )
        .get();

    final List<SubmissionModel>
    submissions = snapshot.docs
        .map(
          (doc) =>
          SubmissionModel.fromFirestore(doc),
    )
        .toList();

    submissions.sort(
          (a, b) {
        final DateTime? aDate =
            a.submittedAt;

        final DateTime? bDate =
            b.submittedAt;

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

        return bDate.compareTo(aDate);
      },
    );

    return submissions;
  }

  // ============================================================
  // GET ONE SUBMISSION BY ID - INSTRUCTOR
  // ============================================================

  Future<SubmissionModel?>
  getSubmissionById(
      String submissionId,
      ) async {
    final String trimmedId =
    submissionId.trim();

    if (trimmedId.isEmpty) {
      return null;
    }

    final DocumentSnapshot<
        Map<String, dynamic>>
    doc = await _submissions
        .doc(trimmedId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return SubmissionModel.fromFirestore(
      doc,
    );
  }

  // ============================================================
  // GET STUDENT SUBMISSIONS - INSTRUCTOR
  // ============================================================

  Future<List<SubmissionModel>>
  getSubmissionsForStudent(
      String studentId,
      ) async {
    final String trimmedStudentId =
    studentId.trim();

    if (trimmedStudentId.isEmpty) {
      return <SubmissionModel>[];
    }

    final QuerySnapshot<Map<String, dynamic>>
    snapshot = await _submissions
        .where(
      'studentId',
      isEqualTo: trimmedStudentId,
    )
        .get();

    final List<SubmissionModel>
    submissions = snapshot.docs
        .map(
          (doc) =>
          SubmissionModel.fromFirestore(doc),
    )
        .toList();

    submissions.sort(
          (a, b) {
        final DateTime? aDate =
            a.submittedAt;

        final DateTime? bDate =
            b.submittedAt;

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

        return bDate.compareTo(aDate);
      },
    );

    return submissions;
  }

  // ============================================================
  // MARK SUBMISSION - INSTRUCTOR
  // ============================================================

  Future<void> markSubmission({
    required String submissionId,
    required int marks,
    required String feedback,
  }) async {
    final String trimmedSubmissionId =
    submissionId.trim();

    if (trimmedSubmissionId.isEmpty) {
      throw Exception(
        'Invalid submission.',
      );
    }

    if (marks < 0) {
      throw Exception(
        'Marks cannot be negative.',
      );
    }

    final DocumentReference<
        Map<String, dynamic>>
    submissionRef =
    _submissions.doc(
      trimmedSubmissionId,
    );

    final DocumentSnapshot<
        Map<String, dynamic>>
    submissionSnapshot =
    await submissionRef.get();

    if (!submissionSnapshot.exists) {
      throw Exception(
        'Submission not found.',
      );
    }

    final Map<String, dynamic> data =
        submissionSnapshot.data() ??
            <String, dynamic>{};

    final String assignmentId =
        data['assignmentId']?.toString() ?? '';

    if (assignmentId.isEmpty) {
      throw Exception(
        'Assignment information is missing.',
      );
    }

    // ----------------------------------------------------------
    // GET ASSIGNMENT
    // ----------------------------------------------------------

    final DocumentSnapshot<
        Map<String, dynamic>>
    assignmentSnapshot =
    await _firestore
        .collection(
      CollectionNames.assignments,
    )
        .doc(assignmentId)
        .get();

    if (!assignmentSnapshot.exists) {
      throw Exception(
        'Assignment not found.',
      );
    }

    final AssignmentModel assignment =
    AssignmentModel.fromFirestore(
      assignmentSnapshot,
    );

    // ----------------------------------------------------------
    // VALIDATE MARKS
    // ----------------------------------------------------------

    if (marks > assignment.totalMarks) {
      throw Exception(
        'Marks cannot be greater than '
            '${assignment.totalMarks}.',
      );
    }

    // ----------------------------------------------------------
    // UPDATE SUBMISSION
    // ----------------------------------------------------------

    await submissionRef.update(
      <String, dynamic>{
        'marks': marks,
        'feedback':
        feedback.trim().isEmpty
            ? null
            : feedback.trim(),
        'status': 'marked',
        'markedAt':
        FieldValue.serverTimestamp(),
        'markedBy': _uid,
      },
    );
  }

  // ============================================================
  // UPDATE MARKS - INSTRUCTOR
  // ============================================================

  Future<void> updateMarks({
    required String submissionId,
    required int marks,
  }) async {
    final String trimmedSubmissionId =
    submissionId.trim();

    if (trimmedSubmissionId.isEmpty) {
      throw Exception(
        'Invalid submission.',
      );
    }

    if (marks < 0) {
      throw Exception(
        'Marks cannot be negative.',
      );
    }

    final DocumentReference<
        Map<String, dynamic>>
    submissionRef =
    _submissions.doc(
      trimmedSubmissionId,
    );

    final DocumentSnapshot<
        Map<String, dynamic>>
    submissionSnapshot =
    await submissionRef.get();

    if (!submissionSnapshot.exists) {
      throw Exception(
        'Submission not found.',
      );
    }

    final Map<String, dynamic> data =
        submissionSnapshot.data() ??
            <String, dynamic>{};

    final String assignmentId =
        data['assignmentId']?.toString() ?? '';

    if (assignmentId.isEmpty) {
      throw Exception(
        'Assignment information is missing.',
      );
    }

    final DocumentSnapshot<
        Map<String, dynamic>>
    assignmentSnapshot =
    await _firestore
        .collection(
      CollectionNames.assignments,
    )
        .doc(assignmentId)
        .get();

    if (!assignmentSnapshot.exists) {
      throw Exception(
        'Assignment not found.',
      );
    }

    final AssignmentModel assignment =
    AssignmentModel.fromFirestore(
      assignmentSnapshot,
    );

    if (marks > assignment.totalMarks) {
      throw Exception(
        'Marks cannot be greater than '
            '${assignment.totalMarks}.',
      );
    }

    await submissionRef.update(
      <String, dynamic>{
        'marks': marks,
        'status': 'marked',
        'markedAt':
        FieldValue.serverTimestamp(),
        'markedBy': _uid,
      },
    );
  }

  // ============================================================
  // UPDATE FEEDBACK - INSTRUCTOR
  // ============================================================

  Future<void> updateFeedback({
    required String submissionId,
    required String feedback,
  }) async {
    final String trimmedSubmissionId =
    submissionId.trim();

    if (trimmedSubmissionId.isEmpty) {
      throw Exception(
        'Invalid submission.',
      );
    }

    final DocumentReference<
        Map<String, dynamic>>
    submissionRef =
    _submissions.doc(
      trimmedSubmissionId,
    );

    final DocumentSnapshot<
        Map<String, dynamic>>
    submissionSnapshot =
    await submissionRef.get();

    if (!submissionSnapshot.exists) {
      throw Exception(
        'Submission not found.',
      );
    }

    final String trimmedFeedback =
    feedback.trim();

    await submissionRef.update(
      <String, dynamic>{
        'feedback':
        trimmedFeedback.isEmpty
            ? null
            : trimmedFeedback,
        'status': 'marked',
        'markedAt':
        FieldValue.serverTimestamp(),
        'markedBy': _uid,
      },
    );
  }

  // ============================================================
  // UPLOAD FILE TO FIREBASE STORAGE
  // ============================================================

  Future<String> uploadSubmissionFile({
    required String assignmentId,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    if (fileBytes.isEmpty) {
      throw Exception(
        'Selected file is empty.',
      );
    }

    final String safeFileName =
    _sanitizeFileName(fileName);

    final String storagePath =
        'submissions/'
        '$assignmentId/'
        '$_uid/'
        '${DateTime.now().millisecondsSinceEpoch}_'
        '$safeFileName';

    final Reference reference =
    _storage.ref().child(
      storagePath,
    );

    await reference.putData(
      fileBytes,
      SettableMetadata(
        contentType: _getContentType(
          safeFileName,
        ),
      ),
    );

    return reference.getDownloadURL();
  }

  // ============================================================
  // SUBMIT ASSIGNMENT - STUDENT
  // ============================================================

  Future<String> submitAssignment({
    required AssignmentModel assignment,
    required String batchId,
    required String answerText,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final String studentId = _uid;

    final String trimmedBatchId =
    batchId.trim();

    final String assignmentId =
    assignment.id.trim();

    if (assignmentId.isEmpty) {
      throw Exception(
        'Invalid assignment.',
      );
    }

    if (trimmedBatchId.isEmpty) {
      throw Exception(
        'Student batch is not assigned.',
      );
    }

    // ----------------------------------------------------------
    // CHECK EXISTING SUBMISSION
    // ----------------------------------------------------------

    final SubmissionModel? existing =
    await getMySubmission(
      assignmentId,
    );

    if (existing != null) {
      throw Exception(
        'You have already submitted this assignment.',
      );
    }

    // ----------------------------------------------------------
    // CHECK ANSWER
    // ----------------------------------------------------------

    final String trimmedAnswer =
    answerText.trim();

    if (trimmedAnswer.isEmpty &&
        fileBytes == null) {
      throw Exception(
        'Please write an answer or upload a file.',
      );
    }

    // ----------------------------------------------------------
    // UPLOAD FILE
    // ----------------------------------------------------------

    String? fileUrl;

    if (fileBytes != null) {
      final String selectedFileName =
          fileName?.trim() ?? '';

      if (selectedFileName.isEmpty) {
        throw Exception(
          'File name is required.',
        );
      }

      fileUrl =
      await uploadSubmissionFile(
        assignmentId: assignmentId,
        fileBytes: fileBytes,
        fileName: selectedFileName,
      );
    }

    // ----------------------------------------------------------
    // STATUS
    // ----------------------------------------------------------

    final DateTime now =
    DateTime.now();

    final bool isLate =
        assignment.dueDate != null &&
            now.isAfter(
              assignment.dueDate!,
            );

    final String status =
    isLate ? 'late' : 'submitted';

    // ----------------------------------------------------------
    // FIRESTORE DOCUMENT
    // ----------------------------------------------------------

    final DocumentReference<
        Map<String, dynamic>>
    docRef =
    _submissions.doc();

    final SubmissionModel submission =
    SubmissionModel(
      id: docRef.id,
      assignmentId: assignmentId,
      studentId: studentId,
      batchId: trimmedBatchId,
      answerText: trimmedAnswer,
      fileUrl: fileUrl,
      fileName: fileName?.trim(),
      status: status,
      submittedAt: now,
      marks: null,
      feedback: null,
      markedAt: null,
      markedBy: null,
    );

    await docRef.set(
      submission.toFirestore(),
    );

    return docRef.id;
  }

  // ============================================================
  // FILE NAME SANITIZATION
  // ============================================================

  String _sanitizeFileName(
      String fileName,
      ) {
    return fileName
        .trim()
        .replaceAll(
      RegExp(
        r'[^a-zA-Z0-9._-]',
      ),
      '_',
    );
  }

  // ============================================================
  // CONTENT TYPE
  // ============================================================

  String _getContentType(
      String fileName,
      ) {
    final String extension =
        fileName
            .toLowerCase()
            .split('.')
            .last;

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';

      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      case 'gif':
        return 'image/gif';

      case 'pdf':
        return 'application/pdf';

      case 'doc':
        return 'application/msword';

      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

      case 'ppt':
        return 'application/vnd.ms-powerpoint';

      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';

      case 'xls':
        return 'application/vnd.ms-excel';

      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

      case 'txt':
        return 'text/plain';

      case 'zip':
        return 'application/zip';

      default:
        return 'application/octet-stream';
    }
  }
}