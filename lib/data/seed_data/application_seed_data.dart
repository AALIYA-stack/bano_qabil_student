import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationSeedData {
  ApplicationSeedData._();

  static const List<Map<String, dynamic>> applications = [
    {
      'id': 'application_001',
      'studentId': 'student_001',
      'fullName': 'Ali Raza',
      'cnic': '35202-1234567-1',
      'education': 'Intermediate',
      'city': 'Lahore',
      'courseId': 'flutter',
      'courseName': 'Flutter App Development',
      'campusId': 'lahore',
      'campusName': 'Lahore Campus',
      'batchId': 'flutter-batch-01',
      'whyJoin':
      'I want to learn Flutter development and build professional mobile applications.',
      'status': 'accepted',
      'rejectionReason': null,
    },
    {
      'id': 'application_002',
      'studentId': 'student_002',
      'fullName': 'Ayesha Khan',
      'cnic': '35202-2345678-2',
      'education': 'Bachelor',
      'city': 'Lahore',
      'courseId': 'graphic_design',
      'courseName': 'Graphic Design',
      'campusId': 'lahore',
      'campusName': 'Lahore Campus',
      'batchId': 'graphic_design_batch_01',
      'whyJoin':
      'I want to improve my graphic design skills and create professional designs.',
      'status': 'accepted',
      'rejectionReason': null,
    },
    {
      'id': 'application_003',
      'studentId': 'student_003',
      'fullName': 'Hamza Ahmed',
      'cnic': '35202-3456789-3',
      'education': 'Intermediate',
      'city': 'Lahore',
      'courseId': 'python',
      'courseName': 'Python Programming',
      'campusId': 'lahore',
      'campusName': 'Lahore Campus',
      'batchId': 'python_batch_01',
      'whyJoin':
      'I want to learn Python programming and improve my problem solving skills.',
      'status': 'submitted',
      'rejectionReason': null,
    },
    {
      'id': 'application_004',
      'studentId': 'student_004',
      'fullName': 'Fatima Noor',
      'cnic': '35202-4567890-4',
      'education': 'Bachelor',
      'city': 'Lahore',
      'courseId': 'web',
      'courseName': 'Web Development',
      'campusId': 'lahore',
      'campusName': 'Lahore Campus',
      'batchId': 'web_batch_01',
      'whyJoin':
      'I want to learn modern web development and build responsive websites.',
      'status': 'accepted',
      'rejectionReason': null,
    },
    {
      'id': 'application_005',
      'studentId': 'student_005',
      'fullName': 'Usman Tariq',
      'cnic': '35202-5678901-5',
      'education': 'Intermediate',
      'city': 'Lahore',
      'courseId': 'digital_marketing',
      'courseName': 'Digital Marketing',
      'campusId': 'lahore',
      'campusName': 'Lahore Campus',
      'batchId': '',
      'whyJoin':
      'I want to learn digital marketing and develop skills for online business.',
      'status': 'submitted',
      'rejectionReason': null,
    },
  ];

  static Map<String, dynamic> toFirestore(
      Map<String, dynamic> application,
      ) {
    final now = Timestamp.now();

    return {
      'studentId': application['studentId'],
      'fullName': application['fullName'],
      'cnic': application['cnic'],
      'education': application['education'],
      'city': application['city'],
      'courseId': application['courseId'],
      'courseName': application['courseName'],
      'campusId': application['campusId'],
      'campusName': application['campusName'],
      'batchId': application['batchId'],
      'whyJoin': application['whyJoin'],
      'status': application['status'],
      'rejectionReason': application['rejectionReason'],
      'createdAt': now,
      'updatedAt': now,
    };
  }
}