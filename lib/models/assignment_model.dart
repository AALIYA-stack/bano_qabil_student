import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentModel {
  final String id;
  final String batchId;
  final String courseId;
  final String title;
  final String description;
  final String instructions;
  final DateTime? dueDate;
  final int totalMarks;
  final String createdBy;
  final DateTime? createdAt;
  final bool isQuiz;

  const AssignmentModel({
    required this.id,
    required this.batchId,
    required this.courseId,
    required this.title,
    required this.description,
    required this.instructions,
    required this.dueDate,
    required this.totalMarks,
    required this.createdBy,
    required this.createdAt,
    required this.isQuiz,
  });

  factory AssignmentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return AssignmentModel(
      id: doc.id,
      batchId: data['batchId']?.toString() ?? '',
      courseId: data['courseId']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      instructions: data['instructions']?.toString() ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      totalMarks: (data['totalMarks'] as num?)?.toInt() ?? 100,
      createdBy: data['createdBy']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isQuiz: data['isQuiz'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'batchId': batchId,
      'courseId': courseId,
      'title': title,
      'description': description,
      'instructions': instructions,
      'dueDate': dueDate == null
          ? null
          : Timestamp.fromDate(dueDate!),
      'totalMarks': totalMarks,
      'createdBy': createdBy,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'isQuiz': isQuiz,
    };
  }

  bool get isPastDue {
    if (dueDate == null) return false;

    return DateTime.now().isAfter(dueDate!);
  }
}