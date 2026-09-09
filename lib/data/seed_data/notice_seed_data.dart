import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeSeedData {
  NoticeSeedData._();

  static List<Map<String, dynamic>> get notices {
    return [
      {
        'id': 'notice_001',
        'title': 'Flutter Class Update',
        'description':
        'Tomorrow\'s Flutter class will start at 6:30 PM in Lab 02.',
        'type': 'class',
        'priority': 'high',
        'courseId': 'flutter-development',
        'batchId': 'flutter-lahore-01',
        'campusId': 'lahore-campus',
        'createdBy': 'demo_admin_uid',
        'createdAt': Timestamp.now(),
        'isActive': true,
      },
      {
        'id': 'notice_002',
        'title': 'Assignment Reminder',
        'description':
        'Please submit your Dart Fundamentals assignment before the due date.',
        'type': 'assignment',
        'priority': 'normal',
        'courseId': 'flutter-development',
        'batchId': 'flutter-lahore-01',
        'campusId': 'lahore-campus',
        'createdBy': 'demo_instructor_uid',
        'createdAt': Timestamp.now(),
        'isActive': true,
      },
      {
        'id': 'notice_003',
        'title': 'Campus Announcement',
        'description':
        'Students are requested to arrive at campus at least 10 minutes before class.',
        'type': 'general',
        'priority': 'normal',
        'courseId': null,
        'batchId': null,
        'campusId': 'lahore-campus',
        'createdBy': 'demo_admin_uid',
        'createdAt': Timestamp.now(),
        'isActive': true,
      },
      {
        'id': 'notice_004',
        'title': 'Important Student Notice',
        'description':
        'Keep your student information updated in your profile.',
        'type': 'important',
        'priority': 'high',
        'courseId': null,
        'batchId': null,
        'campusId': null,
        'createdBy': 'demo_admin_uid',
        'createdAt': Timestamp.now(),
        'isActive': true,
      },
    ];
  }
}