import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/collection_names.dart';
import '../../../models/batch_model.dart';

class CoordinatorBatchService {
  CoordinatorBatchService._();

  static final CoordinatorBatchService instance =
  CoordinatorBatchService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // GET ALL BATCHES
  // ============================================================

  Future<List<BatchModel>> getBatches() async {
    try {
      final snapshot = await _firestore
          .collection(CollectionNames.batches)
          .get();

      // ========================================================
      // DEBUG
      // ========================================================

      print('');
      print('==============================================');
      print('          BATCH MANAGEMENT DEBUG              ');
      print('==============================================');

      print(
        'Firebase Project ID: '
            '${_firestore.app.options.projectId}',
      );

      print(
        'Firestore Collection: '
            '${CollectionNames.batches}',
      );

      print(
        'TOTAL BATCH DOCUMENTS: '
            '${snapshot.docs.length}',
      );

      print('----------------------------------------------');

      for (final doc in snapshot.docs) {
        print('BATCH ID: ${doc.id}');
        print('BATCH DATA: ${doc.data()}');
        print('----------------------------------------------');
      }

      // ========================================================
      // PARSE BATCHES
      // ========================================================

      final List<BatchModel> batches = [];

      for (final doc in snapshot.docs) {
        try {
          final batch = BatchModel.fromFirestore(doc);

          print(
            'PARSED SUCCESSFULLY: ${batch.id}',
          );

          print(
            '  courseId: ${batch.courseId}',
          );

          print(
            '  campusId: ${batch.campusId}',
          );

          print(
            '  instructorId: ${batch.instructorId}',
          );

          print(
            '  classDay: ${batch.classDay}',
          );

          print(
            '  classTime: ${batch.classTime}',
          );

          print(
            '  room: ${batch.room}',
          );

          print(
            '  seats: ${batch.seats}',
          );

          print(
            '  enrolledStudents: '
                '${batch.enrolledStudents}',
          );

          print(
            '  seatsLeft: ${batch.seatsLeft}',
          );

          print(
            '  isOpen: ${batch.isOpen}',
          );

          print(
            '  startDate: ${batch.startDate}',
          );

          print(
            '  instructorAssignments: '
                '${batch.instructorAssignments}',
          );

          print(
            '----------------------------------------------',
          );

          batches.add(batch);
        } catch (e, stackTrace) {
          print(
            'FAILED TO PARSE BATCH: ${doc.id}',
          );

          print(
            'ERROR: $e',
          );

          print(
            'STACK TRACE: $stackTrace',
          );

          print(
            '----------------------------------------------',
          );
        }
      }

      // ========================================================
      // SORT BY START DATE
      // ========================================================

      batches.sort((a, b) {
        final aDate = a.startDate;
        final bDate = b.startDate;

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

      // ========================================================
      // FINAL DEBUG
      // ========================================================

      print('');
      print('==============================================');
      print(
        'FINAL VALID BATCH COUNT: ${batches.length}',
      );
      print('==============================================');
      print('');

      return batches;
    } catch (e, stackTrace) {
      print('');
      print('==============================================');
      print('             GET BATCHES ERROR                ');
      print('==============================================');

      print(
        'ERROR: $e',
      );

      print(
        'STACK TRACE: $stackTrace',
      );

      print('==============================================');
      print('');

      throw Exception(
        'Unable to load batches. Please check Firestore permissions.',
      );
    }
  }

  // ============================================================
  // GET SINGLE BATCH
  // ============================================================

  Future<BatchModel?> getBatchById(
      String batchId,
      ) async {
    final cleanId = batchId.trim();

    if (cleanId.isEmpty) {
      return null;
    }

    try {
      final doc = await _firestore
          .collection(CollectionNames.batches)
          .doc(cleanId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return BatchModel.fromFirestore(doc);
    } catch (e) {
      throw Exception(
        'Unable to load batch details.',
      );
    }
  }

  // ============================================================
  // CREATE BATCH
  // ============================================================

  Future<String> createBatch({
    required String courseId,
    required String campusId,
    String instructorId = '',
    required String classDay,
    required String classTime,
    required String room,
    required DateTime? startDate,
    required int seats,
    int enrolledStudents = 0,
    bool isOpen = true,
  }) async {
    final cleanCourseId = courseId.trim();
    final cleanCampusId = campusId.trim();
    final cleanInstructorId = instructorId.trim();
    final cleanClassDay = classDay.trim();
    final cleanClassTime = classTime.trim();
    final cleanRoom = room.trim();

    // ========================================================
    // VALIDATION
    // ========================================================

    if (cleanCourseId.isEmpty) {
      throw Exception(
        'Please select a course.',
      );
    }

    if (cleanCampusId.isEmpty) {
      throw Exception(
        'Please select a campus.',
      );
    }

    if (cleanClassDay.isEmpty) {
      throw Exception(
        'Please enter the class day.',
      );
    }

    if (cleanClassTime.isEmpty) {
      throw Exception(
        'Please enter the class time.',
      );
    }

    if (cleanRoom.isEmpty) {
      throw Exception(
        'Please enter the room.',
      );
    }

    if (seats <= 0) {
      throw Exception(
        'Seats must be greater than zero.',
      );
    }

    if (enrolledStudents < 0) {
      throw Exception(
        'Enrolled students cannot be negative.',
      );
    }

    if (enrolledStudents > seats) {
      throw Exception(
        'Enrolled students cannot exceed total seats.',
      );
    }

    // ========================================================
    // CREATE
    // ========================================================

    try {
      final docRef = _firestore
          .collection(CollectionNames.batches)
          .doc();

      final data = <String, dynamic>{
        'courseId': cleanCourseId,
        'campusId': cleanCampusId,
        'instructorId': cleanInstructorId,

        // New subject/instructor structure.
        'instructorAssignments':
        <Map<String, dynamic>>[],

        'classDay': cleanClassDay,
        'classTime': cleanClassTime,
        'room': cleanRoom,

        'startDate': startDate == null
            ? null
            : Timestamp.fromDate(startDate),

        'seats': seats,
        'enrolledStudents': enrolledStudents,

        'seatsLeft':
        seats - enrolledStudents,

        'isOpen': isOpen,

        'createdAt':
        FieldValue.serverTimestamp(),

        'updatedAt':
        FieldValue.serverTimestamp(),
      };

      await docRef.set(data);

      return docRef.id;
    } catch (e) {
      throw Exception(
        'Unable to create batch. Please try again.',
      );
    }
  }

  // ============================================================
  // UPDATE BATCH
  // ============================================================

  Future<void> updateBatch({
    required String batchId,
    required String courseId,
    required String campusId,
    String instructorId = '',
    required String classDay,
    required String classTime,
    required String room,
    required DateTime? startDate,
    required int seats,
    required int enrolledStudents,
    required bool isOpen,
  }) async {
    final cleanBatchId = batchId.trim();
    final cleanCourseId = courseId.trim();
    final cleanCampusId = campusId.trim();
    final cleanInstructorId = instructorId.trim();
    final cleanClassDay = classDay.trim();
    final cleanClassTime = classTime.trim();
    final cleanRoom = room.trim();

    // ========================================================
    // VALIDATION
    // ========================================================

    if (cleanBatchId.isEmpty) {
      throw Exception(
        'Batch ID is required.',
      );
    }

    if (cleanCourseId.isEmpty) {
      throw Exception(
        'Please select a course.',
      );
    }

    if (cleanCampusId.isEmpty) {
      throw Exception(
        'Please select a campus.',
      );
    }

    if (cleanClassDay.isEmpty) {
      throw Exception(
        'Please enter the class day.',
      );
    }

    if (cleanClassTime.isEmpty) {
      throw Exception(
        'Please enter the class time.',
      );
    }

    if (cleanRoom.isEmpty) {
      throw Exception(
        'Please enter the room.',
      );
    }

    if (seats <= 0) {
      throw Exception(
        'Seats must be greater than zero.',
      );
    }

    if (enrolledStudents < 0) {
      throw Exception(
        'Enrolled students cannot be negative.',
      );
    }

    if (enrolledStudents > seats) {
      throw Exception(
        'Enrolled students cannot exceed total seats.',
      );
    }

    // ========================================================
    // UPDATE
    // ========================================================

    try {
      final batchRef = _firestore
          .collection(CollectionNames.batches)
          .doc(cleanBatchId);

      final existingDoc =
      await batchRef.get();

      if (!existingDoc.exists) {
        throw Exception(
          'Batch not found.',
        );
      }

      final existingData =
      existingDoc.data();

      // Preserve existing assignments.
      final existingAssignments =
      _readAssignments(
        existingData?['instructorAssignments'],
      );

      await batchRef.update({
        'courseId': cleanCourseId,
        'campusId': cleanCampusId,
        'instructorId': cleanInstructorId,

        'instructorAssignments':
        existingAssignments,

        'classDay': cleanClassDay,
        'classTime': cleanClassTime,
        'room': cleanRoom,

        'startDate': startDate == null
            ? null
            : Timestamp.fromDate(startDate),

        'seats': seats,
        'enrolledStudents': enrolledStudents,

        'seatsLeft':
        seats - enrolledStudents,

        'isOpen': isOpen,

        'updatedAt':
        FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to update batch. Please try again.',
      );
    }
  }

  // ============================================================
  // TOGGLE BATCH OPEN / CLOSED
  // ============================================================

  Future<void> setBatchOpenStatus({
    required String batchId,
    required bool isOpen,
  }) async {
    final cleanBatchId = batchId.trim();

    if (cleanBatchId.isEmpty) {
      throw Exception(
        'Batch ID is required.',
      );
    }

    try {
      await _firestore
          .collection(CollectionNames.batches)
          .doc(cleanBatchId)
          .update({
        'isOpen': isOpen,
        'updatedAt':
        FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(
        'Unable to update batch status.',
      );
    }
  }

  // ============================================================
  // DELETE BATCH
  // ============================================================

  Future<void> deleteBatch(
      String batchId,
      ) async {
    final cleanBatchId = batchId.trim();

    if (cleanBatchId.isEmpty) {
      throw Exception(
        'Batch ID is required.',
      );
    }

    try {
      final batchRef = _firestore
          .collection(CollectionNames.batches)
          .doc(cleanBatchId);

      final batchDoc =
      await batchRef.get();

      if (!batchDoc.exists) {
        throw Exception(
          'Batch not found.',
        );
      }

      final data = batchDoc.data();

      final instructorIds =
      <String>{};

      // ========================================================
      // OLD INSTRUCTOR STRUCTURE
      // ========================================================

      final oldInstructorId =
          data?['instructorId']
              ?.toString()
              .trim() ??
              '';

      if (oldInstructorId.isNotEmpty) {
        instructorIds.add(
          oldInstructorId,
        );
      }

      // ========================================================
      // NEW INSTRUCTOR STRUCTURE
      // ========================================================

      final assignments =
      _readAssignments(
        data?['instructorAssignments'],
      );

      for (final assignment
      in assignments) {
        final instructorId =
            assignment['instructorId']
                ?.toString()
                .trim() ??
                '';

        if (instructorId.isNotEmpty) {
          instructorIds.add(
            instructorId,
          );
        }
      }

      // ========================================================
      // FIRESTORE BATCH WRITE
      // ========================================================

      final writeBatch =
      _firestore.batch();

      writeBatch.delete(
        batchRef,
      );

      // ========================================================
      // REMOVE BATCH FROM INSTRUCTORS
      // ========================================================

      for (final instructorId
      in instructorIds) {
        final instructorRef =
        _firestore
            .collection(
          CollectionNames.users,
        )
            .doc(instructorId);

        final instructorDoc =
        await instructorRef.get();

        if (!instructorDoc.exists) {
          continue;
        }

        final instructorData =
        instructorDoc.data();

        final batchIds =
        _readStringList(
          instructorData?['batchIds'],
        );

        batchIds.remove(
          cleanBatchId,
        );

        final oldBatchId =
            instructorData?['batchId']
                ?.toString()
                .trim() ??
                '';

        final update =
        <String, dynamic>{
          'batchIds': batchIds,
          'updatedAt':
          FieldValue.serverTimestamp(),
        };

        if (oldBatchId ==
            cleanBatchId) {
          update['batchId'] =
          batchIds.isNotEmpty
              ? batchIds.first
              : '';
        }

        writeBatch.update(
          instructorRef,
          update,
        );
      }

      await writeBatch.commit();
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to delete batch. Please try again.',
      );
    }
  }

  // ============================================================
  // SEARCH BATCHES
  // ============================================================

  List<BatchModel> searchBatches(
      List<BatchModel> batches,
      String query,
      ) {
    final cleanQuery =
    query.trim().toLowerCase();

    if (cleanQuery.isEmpty) {
      return batches;
    }

    return batches.where((batch) {
      return batch.id
          .toLowerCase()
          .contains(cleanQuery) ||
          batch.courseId
              .toLowerCase()
              .contains(cleanQuery) ||
          batch.campusId
              .toLowerCase()
              .contains(cleanQuery) ||
          batch.classDay
              .toLowerCase()
              .contains(cleanQuery) ||
          batch.classTime
              .toLowerCase()
              .contains(cleanQuery) ||
          batch.room
              .toLowerCase()
              .contains(cleanQuery) ||
          batch.instructorId
              .toLowerCase()
              .contains(cleanQuery);
    }).toList();
  }

  // ============================================================
  // READ STRING LIST
  // ============================================================

  List<String> _readStringList(
      dynamic value,
      ) {
    if (value is! List) {
      return [];
    }

    return value
        .map(
          (item) => item
          .toString()
          .trim(),
    )
        .where(
          (item) => item.isNotEmpty,
    )
        .toSet()
        .toList();
  }

  // ============================================================
  // READ INSTRUCTOR ASSIGNMENTS
  // ============================================================

  List<Map<String, dynamic>> _readAssignments(
      dynamic value,
      ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => <String, dynamic>{
        'instructorId':
        item['instructorId']
            ?.toString()
            .trim() ??
            '',
        'subject':
        item['subject']
            ?.toString()
            .trim() ??
            '',
      },
    )
        .where(
          (item) =>
      item['instructorId']
          .toString()
          .isNotEmpty &&
          item['subject']
              .toString()
              .isNotEmpty,
    )
        .toList();
  }
}