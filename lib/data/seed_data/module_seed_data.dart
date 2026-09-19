
// import 'package:cloud_firestore/cloud_firestore.dart';

class ModuleSeedData {
  ModuleSeedData._();

  static List<Map<String, dynamic>> get modules {
    return [
      {
        'id': 'module-01',
        'courseId': 'flutter',
        'title': 'Flutter Basics',
        'description': 'Introduction to Flutter and Dart basics.',
        'order': 1,
        'isActive': true,
      },
      {
        'id': 'module-02',
        'courseId': 'flutter',
        'title': 'Widgets and Layouts',
        'description': 'Learn Flutter widgets and responsive layouts.',
        'order': 2,
        'isActive': true,
      },
      {
        'id': 'module-03',
        'courseId': 'flutter',
        'title': 'Navigation and Firebase',
        'description': 'Learn navigation and Firebase integration.',
        'order': 3,
        'isActive': true,
      },
    ];
  }
}

