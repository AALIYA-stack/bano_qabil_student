import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final String priority;
  final String? courseId;
  final String? batchId;
  final String? campusId;
  final String createdBy;
  final DateTime? createdAt;
  final bool isActive;

  const NoticeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.courseId,
    required this.batchId,
    required this.campusId,
    required this.createdBy,
    required this.createdAt,
    required this.isActive,
  });

  factory NoticeModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    DateTime? parsedCreatedAt;

    final createdAtValue = data['createdAt'];

    if (createdAtValue is Timestamp) {
      parsedCreatedAt = createdAtValue.toDate();
    } else if (createdAtValue is DateTime) {
      parsedCreatedAt = createdAtValue;
    }

    String? cleanNullableString(
        dynamic value,
        ) {
      final String valueString =
          value?.toString().trim() ?? '';

      if (valueString.isEmpty) {
        return null;
      }

      return valueString;
    }

    return NoticeModel(
      id: doc.id,

      title:
      data['title']?.toString().trim() ?? '',

      description:
      data['description']?.toString().trim() ?? '',

      type:
      data['type']?.toString().trim().toLowerCase() ??
          'general',

      priority:
      data['priority']
          ?.toString()
          .trim()
          .toLowerCase() ??
          'normal',

      courseId:
      cleanNullableString(data['courseId']),

      batchId:
      cleanNullableString(data['batchId']),

      campusId:
      cleanNullableString(data['campusId']),

      createdBy:
      data['createdBy']?.toString().trim() ?? '',

      createdAt:
      parsedCreatedAt,

      isActive:
      data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'priority': priority,
      'courseId': courseId,
      'batchId': batchId,
      'campusId': campusId,
      'createdBy': createdBy,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'isActive': isActive,
    };
  }

  bool get isImportant {
    return priority.toLowerCase() == 'high' ||
        type.toLowerCase() == 'important';
  }
}