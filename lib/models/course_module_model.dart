import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModuleModel {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final int order;
  final bool isActive;

  const CourseModuleModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.order,
    required this.isActive,
  });

  factory CourseModuleModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return CourseModuleModel(
      id: doc.id,
      courseId: data['courseId']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description:
      data['description']?.toString() ?? '',
      order:
      (data['order'] as num?)?.toInt() ?? 0,
      isActive:
      data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'courseId': courseId,
      'title': title,
      'description': description,
      'order': order,
      'isActive': isActive,
    };
  }
}