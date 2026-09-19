import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/collection_names.dart';
import '../../../models/application_model.dart';
import '../../../models/notification_model.dart';

class CoordinatorApplicationService {
  CoordinatorApplicationService._();

  static final CoordinatorApplicationService instance =
  CoordinatorApplicationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection(CollectionNames.applications);

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection(CollectionNames.notifications);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(CollectionNames.users);

  CollectionReference<Map<String, dynamic>> get _batches =>
      _firestore.collection(CollectionNames.batches);

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
  // GET APPLICATIONS
  // ============================================================

  Future<List<ApplicationModel>> getApplications() async {
    debugPrint('==========================================');
    debugPrint('COORDINATOR APPLICATIONS: LOAD START');
    debugPrint('==========================================');

    try {
      debugPrint('Current Auth UID: ${_auth.currentUser?.uid}');
      debugPrint('Current Email: ${_auth.currentUser?.email}');

      final snapshot = await _applications.get();

      debugPrint(
        'TOTAL APPLICATION DOCUMENTS: ${snapshot.docs.length}',
      );

      final applications = snapshot.docs
          .map(
            (doc) => ApplicationModel.fromFirestore(doc),
      )
          .toList();

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

      debugPrint(
        'APPLICATIONS LOADED SUCCESSFULLY: ${applications.length}',
      );

      for (final application in applications) {
        debugPrint(
          'APPLICATION => '
              'id=${application.id} | '
              'studentId=${application.studentId} | '
              'name=${application.fullName} | '
              'status=${application.status} | '
              'courseId=${application.courseId} | '
              'batchId=${application.batchId} | '
              'campusId=${application.campusId}',
        );
      }

      return applications;
    } catch (e, stackTrace) {
      debugPrint('==========================================');
      debugPrint('ERROR LOADING APPLICATIONS');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==========================================');

      rethrow;
    }
  }

  // ============================================================
  // UPDATE APPLICATION STATUS
  // ============================================================

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? rejectionReason,
  }) async {
    debugPrint('');
    debugPrint('==========================================');
    debugPrint('APPLICATION STATUS UPDATE START');
    debugPrint('==========================================');

    try {
      final cleanApplicationId = applicationId.trim();
      final normalizedStatus = status.trim().toLowerCase();

      debugPrint(
        'Application ID: $cleanApplicationId',
      );

      debugPrint(
        'Requested Status: $normalizedStatus',
      );

      debugPrint(
        'Coordinator UID: ${_auth.currentUser?.uid}',
      );

      debugPrint(
        'Coordinator Email: ${_auth.currentUser?.email}',
      );

      // ----------------------------------------------------------
      // VALIDATION
      // ----------------------------------------------------------

      if (cleanApplicationId.isEmpty) {
        throw Exception('Application ID is missing.');
      }

      const allowedStatuses = {
        'submitted',
        'accepted',
        'waitlisted',
        'waiting_list',
        'rejected',
      };

      if (!allowedStatuses.contains(normalizedStatus)) {
        throw Exception(
          'Invalid application status: $normalizedStatus',
        );
      }

      // ----------------------------------------------------------
      // GET APPLICATION
      // ----------------------------------------------------------

      debugPrint(
        'READ APPLICATION: applications/$cleanApplicationId',
      );

      final applicationRef =
      _applications.doc(cleanApplicationId);

      final applicationSnapshot =
      await applicationRef.get();

      debugPrint(
        'APPLICATION EXISTS: ${applicationSnapshot.exists}',
      );

      if (!applicationSnapshot.exists) {
        throw Exception('Application not found.');
      }

      final applicationData =
      applicationSnapshot.data();

      if (applicationData == null) {
        throw Exception('Application data is empty.');
      }

      debugPrint(
        'APPLICATION DATA: $applicationData',
      );

      // ----------------------------------------------------------
      // READ IMPORTANT FIELDS
      // ----------------------------------------------------------

      final previousStatus =
      (applicationData['status'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

      final studentId =
      (applicationData['studentId'] ?? '')
          .toString()
          .trim();

      final courseId =
      (applicationData['courseId'] ?? '')
          .toString()
          .trim();

      final campusId =
      (applicationData['campusId'] ?? '')
          .toString()
          .trim();

      final batchId =
      (applicationData['batchId'] ?? '')
          .toString()
          .trim();

      debugPrint(
        'PREVIOUS STATUS: $previousStatus',
      );

      debugPrint(
        'STUDENT ID: $studentId',
      );

      debugPrint(
        'COURSE ID: $courseId',
      );

      debugPrint(
        'CAMPUS ID: $campusId',
      );

      debugPrint(
        'BATCH ID: $batchId',
      );

      // ----------------------------------------------------------
      // CREATE BATCH
      // ----------------------------------------------------------

      final batch = _firestore.batch();

      // ----------------------------------------------------------
      // APPLICATION UPDATE
      // ----------------------------------------------------------

      final applicationUpdate =
      <String, dynamic>{
        'status': normalizedStatus,
        'updatedAt':
        FieldValue.serverTimestamp(),
      };

      if (normalizedStatus == 'rejected') {
        final reason = rejectionReason?.trim();

        applicationUpdate['rejectionReason'] =
        reason == null || reason.isEmpty
            ? 'Application rejected.'
            : reason;
      } else {
        applicationUpdate['rejectionReason'] = null;
      }

      debugPrint(
        'PREPARING APPLICATION UPDATE...',
      );

      batch.update(
        applicationRef,
        applicationUpdate,
      );

      // ----------------------------------------------------------
      // ACCEPTED STUDENT
      // ----------------------------------------------------------

      if (normalizedStatus == 'accepted') {
        debugPrint('');
        debugPrint(
          '========== ACCEPT FLOW START ==========',
        );

        if (studentId.isEmpty) {
          throw Exception(
            'Cannot accept application because studentId is empty.',
          );
        }

        debugPrint(
          'STUDENT USER DOCUMENT: users/$studentId',
        );

        // --------------------------------------------------------
        // CHECK STUDENT USER DOCUMENT
        // --------------------------------------------------------

        final studentRef =
        _users.doc(studentId);

        final studentSnapshot =
        await studentRef.get();

        debugPrint(
          'STUDENT USER EXISTS: ${studentSnapshot.exists}',
        );

        if (studentSnapshot.exists) {
          debugPrint(
            'EXISTING STUDENT DATA: ${studentSnapshot.data()}',
          );
        } else {
          debugPrint(
            'WARNING: Student user document does NOT exist.',
          );
        }

        // --------------------------------------------------------
        // UPDATE STUDENT
        // --------------------------------------------------------

        batch.set(
          studentRef,
          {
            'role': 'student',
            'courseId': courseId,
            'campusId': campusId,
            'batchId': batchId,
            'isActive': true,
            'updatedAt':
            FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        debugPrint(
          'STUDENT UPDATE PREPARED.',
        );

        // --------------------------------------------------------
        // UPDATE BATCH
        // --------------------------------------------------------

        if (batchId.isNotEmpty &&
            previousStatus != 'accepted') {
          debugPrint(
            'READING BATCH: batches/$batchId',
          );

          final batchRef =
          _batches.doc(batchId);

          final batchSnapshot =
          await batchRef.get();

          debugPrint(
            'BATCH EXISTS: ${batchSnapshot.exists}',
          );

          if (batchSnapshot.exists) {
            final batchData =
                batchSnapshot.data() ?? {};

            debugPrint(
              'BATCH DATA: $batchData',
            );

            final enrolledStudents =
            _toInt(
              batchData['enrolledStudents'],
            );

            final seats =
            _toInt(
              batchData['seats'],
            );

            debugPrint(
              'CURRENT ENROLLED: $enrolledStudents',
            );

            debugPrint(
              'TOTAL SEATS: $seats',
            );

            // ----------------------------------------------------
            // FULL BATCH CHECK
            // ----------------------------------------------------

            if (seats > 0 &&
                enrolledStudents >= seats) {
              throw Exception(
                'Selected batch is full.',
              );
            }

            final newEnrolled =
                enrolledStudents + 1;

            final seatsLeft =
            seats > 0
                ? (seats - newEnrolled)
                .clamp(0, seats)
                : 0;

            debugPrint(
              'NEW ENROLLED: $newEnrolled',
            );

            debugPrint(
              'NEW SEATS LEFT: $seatsLeft',
            );

            batch.update(
              batchRef,
              {
                'enrolledStudents':
                newEnrolled,
                'seatsLeft':
                seatsLeft,
                'updatedAt':
                FieldValue.serverTimestamp(),
              },
            );

            debugPrint(
              'BATCH UPDATE PREPARED.',
            );
          } else {
            debugPrint(
              'WARNING: Batch does not exist. '
                  'Application will still be accepted.',
            );
          }
        }

        debugPrint(
          '========== ACCEPT FLOW READY ==========',
        );
      }

      // ----------------------------------------------------------
      // COMMIT
      // ----------------------------------------------------------

      debugPrint('');
      debugPrint(
        'FIRESTORE BATCH COMMIT START...',
      );

      await batch.commit();

      debugPrint(
        'FIRESTORE BATCH COMMIT SUCCESS!',
      );

      // ----------------------------------------------------------
      // NOTIFICATION
      // ----------------------------------------------------------

      debugPrint(
        'CREATING APPLICATION NOTIFICATION...',
      );

      try {
        await _createApplicationNotification(
          applicationData: applicationData,
          status: normalizedStatus,
          rejectionReason: rejectionReason,
        );

        debugPrint(
          'NOTIFICATION CREATED SUCCESSFULLY.',
        );
      } catch (notificationError) {
        debugPrint(
          'NOTIFICATION FAILED: $notificationError',
        );

        // Notification failure should not
        // undo application update.
      }

      debugPrint('==========================================');
      debugPrint(
        'APPLICATION UPDATE COMPLETED SUCCESSFULLY',
      );
      debugPrint('==========================================');
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==========================================');
      debugPrint('FIREBASE APPLICATION UPDATE ERROR');
      debugPrint('==========================================');
      debugPrint('CODE: ${e.code}');
      debugPrint('MESSAGE: ${e.message}');
      debugPrint('PLUGIN: ${e.plugin}');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==========================================');

      throw Exception(
        'Firebase error (${e.code}): ${e.message}',
      );
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==========================================');
      debugPrint('APPLICATION UPDATE ERROR');
      debugPrint('==========================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==========================================');

      rethrow;
    }
  }

  // ============================================================
  // BACKWARD COMPATIBILITY
  // ============================================================

  Future<void> updateApplicationStatusOnly({
    required String applicationId,
    required String status,
    String? rejectionReason,
  }) async {
    await updateApplicationStatus(
      applicationId: applicationId,
      status: status,
      rejectionReason: rejectionReason,
    );
  }

  // ============================================================
  // CREATE APPLICATION NOTIFICATION
  // ============================================================

  Future<void> _createApplicationNotification({
    required Map<String, dynamic> applicationData,
    required String status,
    String? rejectionReason,
  }) async {
    final studentId =
    (applicationData['studentId'] ?? '')
        .toString()
        .trim();

    if (studentId.isEmpty) {
      return;
    }

    final courseName =
    (applicationData['courseName'] ?? 'course')
        .toString()
        .trim();

    String title;
    String message;

    switch (status) {
      case 'accepted':
        title = 'Application Accepted';
        message =
        'Your application for $courseName has been accepted.';
        break;

      case 'waitlisted':
      case 'waiting_list':
        title = 'Application Waitlisted';
        message =
        'Your application for $courseName has been waitlisted.';
        break;

      case 'rejected':
        title = 'Application Rejected';

        final reason =
        rejectionReason?.trim();

        if (reason != null &&
            reason.isNotEmpty) {
          message =
          'Your application for $courseName was rejected. '
              'Reason: $reason';
        } else {
          message =
          'Your application for $courseName was rejected.';
        }
        break;

      case 'submitted':
        title = 'Application Submitted';
        message =
        'Your application for $courseName has been submitted.';
        break;

      default:
        title = 'Application Updated';
        message =
        'Your application for $courseName has been updated.';
    }

    final notification = AppNotification(
      id: '',
      studentId: studentId,
      title: title,
      message: message,
      type: 'application_update',
      isRead: false,
      createdAt: DateTime.now(),
      relatedId: '',
    );

    await _notifications.add(
      notification.toFirestore(),
    );
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