import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationSeedData {
  NotificationSeedData._();

  static List<Map<String, dynamic>> get notifications {
    return [
      {
        'id': 'notification_001',
        'title': 'Application Accepted',
        'message':
        'Congratulations! Your Flutter Development application has been accepted.',
        'type': 'application',
        'studentId': 'DEMO_STUDENT_UID',
        'isRead': false,
        'relatedId': 'application_001',
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'notification_002',
        'title': 'New Assignment',
        'message':
        'A new Flutter Login UI assignment has been added.',
        'type': 'assignment',
        'studentId': 'DEMO_STUDENT_UID',
        'isRead': false,
        'relatedId': 'assignment_001',
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'notification_003',
        'title': 'Marks Uploaded',
        'message':
        'Your Dart Fundamentals assignment has been marked.',
        'type': 'marks',
        'studentId': 'DEMO_STUDENT_UID',
        'isRead': true,
        'relatedId': 'assignment_002',
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'notification_004',
        'title': 'Class Timing Update',
        'message':
        'Tomorrow\'s Flutter class will start at 6:30 PM in Lab 02.',
        'type': 'class',
        'studentId': 'DEMO_STUDENT_UID',
        'isRead': false,
        'relatedId': null,
        'createdAt': Timestamp.now(),
      },
    ];
  }
}