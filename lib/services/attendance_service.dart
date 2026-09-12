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
  // GET CURRENT STUDENT BATCH ID
  // ============================================================

  Future<String?> getCurrentBatchId() async {
    final DocumentSnapshot<Map<String, dynamic>>
    userDoc =
    await _firestore
        .collection('users')
        .doc(_uid)
        .get();

    if (!userDoc.exists) {
      return null;
    }

    final Map<String, dynamic>? data =
    userDoc.data();

    if (data == null) {
      return null;
    }

    // First try correct field.
    String batchId =
        data['batchId']?.toString().trim() ?? '';

    // Support old Firestore field too.
    if (batchId.isEmpty) {
      batchId =
          data['batchid']?.toString().trim() ?? '';
    }

    if (batchId.isEmpty) {
      return null;
    }

    return batchId;
  }

  // ============================================================
  // REAL-TIME MY ATTENDANCE
  // ============================================================

  Stream<List<AttendanceModel>>
  getMyAttendanceStream({
    required String batchId,
  }) {
    final String requiredBatchId =
    batchId.trim();

    if (requiredBatchId.isEmpty) {
      return Stream.value(
        const <AttendanceModel>[],
      );
    }

    return _firestore
        .collection('attendance')
        .where(
      'studentId',
      isEqualTo: _uid,
    )
        .snapshots()
        .map(
          (
          QuerySnapshot<Map<String, dynamic>>
          snapshot,
          ) {
        final List<AttendanceModel> records =
        snapshot.docs
            .map(
              (doc) =>
              AttendanceModel
                  .fromFirestore(doc),
        )
            .where(
              (record) =>
          record.studentId == _uid &&
              record.batchId ==
                  requiredBatchId,
        )
            .toList();

        records.sort(
              (a, b) =>
              b.date.compareTo(a.date),
        );

        return records;
      },
    );
  }

  // ============================================================
  // GET MY ATTENDANCE
  // ============================================================

  Future<List<AttendanceModel>>
  getMyAttendance({
    required String batchId,
  }) async {
    final String requiredBatchId =
    batchId.trim();

    if (requiredBatchId.isEmpty) {
      return const <AttendanceModel>[];
    }

    final QuerySnapshot<Map<String, dynamic>>
    snapshot =
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
        .where(
          (record) =>
      record.studentId == _uid &&
          record.batchId ==
              requiredBatchId,
    )
        .toList();

    records.sort(
          (a, b) =>
          b.date.compareTo(a.date),
    );

    return records;
  }

  // ============================================================
  // GET ALL MY ATTENDANCE
  // ============================================================

  Future<List<AttendanceModel>>
  getAllMyAttendance() async {
    final QuerySnapshot<Map<String, dynamic>>
    snapshot =
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
          (a, b) =>
          b.date.compareTo(a.date),
    );

    return records;
  }

  // ============================================================
  // MONTHLY ATTENDANCE
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
  // CALCULATE ATTENDANCE PERCENTAGE
  // ============================================================

  double calculatePercentage(
      List<AttendanceModel> records,
      ) {
    if (records.isEmpty) {
      return 0.0;
    }

    final int attended =
        records.where(
              (record) => record.isAttended,
        ).length;

    final double percentage =
        (attended / records.length) * 100;

    return percentage
        .clamp(0.0, 100.0)
        .toDouble();
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
  // PRESENT
  // ============================================================

  int countPresent(
      List<AttendanceModel> records,
      ) {
    return records.where(
          (record) => record.isPresent,
    ).length;
  }

  // ============================================================
  // ABSENT
  // ============================================================

  int countAbsent(
      List<AttendanceModel> records,
      ) {
    return records.where(
          (record) => record.isAbsent,
    ).length;
  }

  // ============================================================
  // LEAVE
  // ============================================================

  int countLeave(
      List<AttendanceModel> records,
      ) {
    return records.where(
          (record) => record.isLeave,
    ).length;
  }

  // ============================================================
  // LATE
  // ============================================================

  int countLate(
      List<AttendanceModel> records,
      ) {
    return records.where(
          (record) => record.isLate,
    ).length;
  }
}