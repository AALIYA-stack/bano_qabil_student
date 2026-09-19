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
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  // ============================================================
  // GET CURRENT USER BATCH ID
  // ============================================================

  Future<String?> getCurrentBatchId() async {
    final DocumentSnapshot<Map<String, dynamic>> userDoc =
    await _firestore
        .collection('users')
        .doc(_uid)
        .get();

    if (!userDoc.exists) {
      return null;
    }

    final Map<String, dynamic>? data = userDoc.data();

    if (data == null) {
      return null;
    }

    String batchId =
        data['batchId']?.toString().trim() ?? '';

    // Old field support
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

  Stream<List<AttendanceModel>> getMyAttendanceStream({
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
        .where(
      'batchId',
      isEqualTo: requiredBatchId,
    )
        .snapshots()
        .map(
          (
          QuerySnapshot<Map<String, dynamic>> snapshot,
          ) {
        final List<AttendanceModel> records =
        snapshot.docs
            .map(
              (doc) =>
              AttendanceModel.fromFirestore(doc),
        )
            .toList();

        records.sort(
              (a, b) => b.date.compareTo(a.date),
        );

        return records;
      },
    );
  }

  // ============================================================
  // GET MY ATTENDANCE
  // ============================================================

  Future<List<AttendanceModel>> getMyAttendance({
    required String batchId,
  }) async {
    final String requiredBatchId =
    batchId.trim();

    if (requiredBatchId.isEmpty) {
      return const <AttendanceModel>[];
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await _firestore
        .collection('attendance')
        .where(
      'studentId',
      isEqualTo: _uid,
    )
        .where(
      'batchId',
      isEqualTo: requiredBatchId,
    )
        .get();

    final List<AttendanceModel> records =
    snapshot.docs
        .map(
          (doc) =>
          AttendanceModel.fromFirestore(doc),
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
    final QuerySnapshot<Map<String, dynamic>> snapshot =
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
          AttendanceModel.fromFirestore(doc),
    )
        .toList();

    records.sort(
          (a, b) => b.date.compareTo(a.date),
    );

    return records;
  }

  // ============================================================
  // MONTHLY ATTENDANCE
  // ============================================================

  Future<List<AttendanceModel>> getMonthlyAttendance({
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
      print('ATTENDANCE: No records found');
      return 0.0;
    }

    final int present = records
        .where(
          (record) => record.isPresent,
    )
        .length;

    final int late = records
        .where(
          (record) => record.isLate,
    )
        .length;

    final int absent = records
        .where(
          (record) => record.isAbsent,
    )
        .length;

    final int leave = records
        .where(
          (record) => record.isLeave,
    )
        .length;

    final int attended =
        present + late;

    print(
      '================ ATTENDANCE DEBUG ================',
    );

    print('Student UID: $_uid');
    print('Total records: ${records.length}');
    print('Present: $present');
    print('Late: $late');
    print('Absent: $absent');
    print('Leave: $leave');
    print('Attended: $attended');

    for (final record in records) {
      print(
        'DATE: ${record.date} | '
            'BATCH: ${record.batchId} | '
            'STATUS: ${record.status}',
      );
    }

    final double percentage =
        (attended / records.length) * 100;

    print(
      'Attendance Percentage: $percentage%',
    );

    print(
      '==================================================',
    );

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

  // ============================================================
  // INSTRUCTOR: GET BATCH STUDENTS
  // ============================================================

  Future<List<Map<String, dynamic>>> getBatchStudents({
    required String batchId,
  }) async {
    final String requiredBatchId =
    batchId.trim();

    if (requiredBatchId.isEmpty) {
      print(
        'ATTENDANCE STUDENT DEBUG: Empty batch ID',
      );

      return const <Map<String, dynamic>>[];
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await _firestore
        .collection('users')
        .where(
      'role',
      isEqualTo: 'student',
    )
        .where(
      'batchId',
      isEqualTo: requiredBatchId,
    )
        .get();

    // ==========================================================
    // DEBUG
    // ==========================================================

    print(
      '==============================================',
    );

    print(
      'ATTENDANCE STUDENT DEBUG',
    );

    print(
      'Requested Batch ID: $requiredBatchId',
    );

    print(
      'Students Found: ${snapshot.docs.length}',
    );

    print(
      '==============================================',
    );

    // ==========================================================
    // BUILD STUDENT LIST
    // ==========================================================

    final List<Map<String, dynamic>> students =
    snapshot.docs.map(
          (doc) {
        final Map<String, dynamic> data =
        doc.data();

        print(
          'Student: ${doc.id} | '
              'Name: ${data['name']} | '
              'Role: ${data['role']} | '
              'Batch: ${data['batchId']} | '
              'Course: ${data['courseId']}',
        );

        return {
          'id': doc.id,
          'name':
          (data['name'] ?? 'Student').toString(),
          'email':
          (data['email'] ?? '').toString(),
        };
      },
    ).toList();

    // ==========================================================
    // SORT BY NAME
    // ==========================================================

    students.sort(
          (a, b) => a['name']
          .toString()
          .toLowerCase()
          .compareTo(
        b['name']
            .toString()
            .toLowerCase(),
      ),
    );

    print(
      '==============================================',
    );

    print(
      'FINAL ATTENDANCE STUDENT COUNT: '
          '${students.length}',
    );

    print(
      '==============================================',
    );

    return students;
  }

  // ============================================================
  // INSTRUCTOR: SAVE / UPDATE ATTENDANCE
  // ============================================================

  Future<void> saveAttendance({
    required String studentId,
    required String batchId,
    required String courseId,
    required String courseName,
    required DateTime date,
    required String status,
  }) async {
    final String requiredStudentId =
    studentId.trim();

    final String requiredBatchId =
    batchId.trim();

    final String requiredCourseId =
    courseId.trim();

    if (requiredStudentId.isEmpty ||
        requiredBatchId.isEmpty ||
        requiredCourseId.isEmpty) {
      throw Exception(
        'Student, batch and course information is required.',
      );
    }

    // Start of selected day
    final DateTime startOfDay = DateTime(
      date.year,
      date.month,
      date.day,
    );

    // Start of next day
    final DateTime startOfNextDay =
    startOfDay.add(
      const Duration(days: 1),
    );

    // ==========================================================
    // FIND EXISTING ATTENDANCE
    // ==========================================================

    final QuerySnapshot<Map<String, dynamic>> existing =
    await _firestore
        .collection('attendance')
        .where(
      'studentId',
      isEqualTo: requiredStudentId,
    )
        .where(
      'batchId',
      isEqualTo: requiredBatchId,
    )
        .where(
      'date',
      isGreaterThanOrEqualTo:
      Timestamp.fromDate(startOfDay),
    )
        .where(
      'date',
      isLessThan:
      Timestamp.fromDate(startOfNextDay),
    )
        .limit(1)
        .get();

    // ==========================================================
    // ATTENDANCE DATA
    // ==========================================================

    final Map<String, dynamic> attendanceData = {
      'studentId': requiredStudentId,
      'batchId': requiredBatchId,
      'courseId': requiredCourseId,
      'courseName': courseName,
      'date': Timestamp.fromDate(startOfDay),
      'status': status.trim().toLowerCase(),

      // Instructor who marked attendance
      'markedBy': _uid,

      'updatedAt':
      FieldValue.serverTimestamp(),
    };

    // ==========================================================
    // UPDATE EXISTING
    // ==========================================================

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update(
        attendanceData,
      );
    }

    // ==========================================================
    // CREATE NEW
    // ==========================================================

    else {
      await _firestore
          .collection('attendance')
          .add({
        ...attendanceData,
        'createdAt':
        FieldValue.serverTimestamp(),
      });
    }

    print(
      '✅ Attendance saved successfully: '
          '$requiredStudentId → $status',
    );
  }
}