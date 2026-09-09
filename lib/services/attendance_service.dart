import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/collection_names.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  AttendanceService._();

  static final AttendanceService instance =
  AttendanceService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  Future<List<AttendanceModel>> getMyAttendance({
    required String batchId,
  }) async {
    final snapshot = await _firestore
        .collection(CollectionNames.attendance)
        .where('studentId', isEqualTo: _uid)
        .where('batchId', isEqualTo: batchId)
        .get();

    final records = snapshot.docs
        .map(
          (doc) => AttendanceModel.fromFirestore(doc),
    )
        .toList();

    records.sort(
          (a, b) => b.date.compareTo(a.date),
    );

    return records;
  }

  Future<List<AttendanceModel>> getMonthlyAttendance({
    required String batchId,
    required int year,
    required int month,
  }) async {
    final records = await getMyAttendance(
      batchId: batchId,
    );

    return records.where((record) {
      return record.date.year == year &&
          record.date.month == month;
    }).toList();
  }

  double calculatePercentage(
      List<AttendanceModel> records,
      ) {
    if (records.isEmpty) {
      return 0;
    }

    final attended = records.where(
          (record) =>
      record.status == 'present' ||
          record.status == 'late',
    );

    return (attended.length / records.length) * 100;
  }

  int countStatus(
      List<AttendanceModel> records,
      String status,
      ) {
    return records
        .where((record) => record.status == status)
        .length;
  }
}