import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String studentId;
  final String batchId;
  final DateTime date;
  final String status;
  final String markedBy;
  final DateTime? createdAt;

  const AttendanceModel({
    required this.id,
    required this.studentId,
    required this.batchId,
    required this.date,
    required this.status,
    required this.markedBy,
    this.createdAt,
  });

  // ============================================================
  // FROM FIRESTORE
  // ============================================================

  factory AttendanceModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final Map<String, dynamic> data =
        doc.data() ?? {};

    return AttendanceModel(
      id: doc.id,

      studentId:
      data['studentId']?.toString() ?? '',

      batchId:
      data['batchId']?.toString() ?? '',

      date: _parseDate(
        data['date'],
      ),

      status:
      data['status']?.toString().toLowerCase() ??
          'absent',

      markedBy:
      data['markedBy']?.toString() ?? '',

      createdAt:
      _parseNullableDate(
        data['createdAt'],
      ),
    );
  }

  // ============================================================
  // DATE PARSER
  // ============================================================

  static DateTime _parseDate(
      dynamic value,
      ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      final parsed =
      DateTime.tryParse(value);

      if (parsed != null) {
        return parsed;
      }
    }

    return DateTime.now();
  }

  static DateTime? _parseNullableDate(
      dynamic value,
      ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  // ============================================================
  // TO FIRESTORE
  // ============================================================

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'batchId': batchId,
      'date': Timestamp.fromDate(date),
      'status': status,
      'markedBy': markedBy,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  bool get isPresent =>
      status.toLowerCase() == 'present';

  bool get isAbsent =>
      status.toLowerCase() == 'absent';

  bool get isLeave =>
      status.toLowerCase() == 'leave';

  bool get isLate =>
      status.toLowerCase() == 'late';

  bool get isAttended =>
      isPresent || isLate;
}