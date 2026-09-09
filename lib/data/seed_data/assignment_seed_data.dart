import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentSeedData {
  AssignmentSeedData._();

  static List<Map<String, dynamic>> get assignments {
    return [
      {
        'id': 'assignment_flutter_ui_001',
        'batchId': 'flutter-lahore-01',
        'courseId': 'flutter-development',
        'title': 'Flutter Login UI',
        'description':
        'Create a professional login screen using Flutter and Material 3.',
        'instructions':
        'Create a responsive login screen with email, password, validation, '
            'show/hide password and a professional UI. Use reusable widgets where possible.',
        'dueDate': Timestamp.fromDate(
          DateTime(2026, 9, 15, 18, 0),
        ),
        'totalMarks': 100,
        'createdBy': 'demo_instructor_uid',
        'createdAt': Timestamp.now(),
        'isQuiz': false,
      },
      {
        'id': 'assignment_dart_002',
        'batchId': 'flutter-lahore-01',
        'courseId': 'flutter-development',
        'title': 'Dart Fundamentals',
        'description':
        'Practice variables, functions, collections and object-oriented programming in Dart.',
        'instructions':
        'Write Dart programs demonstrating variables, lists, maps, functions, '
            'classes and constructors. Submit your code with a short explanation.',
        'dueDate': Timestamp.fromDate(
          DateTime(2026, 9, 20, 18, 0),
        ),
        'totalMarks': 100,
        'createdBy': 'demo_instructor_uid',
        'createdAt': Timestamp.now(),
        'isQuiz': false,
      },
      {
        'id': 'assignment_firebase_003',
        'batchId': 'flutter-lahore-01',
        'courseId': 'flutter-development',
        'title': 'Firebase Integration',
        'description':
        'Connect a Flutter application with Firebase Authentication and Firestore.',
        'instructions':
        'Create a small Flutter application with Firebase Authentication. '
            'Store a user profile in Firestore and demonstrate reading the profile data.',
        'dueDate': Timestamp.fromDate(
          DateTime(2026, 9, 5, 18, 0),
        ),
        'totalMarks': 100,
        'createdBy': 'demo_instructor_uid',
        'createdAt': Timestamp.now(),
        'isQuiz': false,
      },
      {
        'id': 'assignment_final_004',
        'batchId': 'flutter-lahore-01',
        'courseId': 'flutter-development',
        'title': 'Flutter Mini Project',
        'description':
        'Build a small Flutter application demonstrating the concepts learned during the course.',
        'instructions':
        'Build a complete mini project with multiple screen, navigation, '
            'form validation, reusable widgets and clean UI. Explain your project briefly.',
        'dueDate': Timestamp.fromDate(
          DateTime(2026, 8, 30, 18, 0),
        ),
        'totalMarks': 100,
        'createdBy': 'demo_instructor_uid',
        'createdAt': Timestamp.now(),
        'isQuiz': false,
      },
    ];
  }
}