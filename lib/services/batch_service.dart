import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/collection_names.dart';
import '../models/batch_model.dart';

class BatchService {
  BatchService._();

  static final BatchService instance =
  BatchService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<List<BatchModel>>
  getBatchesForCourse(
      String courseId,
      ) async {
    final snapshot =
    await _firestore
        .collection(
      CollectionNames.batches,
    )
        .where(
      'courseId',
      isEqualTo: courseId,
    )
        .where(
      'isOpen',
      isEqualTo: true,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) =>
          BatchModel.fromFirestore(
            doc,
          ),
    )
        .where(
          (batch) => batch.seatsLeft > 0,
    )
        .toList();
  }

  Future<BatchModel?> getBatchById(
      String batchId,
      ) async {
    if (batchId.trim().isEmpty) {
      return null;
    }

    final doc =
    await _firestore
        .collection(
      CollectionNames.batches,
    )
        .doc(batchId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return BatchModel.fromFirestore(
      doc,
    );
  }
}