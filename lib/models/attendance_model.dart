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

  factory AttendanceModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return AttendanceModel(
      id: doc.id,
      studentId: data['studentId']?.toString() ?? '',
      batchId: data['batchId']?.toString() ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status']?.toString() ?? 'absent',
      markedBy: data['markedBy']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

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

  bool get isPresent => status == 'present';

  bool get isAbsent => status == 'absent';

  bool get isLeave => status == 'leave';

  bool get isLate => status == 'late';
}