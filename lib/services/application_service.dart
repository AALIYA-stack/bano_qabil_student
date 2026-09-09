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

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

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

    // Prevent duplicate application
    // for the same batch.
    final existing = await _applications
        .where(
      'studentId',
      isEqualTo: uid,
    )
        .where(
      'batchId',
      isEqualTo: batchId,
    )
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception(
        'You have already applied for this batch.',
      );
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
        .orderBy(
      'createdAt',
      descending: true,
    )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return ApplicationModel.fromFirestore(
      snapshot.docs.first,
    );
  }

  // ============================================================
  // GET APPLICATION BY ID
  // ============================================================

  Future<ApplicationModel?> getApplicationById(
      String applicationId,
      ) async {
    if (applicationId.trim().isEmpty) {
      return null;
    }

    final doc = await _applications
        .doc(applicationId)
        .get();

    if (!doc.exists) {
      return null;
    }

    final application =
    ApplicationModel.fromFirestore(doc);

    // Student can only view their own application.
    if (application.studentId != _uid) {
      throw Exception(
        'You are not allowed to view this application.',
      );
    }

    return application;
  }
}