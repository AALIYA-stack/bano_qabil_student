import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String studentId;
  final String fullName;
  final String cnic;
  final String education;
  final String city;
  final String courseId;
  final String courseName;
  final String campusId;
  final String campusName;
  final String batchId;
  final String whyJoin;
  final String status;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ApplicationModel({
    required this.id,
    required this.studentId,
    required this.fullName,
    required this.cnic,
    required this.education,
    required this.city,
    required this.courseId,
    required this.courseName,
    required this.campusId,
    required this.campusName,
    required this.batchId,
    required this.whyJoin,
    required this.status,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================================
  // FIRESTORE -> MODEL
  // ============================================================

  factory ApplicationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    DateTime? createdAt;
    DateTime? updatedAt;

    final createdAtValue = data['createdAt'];
    final updatedAtValue = data['updatedAt'];

    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    }

    if (updatedAtValue is Timestamp) {
      updatedAt = updatedAtValue.toDate();
    }

    return ApplicationModel(
      id: doc.id,
      studentId:
      data['studentId']?.toString() ?? '',
      fullName:
      data['fullName']?.toString() ?? '',
      cnic:
      data['cnic']?.toString() ?? '',
      education:
      data['education']?.toString() ?? '',
      city:
      data['city']?.toString() ?? '',
      courseId:
      data['courseId']?.toString() ?? '',
      courseName:
      data['courseName']?.toString() ?? '',
      campusId:
      data['campusId']?.toString() ?? '',
      campusName:
      data['campusName']?.toString() ?? '',
      batchId:
      data['batchId']?.toString() ?? '',
      whyJoin:
      data['whyJoin']?.toString() ?? '',
      status:
      data['status']?.toString() ?? 'submitted',
      rejectionReason:
      data['rejectionReason']?.toString(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // ============================================================
  // MODEL -> FIRESTORE
  // ============================================================

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'fullName': fullName,
      'cnic': cnic,
      'education': education,
      'city': city,
      'courseId': courseId,
      'courseName': courseName,
      'campusId': campusId,
      'campusName': campusName,
      'batchId': batchId,
      'whyJoin': whyJoin,
      'status': status,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  bool get isSubmitted {
    return status.toLowerCase() == 'submitted';
  }

  bool get isUnderReview {
    return status.toLowerCase() == 'under_review';
  }

  bool get isInterviewTest {
    return status.toLowerCase() == 'interview_test';
  }

  bool get isAccepted {
    return status.toLowerCase() == 'accepted';
  }

  bool get isRejected {
    return status.toLowerCase() == 'rejected';
  }

  bool get isWaitingList {
    return status.toLowerCase() == 'waiting_list';
  }
}