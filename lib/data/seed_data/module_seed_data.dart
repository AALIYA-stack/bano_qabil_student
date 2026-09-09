import 'package:cloud_firestore/cloud_firestore.dart';

class ModuleSeedData {
  ModuleSeedData._();

  static List<Map<String, dynamic>> get modules {
    return [
      {
        'id': 'flutter-module-001',
        'courseId': 'flutter-development',
        'title': 'Dart Fundamentals',
        'description':
        'Variables, data types, functions and collections.',
        'order': 1,
        'isActive': true,
      },
      {
        'id': 'flutter-module-002',
        'courseId': 'flutter-development',
        'title': 'Object Oriented Programming',
        'description':
        'Classes, objects, constructors and inheritance.',
        'order': 2,
        'isActive': true,
      },
      {
        'id': 'flutter-module-003',
        'courseId': 'flutter-development',
        'title': 'Flutter UI Development',
        'description':
        'Widgets, layouts, themes and responsive interfaces.',
        'order': 3,
        'isActive': true,
      },
      {
        'id': 'flutter-module-004',
        'courseId': 'flutter-development',
        'title': 'Navigation and Forms',
        'description':
        'Navigation, forms and input validation.',
        'order': 4,
        'isActive': true,
      },
      {
        'id': 'flutter-module-005',
        'courseId': 'flutter-development',
        'title': 'Firebase Integration',
        'description':
        'Authentication, Firestore and Firebase Storage.',
        'order': 5,
        'isActive': true,
      },
      {
        'id': 'flutter-module-006',
        'courseId': 'flutter-development',
        'title': 'Final Mini Project',
        'description':
        'Build and present a complete Flutter application.',
        'order': 6,
        'isActive': true,
      },
    ];
  }
}