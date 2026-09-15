import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/collection_names.dart';
import '../models/application_model.dart';

class ApplicationService {
  ApplicationService._();

  static final ApplicationService instance =
  ApplicationService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // CURRENT USER ID
  // ============================================================

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  // ============================================================
  // APPLICATIONS COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
  get _applications {
    return _firestore.collection(
      CollectionNames.applications,
    );
  }

  // ============================================================
  // SUBMIT APPLICATION
  // ============================================================

  Future<String> submitApplication({
    required String fullName,
    required String cnic,
    required String education,
    required String city,
    required String courseId,
    required String courseName,
    required String campusId,
    required String campusName,
    required String batchId,
    required String whyJoin,
  }) async {
    final uid = _uid;

    final existingSnapshot = await _applications
        .where(
      'studentId',
      isEqualTo: uid,
    )
        .get();

    // Check duplicate batch locally.
    for (final doc in existingSnapshot.docs) {
      final data = doc.data();

      final existingBatchId =
          data['batchId']?.toString() ?? '';

      if (existingBatchId == batchId) {
        throw Exception(
          'You have already applied for this batch.',
        );
      }
    }

    final docRef = _applications.doc();

    final application = ApplicationModel(
      id: docRef.id,
      studentId: uid,
      fullName: fullName.trim(),
      cnic: cnic.trim(),
      education: education.trim(),
      city: city.trim(),
      courseId: courseId,
      courseName: courseName,
      campusId: campusId,
      campusName: campusName,
      batchId: batchId,
      whyJoin: whyJoin.trim(),
      status: 'submitted',
    );

    await docRef.set(
      application.toFirestore(),
    );

    return docRef.id;
  }

  // ============================================================
  // GET CURRENT STUDENT'S LATEST APPLICATION
  // ============================================================

  Future<ApplicationModel?> getMyApplication() async {
    final uid = _uid;

    final snapshot = await _applications
        .where(
      'studentId',
      isEqualTo: uid,
    )
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final applications = snapshot.docs
        .map(
          (doc) => ApplicationModel.fromFirestore(doc),
    )
        .toList();

    // Sort locally by createdAt.
    applications.sort((a, b) {
      final aDate = a.createdAt;
      final bDate = b.createdAt;

      if (aDate == null && bDate == null) {
        return 0;
      }

      if (aDate == null) {
        return 1;
      }

      if (bDate == null) {
        return -1;
      }

      return bDate.compareTo(aDate);
    });

    return applications.first;
  }

  // ============================================================
  // GET APPLICATION BY ID
  // ============================================================

  Future<ApplicationModel?> getApplicationById(
      String applicationId,
      ) async {
    final trimmedId = applicationId.trim();

    if (trimmedId.isEmpty) {
      return null;
    }

    final doc = await _applications
        .doc(trimmedId)
        .get();

    if (!doc.exists) {
      return null;
    }

    final application =
    ApplicationModel.fromFirestore(doc);

    if (application.studentId != _uid) {
      throw Exception(
        'You are not allowed to view this application.',
      );
    }

    return application;
  }
}