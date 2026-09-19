import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/collection_names.dart';

class CoordinatorReportData {
final int applicationsThisMonth;
final int acceptedStudents;
final double averageAttendance;
final int assignmentsPending;

const CoordinatorReportData({
required this.applicationsThisMonth,
required this.acceptedStudents,
required this.averageAttendance,
required this.assignmentsPending,
});
}

class CoordinatorReportService {
CoordinatorReportService._();

static final CoordinatorReportService instance =
CoordinatorReportService._();

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

// ============================================================
// GET REPORT
// ============================================================

Future<CoordinatorReportData> getReport() async {
try {
// ----------------------------------------------------------
// APPLICATIONS
// ----------------------------------------------------------

final QuerySnapshot<Map<String, dynamic>>
applicationsSnapshot =
await _firestore
    .collection(
CollectionNames.applications,
)
    .get();

// ----------------------------------------------------------
// ATTENDANCE
// ----------------------------------------------------------

final QuerySnapshot<Map<String, dynamic>>
attendanceSnapshot =
await _firestore
    .collection(
CollectionNames.attendance,
)
    .get();

// ----------------------------------------------------------
// ASSIGNMENTS
// ----------------------------------------------------------

final QuerySnapshot<Map<String, dynamic>>
assignmentsSnapshot =
await _firestore
    .collection(
CollectionNames.assignments,
)
    .get();

// ----------------------------------------------------------
// SUBMISSIONS
// ----------------------------------------------------------

final QuerySnapshot<Map<String, dynamic>>
submissionsSnapshot =
await _firestore
    .collection(
CollectionNames.submissions,
)
    .get();

// ==========================================================
// 1. APPLICATIONS THIS MONTH
// ==========================================================

final DateTime now = DateTime.now();

final int currentYear = now.year;
final int currentMonth = now.month;

int applicationsThisMonth = 0;

for (final doc in applicationsSnapshot.docs) {
final Map<String, dynamic> data = doc.data();

final DateTime? createdAt =
_parseDate(data['createdAt']);

if (createdAt == null) {
continue;
}

if (createdAt.year == currentYear &&
createdAt.month == currentMonth) {
applicationsThisMonth++;
}
}

// ==========================================================
// 2. ACCEPTED STUDENTS
// ==========================================================

int acceptedStudents = 0;

for (final doc in applicationsSnapshot.docs) {
final Map<String, dynamic> data = doc.data();

final String status =
(data['status'] ?? '')
    .toString()
    .trim()
    .toLowerCase();

if (status == 'accepted') {
acceptedStudents++;
}
}

// ==========================================================
// 3. AVERAGE ATTENDANCE
// ==========================================================
//
// Present / (Present + Absent + Late)
//
// Example:
//
// Present = 8
// Absent  = 1
// Late    = 1
//
// Attendance = 8 / 10 = 80%
//
// ==========================================================

int presentCount = 0;
int attendanceCount = 0;

for (final doc in attendanceSnapshot.docs) {
final Map<String, dynamic> data = doc.data();

final String status =
(data['status'] ?? '')
    .toString()
    .trim()
    .toLowerCase();

if (status == 'present' ||
status == 'absent' ||
status == 'late') {
attendanceCount++;

if (status == 'present') {
presentCount++;
}
}
}

double averageAttendance = 0;

if (attendanceCount > 0) {
averageAttendance =
(presentCount / attendanceCount) * 100;
}

// ==========================================================
// 4. PENDING ASSIGNMENTS
// ==========================================================
//
// AssignmentModel mein status/isCompleted nahi hai.
//
// Isliye submissions collection se determine karte hain.
//
// submitted / marked / late
// = assignment submitted
//
// No valid submission
// = assignment pending
//
// ==========================================================

final Set<String> submittedAssignmentIds =
<String>{};

for (final submissionDoc
in submissionsSnapshot.docs) {
final Map<String, dynamic> data =
submissionDoc.data();

final String assignmentId =
(data['assignmentId'] ?? '')
    .toString()
    .trim();

final String status =
(data['status'] ?? '')
    .toString()
    .trim()
    .toLowerCase();

if (assignmentId.isEmpty) {
continue;
}

if (status == 'submitted' ||
status == 'marked' ||
status == 'late') {
submittedAssignmentIds.add(
assignmentId,
);
}
}

int assignmentsPending = 0;

for (final assignmentDoc
in assignmentsSnapshot.docs) {
final String assignmentId =
assignmentDoc.id;

if (!submittedAssignmentIds.contains(
assignmentId,
)) {
assignmentsPending++;
}
}

// ==========================================================
// DEBUG
// ==========================================================

print('');
print('==========================================');
print('       COORDINATOR REPORT DATA');
print('==========================================');

print(
'Applications This Month: '
'$applicationsThisMonth',
);

print(
'Accepted Students: '
'$acceptedStudents',
);

print(
'Present Attendance Records: '
'$presentCount',
);

print(
'Total Attendance Records: '
'$attendanceCount',
);

print(
'Average Attendance: '
'${averageAttendance.toStringAsFixed(1)}%',
);

print(
'Total Assignments: '
'${assignmentsSnapshot.docs.length}',
);

print(
'Submitted Assignments: '
'${submittedAssignmentIds.length}',
);

print(
'Pending Assignments: '
'$assignmentsPending',
);

print('==========================================');
print('');

// ==========================================================
// RETURN
// ==========================================================

return CoordinatorReportData(
applicationsThisMonth:
applicationsThisMonth,
acceptedStudents:
acceptedStudents,
averageAttendance:
averageAttendance,
assignmentsPending:
assignmentsPending,
);
} catch (e, stackTrace) {
print('');
print(
'ERROR LOADING COORDINATOR REPORT:',
);
print(e);
print('');
print('StackTrace:');
print(stackTrace);
print('');

rethrow;
}
}

// ============================================================
// BACKWARD COMPATIBILITY
// ============================================================
//
// Agar project ki kisi aur file mein getReportData()
// use ho raha ho to woh bhi work karega.
//
// ============================================================

Future<CoordinatorReportData> getReportData() {
return getReport();
}

// ============================================================
// DATE PARSER
// ============================================================

DateTime? _parseDate(dynamic value) {
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
}
