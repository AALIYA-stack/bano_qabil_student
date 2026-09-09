import 'package:cloud_firestore/cloud_firestore.dart';

class ModuleProgressModel {
  final String id;
  final String studentId;
  final String moduleId;
  final String courseId;
  final bool completed;
  final DateTime? completedAt;

  const ModuleProgressModel({
    required this.id,
    required this.studentId,
    required this.moduleId,
    required this.courseId,
    required this.completed,
    required this.completedAt,
  });

  factory ModuleProgressModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return ModuleProgressModel(
      id: doc.id,
      studentId:
      data['studentId']?.toString() ?? '',
      moduleId:
      data['moduleId']?.toString() ?? '',
      courseId:
      data['courseId']?.toString() ?? '',
      completed:
      data['completed'] as bool? ?? false,
      completedAt:
      (data['completedAt'] as Timestamp?)
          ?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'moduleId': moduleId,
      'courseId': courseId,
      'completed': completed,
      'completedAt': completedAt == null
          ? null
          : Timestamp.fromDate(completedAt!),
    };
  }
}