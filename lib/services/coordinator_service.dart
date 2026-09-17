import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/collection_names.dart';
import '../models/application_model.dart';
import '../models/batch_model.dart';
import '../models/coordinator_report_model.dart';
import '../models/notice_model.dart';

/// Coordinator-only Firestore operations: reviewing applications,
/// managing batches, assigning instructors, posting notices, and
/// building the monthly report.
///
/// Reuses the same models, collection names, and error-handling
/// convention (throw Exception, strip 'Exception: ' on display)
/// as the rest of the app.
class CoordinatorService {
  CoordinatorService._();

  static final CoordinatorService instance =
      CoordinatorService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>>
  get _applications =>
      _firestore.collection(CollectionNames.applications);

  CollectionReference<Map<String, dynamic>> get _batches =>
      _firestore.collection(CollectionNames.batches);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(CollectionNames.users);

  CollectionReference<Map<String, dynamic>> get _notices =>
      _firestore.collection(CollectionNames.notices);

  CollectionReference<Map<String, dynamic>>
  get _submissions =>
      _firestore.collection(CollectionNames.submissions);

  CollectionReference<Map<String, dynamic>>
  get _attendance =>
      _firestore.collection(CollectionNames.attendance);

  // ============================================================
  // APPLICATIONS INBOX
  // ============================================================

  /// Real-time stream of applications, optionally filtered by
  /// [statusFilter] (one of ApplicationModel's status strings, or
  /// null / 'all' for every application). Newest first.
  Stream<List<ApplicationModel>> applicationsStream({
    String? statusFilter,
  }) {
    Query<Map<String, dynamic>> query = _applications;

    if (statusFilter != null && statusFilter != 'all') {
      query = query.where('status', isEqualTo: statusFilter);
    }

    return query.snapshots().map((snapshot) {
      final applications = snapshot.docs
          .map((doc) => ApplicationModel.fromFirestore(doc))
          .toList();

      applications.sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return bDate.compareTo(aDate);
      });

      return applications;
    });
  }

  /// Moves an application to [newStatus]. Pass [reason] when
  /// waitlisting or rejecting — stored as `rejectionReason` per the
  /// existing ApplicationModel field, shown to the student.
  Future<void> decideApplication({
    required String applicationId,
    required String newStatus,
    String? reason,
  }) async {
    const validStatuses = {
      'submitted',
      'under_review',
      'interview_test',
      'accepted',
      'rejected',
      'waiting_list',
    };

    if (!validStatuses.contains(newStatus)) {
      throw Exception('Invalid application status.');
    }

    await _applications.doc(applicationId).update({
      'status': newStatus,
      'rejectionReason':
          (newStatus == 'rejected' || newStatus == 'waiting_list')
              ? reason?.trim()
              : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Notify the student.
    final appDoc = await _applications.doc(applicationId).get();
    final appData = appDoc.data();

    if (appData != null) {
      final studentId = appData['studentId']?.toString() ?? '';

      if (studentId.isNotEmpty) {
        await _firestore
            .collection(CollectionNames.notifications)
            .add({
          'title': 'Application update',
          'message': _statusMessage(newStatus),
          'type': 'application',
          'studentId': studentId,
          'isRead': false,
          'relatedId': applicationId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  String _statusMessage(String status) {
    switch (status) {
      case 'under_review':
        return 'Your application is now under review.';
      case 'interview_test':
        return 'You have been shortlisted for an interview / test.';
      case 'accepted':
        return 'Congratulations! Your application has been accepted.';
      case 'waiting_list':
        return 'You have been placed on the waiting list.';
      case 'rejected':
        return 'Your application was not accepted this time.';
      default:
        return 'Your application status has been updated.';
    }
  }

  // ============================================================
  // BATCHES
  // ============================================================

  Stream<List<BatchModel>> batchesStream() {
    return _batches.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BatchModel.fromFirestore(doc))
          .toList()
        ..sort((a, b) => (a.startDate ?? DateTime(2100))
            .compareTo(b.startDate ?? DateTime(2100)));
    });
  }

  /// Creates a new batch. [id] should be a short readable slug
  /// (e.g. "flutter-lahore-02") consistent with the seed data.
  Future<void> createBatch({
    required String id,
    required BatchModel batch,
  }) async {
    final existing = await _batches.doc(id).get();

    if (existing.exists) {
      throw Exception('A batch with this ID already exists.');
    }

    await _batches.doc(id).set(batch.toFirestore());
  }

  Future<void> closeBatch(String batchId) async {
    await _batches.doc(batchId).update({'isOpen': false});
  }

  Future<void> reopenBatch(String batchId) async {
    await _batches.doc(batchId).update({'isOpen': true});
  }

  Future<void> assignInstructor({
    required String batchId,
    required String instructorId,
  }) async {
    await _batches.doc(batchId).update({
      'instructorId': instructorId,
    });
  }

  /// Instructors available to assign, from `users` where role ==
  /// 'instructor'.
  Future<List<InstructorOption>> getInstructors() async {
    final snapshot = await _users
        .where('role', isEqualTo: 'instructor')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return InstructorOption(
        uid: doc.id,
        name: data['name']?.toString() ?? 'Instructor',
        email: data['email']?.toString() ?? '',
      );
    }).toList();
  }

  // ============================================================
  // NOTICES
  // ============================================================

  /// Posts a campus-wide (or app-wide, when [campusId] is null)
  /// notice using the shared NoticeModel/collection students and
  /// instructors already read from.
  Future<void> postNotice({
    required String title,
    required String description,
    String type = 'general',
    String priority = 'normal',
    String? campusId,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedDescription = description.trim();

    if (trimmedTitle.isEmpty) {
      throw Exception('Notice title is required.');
    }

    if (trimmedDescription.isEmpty) {
      throw Exception('Notice description is required.');
    }

    final notice = NoticeModel(
      id: '',
      title: trimmedTitle,
      description: trimmedDescription,
      type: type,
      priority: priority,
      courseId: null,
      batchId: null,
      campusId: (campusId != null && campusId.trim().isNotEmpty)
          ? campusId.trim()
          : null,
      createdBy: _uid,
      createdAt: DateTime.now(),
      isActive: true,
    );

    await _notices.add(notice.toFirestore());
  }

  // ============================================================
  // SEED DEMO DATA
  // ============================================================

  /// One-tap seed: courses, campuses, batches, and sample
  /// applications. Safe to run repeatedly (uses merge sets / fixed
  /// IDs so it will not duplicate documents).
  Future<void> seedDemoData() async {
    final courses = <String, Map<String, dynamic>>{
      'flutter': {
        'name': 'Flutter App Development',
        'description':
            'Build cross-platform mobile apps with Flutter and Dart.',
        'level': 'Beginner',
        'duration': '12 weeks',
        'totalSeats': 30,
        'seatsFilled': 12,
        'isActive': true,
      },
      'web': {
        'name': 'Web Development',
        'description': 'HTML, CSS, JavaScript and modern frameworks.',
        'level': 'Beginner',
        'duration': '10 weeks',
        'totalSeats': 30,
        'seatsFilled': 5,
        'isActive': true,
      },
      'python': {
        'name': 'Python Programming',
        'description': 'Programming fundamentals with Python.',
        'level': 'Beginner',
        'duration': '8 weeks',
        'totalSeats': 30,
        'seatsFilled': 3,
        'isActive': true,
      },
      'graphic_design': {
        'name': 'Graphic Design',
        'description': 'Design fundamentals with industry tools.',
        'level': 'Beginner',
        'duration': '8 weeks',
        'totalSeats': 25,
        'seatsFilled': 4,
        'isActive': true,
      },
      'digital_marketing': {
        'name': 'Digital Marketing',
        'description': 'SEO, social media and online campaigns.',
        'level': 'Beginner',
        'duration': '6 weeks',
        'totalSeats': 25,
        'seatsFilled': 2,
        'isActive': true,
      },
      'cybersecurity': {
        'name': 'Cybersecurity Fundamentals',
        'description': 'Security basics, networking and best practice.',
        'level': 'Intermediate',
        'duration': '10 weeks',
        'totalSeats': 25,
        'seatsFilled': 0,
        'isActive': true,
      },
    };

    final campuses = <String, Map<String, dynamic>>{
      'lahore': {
        'name': 'Lahore Campus',
        'city': 'Lahore',
        'province': 'Punjab',
        'address': 'Bano Qabil Center, Lahore',
        'phone': '042-1234567',
        'isActive': true,
      },
      'karachi': {
        'name': 'Karachi Campus',
        'city': 'Karachi',
        'province': 'Sindh',
        'address': 'Bano Qabil Center, Karachi',
        'phone': '021-1234567',
        'isActive': true,
      },
      'islamabad': {
        'name': 'Islamabad Campus',
        'city': 'Islamabad',
        'province': 'Islamabad',
        'address': 'Bano Qabil Center, Islamabad',
        'phone': '051-1234567',
        'isActive': true,
      },
      'peshawar': {
        'name': 'Peshawar Campus',
        'city': 'Peshawar',
        'province': 'KP',
        'address': 'Bano Qabil Center, Peshawar',
        'phone': '091-1234567',
        'isActive': true,
      },
      'quetta': {
        'name': 'Quetta Campus',
        'city': 'Quetta',
        'province': 'Balochistan',
        'address': 'Bano Qabil Center, Quetta',
        'phone': '081-1234567',
        'isActive': true,
      },
      'multan': {
        'name': 'Multan Campus',
        'city': 'Multan',
        'province': 'Punjab',
        'address': 'Bano Qabil Center, Multan',
        'phone': '061-1234567',
        'isActive': true,
      },
      'gilgit': {
        'name': 'Gilgit Campus',
        'city': 'Gilgit',
        'province': 'GB',
        'address': 'Bano Qabil Center, Gilgit',
        'phone': '05811-234567',
        'isActive': true,
      },
      'muzaffarabad': {
        'name': 'Muzaffarabad Campus',
        'city': 'Muzaffarabad',
        'province': 'AJK',
        'address': 'Bano Qabil Center, Muzaffarabad',
        'phone': '05822-34567',
        'isActive': true,
      },
    };

    final batches = <String, Map<String, dynamic>>{
      'flutter-batch-01': {
        'courseId': 'flutter',
        'campusId': 'lahore',
        'instructorId': '',
        'classDay': 'Mon, Wed, Fri',
        'classTime': '6:00 PM - 8:00 PM',
        'room': 'Lab 2',
        'startDate': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 14)),
        ),
        'seats': 30,
        'enrolledStudents': 12,
        'isOpen': true,
      },
      'web_batch_01': {
        'courseId': 'web',
        'campusId': 'lahore',
        'instructorId': '',
        'classDay': 'Tue, Thu',
        'classTime': '5:00 PM - 7:00 PM',
        'room': 'Lab 1',
        'startDate': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 7)),
        ),
        'seats': 30,
        'enrolledStudents': 5,
        'isOpen': true,
      },
      'python_batch_01': {
        'courseId': 'python',
        'campusId': 'karachi',
        'instructorId': '',
        'classDay': 'Mon, Wed',
        'classTime': '4:00 PM - 6:00 PM',
        'room': 'Lab 3',
        'startDate': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 3)),
        ),
        'seats': 30,
        'enrolledStudents': 3,
        'isOpen': true,
      },
      'graphic_design_batch_01': {
        'courseId': 'graphic_design',
        'campusId': 'islamabad',
        'instructorId': '',
        'classDay': 'Sat, Sun',
        'classTime': '11:00 AM - 1:00 PM',
        'room': 'Design Studio',
        'startDate': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 10)),
        ),
        'seats': 25,
        'enrolledStudents': 4,
        'isOpen': true,
      },
    };

    final batch = _firestore.batch();

    courses.forEach((id, data) {
      batch.set(
        _firestore.collection(CollectionNames.courses).doc(id),
        data,
        SetOptions(merge: true),
      );
    });

    campuses.forEach((id, data) {
      batch.set(
        _firestore.collection(CollectionNames.campuses).doc(id),
        data,
        SetOptions(merge: true),
      );
    });

    batches.forEach((id, data) {
      batch.set(_batches.doc(id), data, SetOptions(merge: true));
    });

    await batch.commit();
  }

  // ============================================================
  // REPORT
  // ============================================================

  Future<CoordinatorReportModel> getMonthlyReport() async {
    final now = DateTime.now();

    // ---------------------------------------------------------
    // APPLICATIONS
    // ---------------------------------------------------------

    final applicationsSnapshot = await _applications.get();

    int applicationsThisMonth = 0;
    int acceptedStudents = 0;

    for (final doc in applicationsSnapshot.docs) {
      final application = ApplicationModel.fromFirestore(doc);

      final createdAt = application.createdAt;

      if (createdAt != null &&
          createdAt.year == now.year &&
          createdAt.month == now.month) {
        applicationsThisMonth++;
      }

      if (application.isAccepted) {
        acceptedStudents++;
      }
    }

    // ---------------------------------------------------------
    // ATTENDANCE (average across every batch)
    // ---------------------------------------------------------

    final attendanceSnapshot = await _attendance.get();

    double averageAttendancePercent = 0;

    if (attendanceSnapshot.docs.isNotEmpty) {
      int attended = 0;

      for (final doc in attendanceSnapshot.docs) {
        final status =
            (doc.data()['status']?.toString() ?? '').toLowerCase();

        if (status == 'present' || status == 'late') {
          attended++;
        }
      }

      averageAttendancePercent =
          (attended / attendanceSnapshot.docs.length) * 100;
    }

    // ---------------------------------------------------------
    // ASSIGNMENTS PENDING REVIEW (submitted but not yet marked)
    // ---------------------------------------------------------

    final submissionsSnapshot = await _submissions.get();

    final assignmentsPendingReview = submissionsSnapshot.docs
        .where((doc) => doc.data()['marks'] == null)
        .length;

    return CoordinatorReportModel(
      applicationsThisMonth: applicationsThisMonth,
      acceptedStudents: acceptedStudents,
      averageAttendancePercent:
          averageAttendancePercent.clamp(0, 100).toDouble(),
      assignmentsPendingReview: assignmentsPendingReview,
    );
  }
}