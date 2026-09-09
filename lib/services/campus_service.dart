import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/collection_names.dart';
import '../models/campus_model.dart';

class CampusService {
  CampusService._();

  static final CampusService instance =
  CampusService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<List<CampusModel>> getActiveCampuses() async {
    final snapshot = await _firestore
        .collection(CollectionNames.campuses)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => CampusModel.fromFirestore(doc),
    )
        .toList();
  }

  Future<CampusModel?> getCampusById(
      String campusId,
      ) async {
    final doc = await _firestore
        .collection(CollectionNames.campuses)
        .doc(campusId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return CampusModel.fromFirestore(doc);
  }
}