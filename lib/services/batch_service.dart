import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/collection_names.dart';
import '../models/batch_model.dart';

class BatchService {
  BatchService._();

  static final BatchService instance =
  BatchService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // =========================================================
  // GET BATCHES FOR COURSE
  // =========================================================

  Future<List<BatchModel>> getBatchesForCourse(
      String courseId,
      ) async {
    try {
      final cleanCourseId =
      courseId.trim().toLowerCase();

      print('');
      print('========================================');
      print('GETTING BATCHES FOR COURSE');
      print('COURSE ID FROM APP: "$cleanCourseId"');
      print('========================================');

      // -----------------------------------------------------
      // Get all open batches.
      //
      // We intentionally filter courseId in Dart.
      // This makes Firebase data mismatches easier to detect.
      // -----------------------------------------------------

      final snapshot = await _firestore
          .collection(CollectionNames.batches)
          .where(
        'isOpen',
        isEqualTo: true,
      )
          .get();

      print(
        'TOTAL OPEN BATCHES FROM FIREBASE: '
            '${snapshot.docs.length}',
      );

      final List<BatchModel> batches = [];

      // -----------------------------------------------------
      // PROCESS EVERY BATCH
      // -----------------------------------------------------

      for (final doc in snapshot.docs) {
        try {
          final rawData = doc.data();

          print('');
          print('----------------------------------------');
          print('CHECKING BATCH: ${doc.id}');
          print(
            'FIREBASE RAW courseId: '
                '"${rawData['courseId']}"',
          );
          print(
            'FIREBASE RAW campusId: '
                '"${rawData['campusId']}"',
          );
          print(
            'FIREBASE RAW isOpen: '
                '"${rawData['isOpen']}"',
          );
          print(
            'FIREBASE RAW seats: '
                '"${rawData['seats']}"',
          );
          print(
            'FIREBASE RAW enrolledStudents: '
                '"${rawData['enrolledStudents']}"',
          );

          final batch =
          BatchModel.fromFirestore(doc);

          final batchCourseId =
          batch.courseId.trim().toLowerCase();

          print(
            'PARSED courseId: "$batchCourseId"',
          );

          print(
            'EXPECTED courseId: "$cleanCourseId"',
          );

          print(
            'seatsLeft: ${batch.seatsLeft}',
          );

          // -------------------------------------------------
          // COURSE MATCH
          // -------------------------------------------------

          if (batchCourseId != cleanCourseId) {
            print(
              '❌ SKIPPED: courseId does not match',
            );

            continue;
          }

          print(
            '✅ COURSE ID MATCH',
          );

          // -------------------------------------------------
          // OPEN CHECK
          // -------------------------------------------------

          if (!batch.isOpen) {
            print(
              '❌ SKIPPED: batch is closed',
            );

            continue;
          }

          // -------------------------------------------------
          // SEATS CHECK
          // -------------------------------------------------

          if (batch.seatsLeft <= 0) {
            print(
              '❌ SKIPPED: no seats available',
            );

            continue;
          }

          // -------------------------------------------------
          // MATCHED
          // -------------------------------------------------

          print(
            '✅ BATCH ADDED: ${batch.id}',
          );

          batches.add(batch);
        } catch (e, stackTrace) {
          print(
            '❌ ERROR READING BATCH ${doc.id}',
          );

          print('ERROR: $e');
          print('STACK: $stackTrace');
        }
      }

      print('');
      print('========================================');
      print(
        'MATCHED BATCHES FOR '
            '"$cleanCourseId": ${batches.length}',
      );

      for (final batch in batches) {
        print(
          'MATCHED → ${batch.id} | '
              'course=${batch.courseId} | '
              'campus=${batch.campusId} | '
              'seatsLeft=${batch.seatsLeft}',
        );
      }

      print('========================================');
      print('');

      return batches;
    } catch (e, stackTrace) {
      print('');
      print(
        '❌ ERROR LOADING BATCHES FOR COURSE '
            '"$courseId"',
      );

      print('ERROR: $e');
      print('STACK: $stackTrace');

      rethrow;
    }
  }

  // =========================================================
  // GET SINGLE BATCH
  // =========================================================

  Future<BatchModel?> getBatchById(
      String batchId,
      ) async {
    try {
      final cleanBatchId =
      batchId.trim();

      if (cleanBatchId.isEmpty) {
        return null;
      }

      final doc = await _firestore
          .collection(CollectionNames.batches)
          .doc(cleanBatchId)
          .get();

      if (!doc.exists) {
        print(
          'BATCH NOT FOUND: $cleanBatchId',
        );

        return null;
      }

      return BatchModel.fromFirestore(doc);
    } catch (e, stackTrace) {
      print(
        'ERROR LOADING BATCH $batchId: $e',
      );

      print(stackTrace);

      rethrow;
    }
  }
}