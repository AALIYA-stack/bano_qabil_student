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
  // CURRENT USER UID
  // ============================================================

  String get _uid {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    return user.uid;
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
  // GET MY SUBMISSION FOR ONE ASSIGNMENT
  // ============================================================

  Future<SubmissionModel?> getMySubmission(
      String assignmentId,
      ) async {
    final String trimmedId =
    assignmentId.trim();

    if (trimmedId.isEmpty) {
      return null;
    }

    final QuerySnapshot<
        Map<String, dynamic>> snapshot =
    await _submissions
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
  // GET ALL MY SUBMISSIONS
  // ============================================================

  Future<List<SubmissionModel>>
  getMySubmissions() async {
    final QuerySnapshot<
        Map<String, dynamic>> snapshot =
    await _submissions
        .where(
      'studentId',
      isEqualTo: _uid,
    )
        .get();

    final List<SubmissionModel>
    submissions =
    snapshot.docs
        .map(
          (doc) =>
          SubmissionModel.fromFirestore(
            doc,
          ),
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
  // UPLOAD SUBMISSION FILE
  // ============================================================

  Future<String> uploadSubmissionFile({
    required String assignmentId,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final String safeFileName =
    _sanitizeFileName(fileName);

    final String storagePath =
        'submissions/'
        '$assignmentId/'
        '$_uid/'
        '$safeFileName';

    final Reference reference =
    _storage.ref().child(
      storagePath,
    );

    await reference.putData(
      fileBytes,
      SettableMetadata(
        contentType:
        _getContentType(
          safeFileName,
        ),
      ),
    );

    return reference.getDownloadURL();
  }

  // ============================================================
  // SUBMIT ASSIGNMENT
  // ============================================================

  Future<String> submitAssignment({
    required AssignmentModel assignment,
    required String batchId,
    required String answerText,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    // ----------------------------------------------------------
    // CHECK LOGIN
    // ----------------------------------------------------------

    final String studentId = _uid;

    // ----------------------------------------------------------
    // CHECK BATCH
    // ----------------------------------------------------------

    if (batchId.trim().isEmpty) {
      throw Exception(
        'Student batch is not assigned.',
      );
    }

    // ----------------------------------------------------------
    // CHECK DUPLICATE SUBMISSION
    // ----------------------------------------------------------

    final SubmissionModel?
    existingSubmission =
    await getMySubmission(
      assignment.id,
    );

    if (existingSubmission != null) {
      throw Exception(
        'You have already submitted this assignment.',
      );
    }

    // ----------------------------------------------------------
    // CHECK ANSWER / FILE
    // ----------------------------------------------------------

    final String trimmedAnswer =
    answerText.trim();

    if (trimmedAnswer.isEmpty &&
        fileBytes == null) {
      throw Exception(
        'Please provide an answer or upload a file.',
      );
    }

    // ----------------------------------------------------------
    // UPLOAD FILE
    // ----------------------------------------------------------

    String? fileUrl;

    if (fileBytes != null) {
      if (fileName == null ||
          fileName.trim().isEmpty) {
        throw Exception(
          'File name is required.',
        );
      }

      fileUrl =
      await uploadSubmissionFile(
        assignmentId:
        assignment.id,
        fileBytes: fileBytes,
        fileName: fileName,
      );
    }

    // ----------------------------------------------------------
    // STATUS
    // ----------------------------------------------------------

    final DateTime now =
    DateTime.now();

    final String status =
    assignment.dueDate != null &&
        now.isAfter(
          assignment.dueDate!,
        )
        ? 'late'
        : 'submitted';

    // ----------------------------------------------------------
    // CREATE FIRESTORE DOCUMENT
    // ----------------------------------------------------------

    final DocumentReference<
        Map<String, dynamic>> docRef =
    _submissions.doc();

    final SubmissionModel submission =
    SubmissionModel(
      id: docRef.id,
      assignmentId: assignment.id,
      studentId: studentId,
      batchId: batchId.trim(),
      answerText: trimmedAnswer,
      fileUrl: fileUrl,
      fileName: fileName,
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
  // FILE NAME
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

      case 'pdf':
        return 'application/pdf';

      case 'doc':
        return 'application/msword';

      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

      case 'txt':
        return 'text/plain';

      default:
        return 'application/octet-stream';
    }
  }
}