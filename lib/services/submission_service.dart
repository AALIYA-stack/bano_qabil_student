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

  User get _currentUser {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    return user;
  }

  String get _uid {
    return _currentUser.uid;
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
  // GET ONE SUBMISSION
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
  // GET ALL MY SUBMISSIONS
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

    final List<SubmissionModel> submissions =
    snapshot.docs
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
    _storage.ref().child(storagePath);

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
  // SUBMIT ASSIGNMENT
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
        Map<String, dynamic>> docRef =
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