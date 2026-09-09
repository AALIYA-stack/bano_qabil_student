import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionModel {
  final String id;
  final String assignmentId;
  final String studentId;
  final String batchId;
  final String answerText;
  final String? fileUrl;
  final String? fileName;
  final String status;
  final DateTime? submittedAt;
  final int? marks;
  final String? feedback;
  final DateTime? markedAt;
  final String? markedBy;

  const SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.batchId,
    required this.answerText,
    required this.fileUrl,
    required this.fileName,
    required this.status,
    required this.submittedAt,
    required this.marks,
    required this.feedback,
    required this.markedAt,
    required this.markedBy,
  });

  factory SubmissionModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    DateTime? submittedAt;
    DateTime? markedAt;

    final submittedValue =
    data['submittedAt'];

    final markedValue =
    data['markedAt'];

    if (submittedValue is Timestamp) {
      submittedAt =
          submittedValue.toDate();
    }

    if (markedValue is Timestamp) {
      markedAt =
          markedValue.toDate();
    }

    return SubmissionModel(
      id: doc.id,
      assignmentId:
      data['assignmentId']
          ?.toString() ??
          '',
      studentId:
      data['studentId']
          ?.toString() ??
          '',
      batchId:
      data['batchId']
          ?.toString() ??
          '',
      answerText:
      data['answerText']
          ?.toString() ??
          '',
      fileUrl:
      data['fileUrl']?.toString(),
      fileName:
      data['fileName']?.toString(),
      status:
      data['status']
          ?.toString() ??
          'submitted',
      submittedAt: submittedAt,
      marks:
      (data['marks'] as num?)
          ?.toInt(),
      feedback:
      data['feedback']?.toString(),
      markedAt: markedAt,
      markedBy:
      data['markedBy']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'assignmentId': assignmentId,
      'studentId': studentId,
      'batchId': batchId,
      'answerText': answerText,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'status': status,
      'submittedAt': submittedAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(
        submittedAt!,
      ),
      'marks': marks,
      'feedback': feedback,
      'markedAt': markedAt == null
          ? null
          : Timestamp.fromDate(
        markedAt!,
      ),
      'markedBy': markedBy,
    };
  }

  bool get isSubmitted {
    return status == 'submitted' ||
        status == 'marked' ||
        status == 'late';
  }

  bool get isMarked {
    return status == 'marked';
  }

  bool get isLate {
    return status == 'late';
  }
}