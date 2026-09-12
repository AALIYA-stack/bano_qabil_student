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
final Map<String, dynamic> data = doc.data() ?? {};

return AttendanceModel(
id: doc.id,

studentId: data['studentId']?.toString() ?? '',

batchId: data['batchId']?.toString() ?? '',

date: _parseDate(data['date']),

status: _normalizeStatus(
data['status'],
),

markedBy: data['markedBy']?.toString() ?? '',

createdAt: _parseNullableDate(
data['createdAt'],
),
);
}

// ============================================================
// STATUS NORMALIZER
// ============================================================

static String _normalizeStatus(dynamic value) {
final String status =
value?.toString().trim().toLowerCase() ?? '';

switch (status) {
case 'present':
return 'present';

case 'absent':
return 'absent';

case 'late':
return 'late';

case 'leave':
return 'leave';

default:
return 'unknown';
}
}

// ============================================================
// DATE PARSER
// ============================================================

static DateTime _parseDate(dynamic value) {
if (value is Timestamp) {
return value.toDate();
}

if (value is DateTime) {
return value;
}

if (value is String) {
final DateTime? parsed = DateTime.tryParse(value);

if (parsed != null) {
return parsed;
}
}

// Firestore record mein date missing ho to
// app crash nahi karegi.
return DateTime.fromMillisecondsSinceEpoch(0);
}

static DateTime? _parseNullableDate(dynamic value) {
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

bool get isPresent => status == 'present';

bool get isAbsent => status == 'absent';

bool get isLeave => status == 'leave';

bool get isLate => status == 'late';

/// Present aur Late dono attendance mein count honge.
bool get isAttended => isPresent || isLate;

// ============================================================
// DISPLAY HELPERS
// ============================================================

String get statusLabel {
switch (status) {
case 'present':
return 'Present';

case 'absent':
return 'Absent';

case 'late':
return 'Late';

case 'leave':
return 'Leave';

default:
return 'Unknown';
}
}
}

