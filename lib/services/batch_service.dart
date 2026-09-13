import 'package:cloud_firestore/cloud_firestore.dart';

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

      print('========================================');
      print('GETTING BATCHES FOR COURSE');
      print('COURSE ID FROM APP: $cleanCourseId');

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

      print(
        'TOTAL OPEN BATCHES FROM FIREBASE: '
            '${snapshot.docs.length}',
      );

      final List<BatchModel> batches = [];

      for (final doc in snapshot.docs) {
        try {
          final batch = BatchModel.fromFirestore(doc);

          print(
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
          print(
            'ERROR READING BATCH ${doc.id}: $e',
          );
        }
      }

      print(
        'MATCHED BATCHES FOR $cleanCourseId: '
            '${batches.length}',
      );

      print('========================================');

      return batches;
    } catch (e) {
      print(
        'ERROR LOADING BATCHES FOR COURSE '
            '$courseId: $e',
      );

      rethrow;
    }
  }

  // =========================================================
  // GET SINGLE BATCH BY ID
  // =========================================================
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
      print(
        'ERROR LOADING BATCH $batchId: $e',
      );

      rethrow;
    }
  }
}