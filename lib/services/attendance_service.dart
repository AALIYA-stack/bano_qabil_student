import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/attendance_model.dart';

class AttendanceService {
  AttendanceService._();

  static final AttendanceService instance =
  AttendanceService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // CURRENT USER UID
  // ============================================================

  String get _uid {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    return user.uid;
  }

  // ============================================================
  // GET MY ATTENDANCE
  // ============================================================

  Future<List<AttendanceModel>> getMyAttendance({
    required String batchId,
  }) async {
    final QuerySnapshot<
        Map<String, dynamic>> snapshot =
    await _firestore
        .collection('attendance')
        .where(
      'studentId',
      isEqualTo: _uid,
    )
        .where(
      'batchId',
      isEqualTo: batchId,
    )
        .get();

    final List<AttendanceModel> records =
    snapshot.docs
        .map(
          (doc) =>
          AttendanceModel.fromFirestore(
            doc,
          ),
    )
        .toList();

    records.sort(
          (a, b) => b.date.compareTo(a.date),
    );

    return records;
  }

  // ============================================================
  // GET ALL MY ATTENDANCE
  // ============================================================

  Future<List<AttendanceModel>>
  getAllMyAttendance() async {
    final QuerySnapshot<
        Map<String, dynamic>> snapshot =
    await _firestore
        .collection('attendance')
        .where(
      'studentId',
      isEqualTo: _uid,
    )
        .get();

    final List<AttendanceModel> records =
    snapshot.docs
        .map(
          (doc) =>
          AttendanceModel.fromFirestore(
            doc,
          ),
    )
        .toList();

    records.sort(
          (a, b) => b.date.compareTo(a.date),
    );

    return records;
  }

  // ============================================================
  // GET MONTHLY ATTENDANCE
  // ============================================================

  Future<List<AttendanceModel>>
  getMonthlyAttendance({
    required String batchId,
    required int year,
    required int month,
  }) async {
    final List<AttendanceModel> records =
    await getMyAttendance(
      batchId: batchId,
    );

    return records.where(
          (record) {
        return record.date.year == year &&
            record.date.month == month;
      },
    ).toList();
  }

  // ============================================================
  // CALCULATE PERCENTAGE
  // ============================================================

  double calculatePercentage(
      List<AttendanceModel> records,
      ) {
    if (records.isEmpty) {
      return 0;
    }

    final int attended =
        records.where(
              (record) => record.isAttended,
        ).length;

    return (attended / records.length) * 100;
  }

  // ============================================================
  // COUNT STATUS
  // ============================================================

  int countStatus(
      List<AttendanceModel> records,
      String status,
      ) {
    return records.where(
          (record) =>
      record.status.toLowerCase() ==
          status.toLowerCase(),
    ).length;
  }

  // ============================================================
  // COUNT PRESENT
  // ============================================================

  int countPresent(
      List<AttendanceModel> records,
      ) {
    return records.where(
          (record) => record.isPresent,
    ).length;
  }

  // ============================================================
  // COUNT ABSENT
  // ============================================================

  int countAbsent(
      List<AttendanceModel> records,
      ) {
    return records.where(
          (record) => record.isAbsent,
    ).length;
  }

  // ============================================================
  // COUNT LEAVE
  // ============================================================

  int countLeave(
      List<AttendanceModel> records,
      ) {
    return records.where(
          (record) => record.isLeave,
    ).length;
  }

  // ============================================================
  // COUNT LATE
  // ============================================================

  int countLate(
      List<AttendanceModel> records,
      ) {
    return records.where(
          (record) => record.isLate,
    ).length;
  }
}