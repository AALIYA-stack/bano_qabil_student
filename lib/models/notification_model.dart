import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final String studentId;
  final bool isRead;
  final String? relatedId;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.studentId,
    required this.isRead,
    required this.relatedId,
    required this.createdAt,
  });

  factory AppNotification.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final Map<String, dynamic> data =
        doc.data() ?? <String, dynamic>{};

    DateTime? parsedCreatedAt;

    final dynamic createdAtValue =
    data['createdAt'];

    if (createdAtValue is Timestamp) {
      parsedCreatedAt =
          createdAtValue.toDate();
    } else if (createdAtValue is DateTime) {
      parsedCreatedAt = createdAtValue;
    } else if (createdAtValue is String) {
      parsedCreatedAt =
          DateTime.tryParse(createdAtValue);
    }

    return AppNotification(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      type: data['type']?.toString() ?? 'general',
      studentId:
      data['studentId']?.toString() ?? '',
      isRead: data['isRead'] == true,
      relatedId:
      data['relatedId']?.toString(),
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'studentId': studentId,
      'isRead': isRead,
      'relatedId': relatedId,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}