import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/collection_names.dart';
import '../models/application_model.dart';
import '../models/notification_model.dart';

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
  // NOTIFICATIONS COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
  get _notifications {
    return _firestore.collection(
      CollectionNames.notifications,
    );
  }

  // ============================================================
  // CHECK WHETHER STATUS IS ACTIVE
  // ============================================================

  bool _isActiveStatus(String status) {
    final normalizedStatus =
    status.trim().toLowerCase();

    return normalizedStatus == 'submitted' ||
        normalizedStatus == 'under_review' ||
        normalizedStatus == 'interview_test' ||
        normalizedStatus == 'accepted' ||
        normalizedStatus == 'waiting_list';
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

    debugPrint('');
    debugPrint('==========================================');
    debugPrint('APPLICATION SUBMISSION START');
    debugPrint('==========================================');

    debugPrint('STUDENT UID: $uid');
    debugPrint('FULL NAME: ${fullName.trim()}');
    debugPrint('COURSE ID: ${courseId.trim()}');
    debugPrint('COURSE NAME: ${courseName.trim()}');
    debugPrint('CAMPUS ID: ${campusId.trim()}');
    debugPrint('CAMPUS NAME: ${campusName.trim()}');
    debugPrint('BATCH ID: ${batchId.trim()}');

    // ==========================================================
    // GET ALL APPLICATIONS OF CURRENT STUDENT
    // ==========================================================

    debugPrint('CHECKING EXISTING APPLICATIONS...');

    final existingSnapshot = await _applications
        .where(
      'studentId',
      isEqualTo: uid,
    )
        .get();

    debugPrint(
      'EXISTING APPLICATIONS: '
          '${existingSnapshot.docs.length}',
    );

    // ==========================================================
    // CHECK EXISTING APPLICATIONS
    // ==========================================================

    for (final doc in existingSnapshot.docs) {
      final data = doc.data();

      final status =
          data['status']
              ?.toString()
              .trim()
              .toLowerCase() ??
              '';

      final existingBatchId =
          data['batchId']
              ?.toString()
              .trim() ??
              '';

      final existingCourseId =
          data['courseId']
              ?.toString()
              .trim() ??
              '';

      debugPrint(
        'EXISTING APPLICATION => '
            'id=${doc.id} | '
            'course=$existingCourseId | '
            'batch=$existingBatchId | '
            'status=$status',
      );

      // ========================================================
      // ACTIVE APPLICATION
      // ========================================================

      if (_isActiveStatus(status)) {
        // ------------------------------------------------------
        // SAME BATCH
        // ------------------------------------------------------

        if (existingBatchId == batchId.trim()) {
          throw Exception(
            'You have already applied for this batch.',
          );
        }

        // ------------------------------------------------------
        // DIFFERENT COURSE / BATCH
        // ------------------------------------------------------

        throw Exception(
          'You already have an active application. '
              'You can apply for another course after your '
              'current application is rejected.',
        );
      }

      // ========================================================
      // REJECTED APPLICATION
      // ========================================================

      if (status == 'rejected') {
        debugPrint(
          'Previous application rejected. '
              'New application is allowed.',
        );
      }
    }

    // ==========================================================
    // CREATE NEW APPLICATION
    // ==========================================================

    final docRef = _applications.doc();

    final application = ApplicationModel(
      id: docRef.id,
      studentId: uid,
      fullName: fullName.trim(),
      cnic: cnic.trim(),
      education: education.trim(),
      city: city.trim(),
      courseId: courseId.trim(),
      courseName: courseName.trim(),
      campusId: campusId.trim(),
      campusName: campusName.trim(),
      batchId: batchId.trim(),
      whyJoin: whyJoin.trim(),
      status: 'submitted',
    );

    debugPrint(
      'CREATING APPLICATION DOCUMENT...',
    );

    await docRef.set(
      application.toFirestore(),
    );

    debugPrint(
      'APPLICATION DOCUMENT CREATED.',
    );

    // ==========================================================
    // CREATE SUBMISSION NOTIFICATION
    // ==========================================================

    debugPrint(
      'CREATING APPLICATION SUBMISSION NOTIFICATION...',
    );

    try {
      await _createApplicationSubmittedNotification(
        studentId: uid,
        courseName: courseName.trim(),
        applicationId: docRef.id,
      );

      debugPrint(
        'APPLICATION SUBMISSION NOTIFICATION CREATED.',
      );
    } catch (notificationError, notificationStack) {
      // --------------------------------------------------------
      // IMPORTANT:
      // Application is already submitted.
      // Notification failure should NOT make the application
      // look like it failed.
      // --------------------------------------------------------

      debugPrint(
        'NOTIFICATION CREATION FAILED.',
      );

      debugPrint(
        'NOTIFICATION ERROR: $notificationError',
      );

      debugPrint(
        'NOTIFICATION STACK: $notificationStack',
      );
    }

    // ==========================================================
    // SUCCESS LOG
    // ==========================================================

    debugPrint('');
    debugPrint('========================================');
    debugPrint('APPLICATION SUBMITTED SUCCESSFULLY');
    debugPrint('Application ID: ${docRef.id}');
    debugPrint('Student UID: $uid');
    debugPrint(
      'Course ID: ${courseId.trim()}',
    );
    debugPrint(
      'Course Name: ${courseName.trim()}',
    );
    debugPrint(
      'Campus ID: ${campusId.trim()}',
    );
    debugPrint(
      'Campus Name: ${campusName.trim()}',
    );
    debugPrint(
      'Batch ID: ${batchId.trim()}',
    );
    debugPrint('Status: submitted');
    debugPrint('Notification: created');
    debugPrint('========================================');
    debugPrint('');

    return docRef.id;
  }

  // ============================================================
  // CREATE APPLICATION SUBMITTED NOTIFICATION
  // ============================================================

  Future<void> _createApplicationSubmittedNotification({
    required String studentId,
    required String courseName,
    required String applicationId,
  }) async {
    final cleanStudentId = studentId.trim();

    if (cleanStudentId.isEmpty) {
      throw Exception(
        'Cannot create notification because studentId is empty.',
      );
    }

    final cleanCourseName =
    courseName.trim().isEmpty
        ? 'selected course'
        : courseName.trim();

    // ==========================================================
    // CREATE NOTIFICATION MODEL
    // ==========================================================

    final notification = AppNotification(
      id: '',
      studentId: cleanStudentId,
      title: 'Application Submitted',
      message:
      'Your application for $cleanCourseName '
          'has been submitted successfully. '
          'You will be notified when your application '
          'is reviewed.',
      type: 'application_update',
      isRead: false,
      createdAt: DateTime.now(),
      relatedId: applicationId,
    );

    // ==========================================================
    // SAVE NOTIFICATION
    // ==========================================================

    final notificationRef =
    await _notifications.add(
      notification.toFirestore(),
    );

    debugPrint(
      'NOTIFICATION ID: ${notificationRef.id}',
    );

    debugPrint(
      'NOTIFICATION STUDENT ID: $cleanStudentId',
    );

    debugPrint(
      'NOTIFICATION TYPE: application_update',
    );
  }

  // ============================================================
  // GET CURRENT STUDENT'S ACTIVE APPLICATION
  // ============================================================

  Future<ApplicationModel?>
  getMyActiveApplication() async {
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
          (doc) =>
          ApplicationModel.fromFirestore(doc),
    )
        .toList();

    // ==========================================================
    // ONLY ACTIVE APPLICATIONS
    // ==========================================================

    final activeApplications =
    applications.where((app) {
      return _isActiveStatus(app.status);
    }).toList();

    if (activeApplications.isEmpty) {
      return null;
    }

    // ==========================================================
    // SORT NEWEST FIRST
    // ==========================================================

    activeApplications.sort((a, b) {
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

    return activeApplications.first;
  }

  // ============================================================
  // GET CURRENT STUDENT'S LATEST APPLICATION
  // ============================================================

  Future<ApplicationModel?>
  getMyApplication() async {
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
          (doc) =>
          ApplicationModel.fromFirestore(doc),
    )
        .toList();

    // ==========================================================
    // SORT BY CREATED DATE
    // ==========================================================

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

  Future<ApplicationModel?>
  getApplicationById(
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

    // ==========================================================
    // SECURITY CHECK
    // ==========================================================

    if (application.studentId != _uid) {
      throw Exception(
        'You are not allowed to view this application.',
      );
    }

    return application;
  }
}