import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/collection_names.dart';
import '../models/batch_model.dart';

class BatchService {
  BatchService._();


  static final BatchService instance = BatchService._();



  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // =========================================================
  // GET BATCHES FOR COURSE
  // =========================================================
  Future<List<BatchModel>> getBatchesForCourse(
      String courseId,
      ) async {
    try {
      final cleanCourseId = courseId.trim();

      debugPrint('========================================');
      debugPrint('GETTING BATCHES FOR COURSE');
      debugPrint('COURSE ID FROM APP: $cleanCourseId');

      // Pehle sirf open batches get kar rahe hain.
      // courseId ka filter Dart mein karenge taake
      // exact mismatch easily detect ho sake.
      final snapshot = await _firestore
          .collection(CollectionNames.batches)
          .where(
        'isOpen',
        isEqualTo: true,
      )
          .get();

      debugPrint(
        'TOTAL OPEN BATCHES FROM FIREBASE: '
            '${snapshot.docs.length}',
      );

      final List<BatchModel> batches = [];

      for (final doc in snapshot.docs) {
        try {
          final batch = BatchModel.fromFirestore(doc);

          debugPrint(
            'BATCH: ${batch.id} | '
                'courseId: ${batch.courseId} | '
                'campusId: ${batch.campusId} | '
                'isOpen: ${batch.isOpen} | '
                'seats: ${batch.seats} | '
                'enrolled: ${batch.enrolledStudents} | '
                'seatsLeft: ${batch.seatsLeft}',
          );

          // Course ID exact match
          if (batch.courseId.trim() != cleanCourseId) {
            continue;
          }

          // Open batch hona zaroori hai
          if (!batch.isOpen) {
            continue;
          }

          // Seats available honi chahiye
          if (batch.seatsLeft <= 0) {
            continue;
          }

          batches.add(batch);
        } catch (e) {
          debugPrint(
            'ERROR READING BATCH ${doc.id}: $e',
          );
        }
      }

      debugPrint(
        'MATCHED BATCHES FOR $cleanCourseId: '
            '${batches.length}',
      );

      debugPrint('========================================');

      return batches;
    } catch (e) {
      debugPrint(
        'ERROR LOADING BATCHES FOR COURSE '
            '$courseId: $e',
      );

      rethrow;
    }
  }


  // =========================================================
  // GET SINGLE BATCH BY ID
  // =========================================================
  // ============================================================
  // GET BATCHES FOR INSTRUCTOR
  // ============================================================

Future<List<BatchModel>> getBatchesForInstructor(
      String instructorId,
      ) async {
    if (instructorId.trim().isEmpty) {
      return [];
    }

    final snapshot =
        await _firestore
            .collection(
              CollectionNames.batches,
            )
            .where(
              'instructorId',
              isEqualTo: instructorId,
            )
            .get();

    return snapshot.docs
        .map(
          (doc) => BatchModel.fromFirestore(
            doc,
          ),
        )
        .toList();
  }
  Future<BatchModel?> getBatchById(
      String batchId,
      ) async {
    try {
      if (batchId.trim().isEmpty) {
        return null;
      }

      final doc = await _firestore
          .collection(CollectionNames.batches)
          .doc(batchId.trim())
          .get();

      if (!doc.exists) {
        return null;
      }

      return BatchModel.fromFirestore(doc);
    } catch (e) {
      debugPrint(
        'ERROR LOADING BATCH $batchId: $e',
      );

      rethrow;
    }
  }
}

