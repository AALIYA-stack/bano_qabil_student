import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/collection_names.dart';

class CoordinatorService {
  CoordinatorService._();

  static final CoordinatorService instance =
  CoordinatorService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection(CollectionNames.applications);

  CollectionReference<Map<String, dynamic>> get _batches =>
      _firestore.collection(CollectionNames.batches);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(CollectionNames.users);

  CollectionReference<Map<String, dynamic>> get _courses =>
      _firestore.collection(CollectionNames.courses);

  CollectionReference<Map<String, dynamic>> get _campuses =>
      _firestore.collection(CollectionNames.campuses);

  CollectionReference<Map<String, dynamic>> get _notices =>
      _firestore.collection(CollectionNames.notices);

  // ============================================================
  // CURRENT USER
  // ============================================================

  String get currentUid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Coordinator is not logged in.');
    }

    return user.uid;
  }

  // ============================================================
  // APPLICATIONS STREAM
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
  watchApplications() {
    return _applications
        .orderBy(
      'createdAt',
      descending: true,
    )
        .snapshots();
  }

  // ============================================================
  // UPDATE APPLICATION STATUS
  // ============================================================

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? rejectionReason,
  }) async {
    final cleanStatus = status.trim().toLowerCase();

    if (applicationId.trim().isEmpty) {
      throw Exception('Application ID is missing.');
    }

    final applicationRef =
    _applications.doc(applicationId.trim());

    final applicationSnapshot =
    await applicationRef.get();

    if (!applicationSnapshot.exists) {
      throw Exception('Application was not found.');
    }

    final applicationData =
        applicationSnapshot.data() ?? {};

    final studentId =
        applicationData['studentId']?.toString() ?? '';

    final batchId =
        applicationData['batchId']?.toString() ?? '';

    final courseId =
        applicationData['courseId']?.toString() ?? '';

    final campusId =
        applicationData['campusId']?.toString() ?? '';

    final batch =
    _firestore.batch();

    final Map<String, dynamic> applicationUpdate = {
      'status': cleanStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (cleanStatus == 'rejected') {
      applicationUpdate['rejectionReason'] =
          rejectionReason?.trim() ?? 'Application rejected.';
    } else {
      applicationUpdate['rejectionReason'] = null;
    }

    batch.update(
      applicationRef,
      applicationUpdate,
    );

    // ----------------------------------------------------------
    // ACCEPTED STUDENT
    // ----------------------------------------------------------

    if (cleanStatus == 'accepted' &&
        studentId.isNotEmpty) {
      batch.set(
        _users.doc(studentId),
        {
          'courseId': courseId,
          'campus': campusId,
          'batchId': batchId,
          'role': 'student',
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // Update batch enrollment.
      if (batchId.isNotEmpty) {
        final batchRef = _batches.doc(batchId);

        final batchSnapshot =
        await batchRef.get();

        if (batchSnapshot.exists) {
          final data =
              batchSnapshot.data() ?? {};

          final enrolled =
          _toInt(data['enrolledStudents']);

          batch.update(
            batchRef,
            {
              'enrolledStudents': enrolled + 1,
            },
          );
        }
      }
    }

    await batch.commit();
  }

  // ============================================================
  // BATCHES STREAM
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
  watchBatches() {
    return _batches
        .orderBy(
      'startDate',
      descending: false,
    )
        .snapshots();
  }

  // ============================================================
  // CREATE BATCH
  // ============================================================

  Future<String> createBatch({
    required String courseId,
    required String campusId,
    required String instructorId,
    required String classDay,
    required String classTime,
    required String room,
    required DateTime startDate,
    required int seats,
  }) async {
    if (courseId.trim().isEmpty) {
      throw Exception('Please select a course.');
    }

    if (campusId.trim().isEmpty) {
      throw Exception('Please select a campus.');
    }

    if (classDay.trim().isEmpty) {
      throw Exception('Please enter class day.');
    }

    if (classTime.trim().isEmpty) {
      throw Exception('Please enter class time.');
    }

    if (room.trim().isEmpty) {
      throw Exception('Please enter room/lab.');
    }

    if (seats <= 0) {
      throw Exception('Seats must be greater than zero.');
    }

    final batchRef = _batches.doc();

    await batchRef.set({
      'courseId': courseId.trim(),
      'campusId': campusId.trim(),
      'instructorId': instructorId.trim(),
      'classDay': classDay.trim(),
      'classTime': classTime.trim(),
      'room': room.trim(),
      'startDate': Timestamp.fromDate(startDate),
      'seats': seats,
      'enrolledStudents': 0,
      'seatsLeft': seats,
      'isOpen': true,
      'createdBy': currentUid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return batchRef.id;
  }

  // ============================================================
  // OPEN / CLOSE BATCH
  // ============================================================

  Future<void> setBatchStatus({
    required String batchId,
    required bool isOpen,
  }) async {
    if (batchId.trim().isEmpty) {
      throw Exception('Batch ID is missing.');
    }

    await _batches.doc(batchId.trim()).update({
      'isOpen': isOpen,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // ASSIGN INSTRUCTOR
  // ============================================================

  Future<void> assignInstructor({
    required String batchId,
    required String instructorId,
  }) async {
    if (batchId.trim().isEmpty) {
      throw Exception('Batch ID is missing.');
    }

    if (instructorId.trim().isEmpty) {
      throw Exception('Please select an instructor.');
    }

    await _batches.doc(batchId.trim()).update({
      'instructorId': instructorId.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // INSTRUCTORS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
  watchInstructors() {
    return _users
        .where(
      'role',
      isEqualTo: 'instructor',
    )
        .snapshots();
  }

  // ============================================================
  // COURSES
  // ============================================================

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  getCourses() async {
    final snapshot =
    await _courses
        .where(
      'isActive',
      isEqualTo: true,
    )
        .get();

    return snapshot.docs;
  }

  // ============================================================
  // CAMPUSES
  // ============================================================

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  getCampuses() async {
    final snapshot =
    await _campuses
        .where(
      'isActive',
      isEqualTo: true,
    )
        .get();

    return snapshot.docs;
  }

  // ============================================================
  // REPORT
  // ============================================================

  Future<Map<String, int>> getReport() async {
    final applicationsSnapshot =
    await _applications.get();

    final usersSnapshot =
    await _users
        .where(
      'role',
      isEqualTo: 'student',
    )
        .get();

    final assignmentsSnapshot =
    await _firestore
        .collection(
      CollectionNames.assignments,
    )
        .get();

    final submissionsSnapshot =
    await _firestore
        .collection(
      CollectionNames.submissions,
    )
        .get();

    int accepted = 0;

    for (final doc
    in applicationsSnapshot.docs) {
      final status =
      doc.data()['status']
          ?.toString()
          .toLowerCase();

      if (status == 'accepted') {
        accepted++;
      }
    }

    final totalAssignments =
        assignmentsSnapshot.docs.length;

    final totalSubmissions =
        submissionsSnapshot.docs.length;

    final pendingAssignments =
        totalAssignments - totalSubmissions;

    return {
      'applications':
      applicationsSnapshot.docs.length,
      'accepted':
      accepted,
      'students':
      usersSnapshot.docs.length,
      'assignments':
      totalAssignments,
      'submissions':
      totalSubmissions,
      'pendingAssignments':
      pendingAssignments < 0
          ? 0
          : pendingAssignments,
    };
  }

  // ============================================================
  // POST CAMPUS NOTICE
  // ============================================================

  Future<void> createNotice({
    required String title,
    required String description,
    required String priority,
    String? campusId,
  }) async {
    if (title.trim().isEmpty) {
      throw Exception('Please enter notice title.');
    }

    if (description.trim().isEmpty) {
      throw Exception('Please enter notice description.');
    }

    await _notices.add({
      'title': title.trim(),
      'description': description.trim(),
      'type': 'general',
      'priority': priority.trim().toLowerCase(),
      'courseId': null,
      'batchId': null,
      'campusId':
      campusId?.trim().isEmpty == true
          ? null
          : campusId?.trim(),
      'createdBy': currentUid,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  // ============================================================
  // INTEGER HELPER
  // ============================================================

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }
}