import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/collection_names.dart';
import '../models/course_model.dart';

class CourseService {
  CourseService._();

  static final CourseService instance = CourseService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<List<CourseModel>> getActiveCourses() async {
    final snapshot = await _firestore
        .collection(CollectionNames.courses)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => CourseModel.fromFirestore(doc),
    )
        .toList();
  }

  Future<CourseModel?> getCourseById(
      String courseId,
      ) async {
    final doc = await _firestore
        .collection(CollectionNames.courses)
        .doc(courseId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return CourseModel.fromFirestore(doc);
  }
}