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

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>>
  get _submissions {
    return _firestore.collection(
      CollectionNames.submissions,
    );
  }

  Future<SubmissionModel?> getMySubmission(
      String assignmentId,
      ) async {
    final snapshot =
    await _submissions
        .where(
      'assignmentId',
      isEqualTo: assignmentId,
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

  Future<List<SubmissionModel>>
  getMySubmissions() async {
    final snapshot =
    await _submissions
        .where(
      'studentId',
      isEqualTo: _uid,
    )
        .get();

    final submissions =
    snapshot.docs
        .map(
          (doc) =>
          SubmissionModel
              .fromFirestore(
            doc,
          ),
    )
        .toList();

    submissions.sort((a, b) {
      final aDate = a.submittedAt;
      final bDate = b.submittedAt;

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
    });

    return submissions;
  }

  Future<String> uploadSubmissionFile({
    required String assignmentId,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final safeFileName =
    _sanitizeFileName(fileName);

    final storagePath =
        'submissions/'
        '$assignmentId/'
        '$_uid/'
        '$safeFileName';

    final reference =
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

  Future<String> submitAssignment({
    required AssignmentModel assignment,
    required String batchId,
    required String answerText,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final existingSubmission =
    await getMySubmission(
      assignment.id,
    );

    if (existingSubmission != null) {
      throw Exception(
        'You have already submitted this assignment.',
      );
    }

    if (answerText.trim().isEmpty &&
        fileBytes == null) {
      throw Exception(
        'Please provide an answer or upload a file.',
      );
    }

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
        assignmentId: assignment.id,
        fileBytes: fileBytes,
        fileName: fileName,
      );
    }

    final now = DateTime.now();

    final status =
    assignment.dueDate != null &&
        now.isAfter(
          assignment.dueDate!,
        )
        ? 'late'
        : 'submitted';

    final docRef =
    _submissions.doc();

    final submission =
    SubmissionModel(
      id: docRef.id,
      assignmentId: assignment.id,
      studentId: _uid,
      batchId: batchId,
      answerText: answerText.trim(),
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

  String _getContentType(
      String fileName,
      ) {
    final extension =
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