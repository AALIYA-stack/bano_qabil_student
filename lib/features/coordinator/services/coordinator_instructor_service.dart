import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/collection_names.dart';

class CoordinatorInstructorService {
  CoordinatorInstructorService._();

  static final CoordinatorInstructorService instance =
  CoordinatorInstructorService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // GET ALL ACTIVE INSTRUCTORS
  // ============================================================

  Future<List<Map<String, dynamic>>> getInstructors() async {
    try {
      print('========================================');
      print('GET INSTRUCTORS START');
      print('========================================');

      final snapshot = await _firestore
          .collection(CollectionNames.users)
          .where(
        'role',
        isEqualTo: 'instructor',
      )
          .get();

      print(
        'TOTAL INSTRUCTOR DOCUMENTS: ${snapshot.docs.length}',
      );

      final List<Map<String, dynamic>> instructors = [];

      for (final doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data();

        final String id = doc.id;

        final String role =
        (data['role'] ?? '')
            .toString()
            .trim()
            .toLowerCase();

        final String name =
        (data['name'] ?? '')
            .toString()
            .trim();

        final String email =
        (data['email'] ?? '')
            .toString()
            .trim();

        final String phone =
        (data['phone'] ?? '')
            .toString()
            .trim();

        final String courseId =
        (data['courseId'] ?? '')
            .toString()
            .trim();

        final String campusId =
        (data['campusId'] ?? '')
            .toString()
            .trim();

        final String batchId =
        (data['batchId'] ?? '')
            .toString()
            .trim();

        final bool isActive =
            data['isActive'] == true;

        final String displayName =
        name.isNotEmpty
            ? name
            : email.isNotEmpty
            ? email
            : 'Instructor';

        print(
          'INSTRUCTOR FOUND: '
              'ID=$id | '
              'NAME=$displayName | '
              'EMAIL=$email | '
              'ROLE=$role | '
              'COURSE=$courseId | '
              'CAMPUS=$campusId | '
              'BATCH=$batchId | '
              'ACTIVE=$isActive',
        );

        // --------------------------------------------------------
        // ROLE CHECK
        // --------------------------------------------------------

        if (role != 'instructor') {
          print(
            'SKIPPED INVALID ROLE: '
                '$id | role=$role',
          );
          continue;
        }

        // --------------------------------------------------------
        // ACTIVE CHECK
        // --------------------------------------------------------

        if (!isActive) {
          print(
            'SKIPPED INACTIVE INSTRUCTOR: '
                '$id | $displayName',
          );
          continue;
        }

        instructors.add({
          'id': id,
          'name': displayName,
          'email': email,
          'phone': phone,
          'role': role,
          'courseId': courseId,
          'campusId': campusId,
          'batchId': batchId,
          'isActive': true,
        });
      }

      // --------------------------------------------------------
      // SORT BY NAME
      // --------------------------------------------------------

      instructors.sort(
            (a, b) {
          final String nameA =
          (a['name'] ?? '')
              .toString()
              .toLowerCase();

          final String nameB =
          (b['name'] ?? '')
              .toString()
              .toLowerCase();

          return nameA.compareTo(nameB);
        },
      );

      print(
        '----------------------------------------',
      );

      print(
        'ACTIVE INSTRUCTORS: ${instructors.length}',
      );

      for (final instructor in instructors) {
        print(
          'ACTIVE INSTRUCTOR: '
              'ID=${instructor['id']} | '
              'NAME=${instructor['name']} | '
              'EMAIL=${instructor['email']} | '
              'COURSE=${instructor['courseId']} | '
              'CAMPUS=${instructor['campusId']} | '
              'BATCH=${instructor['batchId']}',
        );
      }

      print('========================================');
      print('GET INSTRUCTORS END');
      print('========================================');

      return instructors;
    } on FirebaseException catch (e) {
      print(
        '========================================',
      );
      print(
        'FIREBASE ERROR GETTING INSTRUCTORS',
      );
      print(
        'CODE: ${e.code}',
      );
      print(
        'MESSAGE: ${e.message}',
      );
      print(
        '========================================',
      );

      rethrow;
    } catch (e) {
      print(
        'ERROR GETTING INSTRUCTORS: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // GET INSTRUCTORS FOR SPECIFIC COURSE
  // ============================================================

  Future<List<Map<String, dynamic>>> getInstructorsForCourse({
    required String courseId,
  }) async {
    final String cleanCourseId =
    courseId.trim();

    if (cleanCourseId.isEmpty) {
      print(
        'GET COURSE INSTRUCTORS: EMPTY COURSE ID',
      );

      return [];
    }

    try {
      final List<Map<String, dynamic>> instructors =
      await getInstructors();

      final List<Map<String, dynamic>> filtered =
      instructors.where(
            (instructor) {
          final String instructorCourseId =
          (instructor['courseId'] ?? '')
              .toString()
              .trim();

          return instructorCourseId ==
              cleanCourseId;
        },
      ).toList();

      print(
        'COURSE INSTRUCTOR FILTER: '
            'course=$cleanCourseId | '
            'found=${filtered.length}',
      );

      for (final instructor in filtered) {
        print(
          'COURSE MATCH: '
              '${instructor['name']} | '
              'ID=${instructor['id']} | '
              'COURSE=${instructor['courseId']}',
        );
      }

      return filtered;
    } catch (e) {
      print(
        'ERROR GETTING COURSE INSTRUCTORS: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // ASSIGN INSTRUCTOR TO BATCH
  // ============================================================

  Future<void> assignInstructor({
    required String batchId,
    required String instructorId,
  }) async {
    final String cleanBatchId =
    batchId.trim();

    final String cleanInstructorId =
    instructorId.trim();

    try {
      // --------------------------------------------------------
      // BASIC VALIDATION
      // --------------------------------------------------------

      if (cleanBatchId.isEmpty) {
        throw Exception(
          'Batch ID is required.',
        );
      }

      if (cleanInstructorId.isEmpty) {
        throw Exception(
          'Please select an instructor.',
        );
      }

      print('========================================');
      print('ASSIGN INSTRUCTOR START');
      print('BATCH=$cleanBatchId');
      print('INSTRUCTOR=$cleanInstructorId');
      print('========================================');

      // --------------------------------------------------------
      // BATCH REFERENCE
      // --------------------------------------------------------

      final DocumentReference<Map<String, dynamic>> batchRef =
      _firestore
          .collection(CollectionNames.batches)
          .doc(cleanBatchId);

      // --------------------------------------------------------
      // GET BATCH
      // --------------------------------------------------------

      final DocumentSnapshot<Map<String, dynamic>> batchSnapshot =
      await batchRef.get();

      if (!batchSnapshot.exists) {
        throw Exception(
          'Selected batch does not exist.',
        );
      }

      final Map<String, dynamic> batchData =
          batchSnapshot.data() ?? {};

      final String batchCourseId =
      (batchData['courseId'] ?? '')
          .toString()
          .trim();

      final String batchCampusId =
      (batchData['campusId'] ?? '')
          .toString()
          .trim();

      final String oldInstructorId =
      (batchData['instructorId'] ?? '')
          .toString()
          .trim();

      print(
        'BATCH FOUND: '
            'ID=$cleanBatchId | '
            'COURSE=$batchCourseId | '
            'CAMPUS=$batchCampusId | '
            'CURRENT INSTRUCTOR=$oldInstructorId',
      );

      // --------------------------------------------------------
      // INSTRUCTOR REFERENCE
      // --------------------------------------------------------

      final DocumentReference<Map<String, dynamic>> instructorRef =
      _firestore
          .collection(CollectionNames.users)
          .doc(cleanInstructorId);

      // --------------------------------------------------------
      // GET INSTRUCTOR
      // --------------------------------------------------------

      final DocumentSnapshot<Map<String, dynamic>>
      instructorSnapshot =
      await instructorRef.get();

      if (!instructorSnapshot.exists) {
        throw Exception(
          'Selected instructor does not exist.',
        );
      }

      final Map<String, dynamic> instructorData =
          instructorSnapshot.data() ?? {};

      final String role =
      (instructorData['role'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

      final bool isActive =
          instructorData['isActive'] == true;

      final String instructorNameRaw =
      (instructorData['name'] ?? '')
          .toString()
          .trim();

      final String instructorEmail =
      (instructorData['email'] ?? '')
          .toString()
          .trim();

      final String instructorName =
      instructorNameRaw.isNotEmpty
          ? instructorNameRaw
          : instructorEmail.isNotEmpty
          ? instructorEmail
          : 'Instructor';

      final String instructorCourseId =
      (instructorData['courseId'] ?? '')
          .toString()
          .trim();

      final String instructorCampusId =
      (instructorData['campusId'] ?? '')
          .toString()
          .trim();

      final String currentInstructorBatchId =
      (instructorData['batchId'] ?? '')
          .toString()
          .trim();

      print(
        'INSTRUCTOR FOUND: '
            'ID=$cleanInstructorId | '
            'NAME=$instructorName | '
            'EMAIL=$instructorEmail | '
            'ROLE=$role | '
            'ACTIVE=$isActive | '
            'COURSE=$instructorCourseId | '
            'CAMPUS=$instructorCampusId | '
            'BATCH=$currentInstructorBatchId',
      );

      // --------------------------------------------------------
      // ROLE VALIDATION
      // --------------------------------------------------------

      if (role != 'instructor') {
        throw Exception(
          'Selected user is not an instructor.',
        );
      }

      // --------------------------------------------------------
      // ACTIVE VALIDATION
      // --------------------------------------------------------

      if (!isActive) {
        throw Exception(
          '$instructorName is inactive.',
        );
      }

      // --------------------------------------------------------
      // SAME INSTRUCTOR ALREADY ASSIGNED
      // --------------------------------------------------------

      if (currentInstructorBatchId.isNotEmpty &&
          currentInstructorBatchId ==
              cleanBatchId &&
          oldInstructorId ==
              cleanInstructorId) {
        print(
          'INSTRUCTOR ALREADY ASSIGNED TO THIS BATCH.',
        );

        return;
      }

      // --------------------------------------------------------
      // PREVENT MULTIPLE BATCH ASSIGNMENT
      // --------------------------------------------------------

      if (currentInstructorBatchId.isNotEmpty &&
          currentInstructorBatchId !=
              cleanBatchId) {
        throw Exception(
          '$instructorName is already assigned '
              'to batch $currentInstructorBatchId.',
        );
      }

      // --------------------------------------------------------
      // COURSE VALIDATION
      // --------------------------------------------------------

      if (batchCourseId.isNotEmpty &&
          instructorCourseId.isNotEmpty &&
          batchCourseId !=
              instructorCourseId) {
        throw Exception(
          '$instructorName is assigned to '
              '$instructorCourseId, not '
              '$batchCourseId.',
        );
      }

      // --------------------------------------------------------
      // CAMPUS VALIDATION
      // --------------------------------------------------------

      if (batchCampusId.isNotEmpty &&
          instructorCampusId.isNotEmpty &&
          batchCampusId !=
              instructorCampusId) {
        throw Exception(
          'Instructor campus does not match batch campus.',
        );
      }

      print(
        'INSTRUCTOR VALIDATED SUCCESSFULLY',
      );

      // --------------------------------------------------------
      // WRITE BATCH
      // --------------------------------------------------------

      final WriteBatch writeBatch =
      _firestore.batch();

      // Batch -> instructor
      writeBatch.update(
        batchRef,
        {
          'instructorId':
          cleanInstructorId,
        },
      );

      // Instructor -> batch
      writeBatch.update(
        instructorRef,
        {
          'batchId':
          cleanBatchId,
        },
      );

      // --------------------------------------------------------
      // CLEAR OLD INSTRUCTOR
      // --------------------------------------------------------

      if (oldInstructorId.isNotEmpty &&
          oldInstructorId !=
              cleanInstructorId) {
        final DocumentReference<Map<String, dynamic>>
        oldInstructorRef =
        _firestore
            .collection(
          CollectionNames.users,
        )
            .doc(oldInstructorId);

        writeBatch.update(
          oldInstructorRef,
          {
            'batchId': '',
          },
        );

        print(
          'OLD INSTRUCTOR BATCH CLEARED: '
              '$oldInstructorId',
        );
      }

      // --------------------------------------------------------
      // COMMIT
      // --------------------------------------------------------

      print(
        'COMMITTING INSTRUCTOR ASSIGNMENT...',
      );

      await writeBatch.commit();

      print(
        'WRITE BATCH COMMITTED.',
      );

      // --------------------------------------------------------
      // VERIFY BATCH
      // --------------------------------------------------------

      final DocumentSnapshot<Map<String, dynamic>>
      verifyBatch =
      await batchRef.get();

      final String savedInstructorId =
      (verifyBatch.data()?['instructorId'] ?? '')
          .toString()
          .trim();

      if (savedInstructorId !=
          cleanInstructorId) {
        throw Exception(
          'Batch instructor assignment could not be verified.',
        );
      }

      // --------------------------------------------------------
      // VERIFY INSTRUCTOR
      // --------------------------------------------------------

      final DocumentSnapshot<Map<String, dynamic>>
      verifyInstructor =
      await instructorRef.get();

      final String savedBatchId =
      (verifyInstructor.data()?['batchId'] ?? '')
          .toString()
          .trim();

      if (savedBatchId !=
          cleanBatchId) {
        throw Exception(
          'Instructor batch assignment could not be verified.',
        );
      }

      print('========================================');
      print('ASSIGN INSTRUCTOR SUCCESS');
      print('BATCH: $cleanBatchId');
      print('INSTRUCTOR: $cleanInstructorId');
      print('SAVED BATCH INSTRUCTOR: $savedInstructorId');
      print('SAVED INSTRUCTOR BATCH: $savedBatchId');
      print('========================================');
    } on FirebaseException catch (e) {
      print('========================================');
      print('FIREBASE ERROR ASSIGNING INSTRUCTOR');
      print('CODE: ${e.code}');
      print('MESSAGE: ${e.message}');
      print('========================================');

      rethrow;
    } catch (e) {
      print(
        'ERROR ASSIGNING INSTRUCTOR: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // REMOVE INSTRUCTOR
  // ============================================================

  Future<void> removeInstructor({
    required String batchId,
    required String instructorId,
  }) async {
    final String cleanBatchId =
    batchId.trim();

    final String cleanInstructorId =
    instructorId.trim();

    try {
      if (cleanBatchId.isEmpty) {
        throw Exception(
          'Batch ID is required.',
        );
      }

      print('========================================');
      print('REMOVE INSTRUCTOR START');
      print('BATCH=$cleanBatchId');
      print('INSTRUCTOR=$cleanInstructorId');
      print('========================================');

      final DocumentReference<Map<String, dynamic>> batchRef =
      _firestore
          .collection(CollectionNames.batches)
          .doc(cleanBatchId);

      // --------------------------------------------------------
      // VERIFY BATCH
      // --------------------------------------------------------

      final DocumentSnapshot<Map<String, dynamic>>
      batchSnapshot =
      await batchRef.get();

      if (!batchSnapshot.exists) {
        throw Exception(
          'Selected batch does not exist.',
        );
      }

      // --------------------------------------------------------
      // WRITE BATCH
      // --------------------------------------------------------

      final WriteBatch writeBatch =
      _firestore.batch();

      // Clear instructor from batch
      writeBatch.update(
        batchRef,
        {
          'instructorId': '',
        },
      );

      // --------------------------------------------------------
      // CLEAR INSTRUCTOR BATCH
      // --------------------------------------------------------

      if (cleanInstructorId.isNotEmpty) {
        final DocumentReference<Map<String, dynamic>>
        instructorRef =
        _firestore
            .collection(
          CollectionNames.users,
        )
            .doc(cleanInstructorId);

        writeBatch.update(
          instructorRef,
          {
            'batchId': '',
          },
        );
      }

      // --------------------------------------------------------
      // COMMIT
      // --------------------------------------------------------

      await writeBatch.commit();

      print(
        'REMOVE INSTRUCTOR WRITE SUCCESS',
      );

      // --------------------------------------------------------
      // VERIFY
      // --------------------------------------------------------

      final DocumentSnapshot<Map<String, dynamic>>
      verifyBatch =
      await batchRef.get();

      final String savedInstructorId =
      (verifyBatch.data()?['instructorId'] ?? '')
          .toString()
          .trim();

      if (savedInstructorId.isNotEmpty) {
        throw Exception(
          'Instructor could not be removed from batch.',
        );
      }

      print('========================================');
      print('REMOVE INSTRUCTOR SUCCESS');
      print('BATCH: $cleanBatchId');
      print('========================================');
    } on FirebaseException catch (e) {
      print('========================================');
      print('FIREBASE ERROR REMOVING INSTRUCTOR');
      print('CODE: ${e.code}');
      print('MESSAGE: ${e.message}');
      print('========================================');

      rethrow;
    } catch (e) {
      print(
        'ERROR REMOVING INSTRUCTOR: $e',
      );

      rethrow;
    }
  }
}