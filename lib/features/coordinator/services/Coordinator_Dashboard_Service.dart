import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/collection_names.dart';

class CoordinatorDashboardData {
final int applications;
final int activeBatches;
final int students;
final int pendingWork;

const CoordinatorDashboardData({
required this.applications,
required this.activeBatches,
required this.students,
required this.pendingWork,
});
}

class CoordinatorDashboardService {
CoordinatorDashboardService._();

static final CoordinatorDashboardService instance =
CoordinatorDashboardService._();

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

// ============================================================
// DASHBOARD DATA
// ============================================================

Future<CoordinatorDashboardData> getDashboardData() async {
try {
// ----------------------------------------------------------
// 1. APPLICATIONS
// ----------------------------------------------------------

final QuerySnapshot<Map<String, dynamic>>
applicationsSnapshot =
await _firestore
    .collection(
CollectionNames.applications,
)
    .get();

// ----------------------------------------------------------
// 2. ACTIVE BATCHES
// ----------------------------------------------------------

final QuerySnapshot<Map<String, dynamic>>
batchesSnapshot =
await _firestore
    .collection(
CollectionNames.batches,
)
    .where(
'isOpen',
isEqualTo: true,
)
    .get();

// ----------------------------------------------------------
// 3. ASSIGNMENTS
// ----------------------------------------------------------

final QuerySnapshot<Map<String, dynamic>>
assignmentsSnapshot =
await _firestore
    .collection(
CollectionNames.assignments,
)
    .get();

// ----------------------------------------------------------
// 4. SUBMISSIONS
// ----------------------------------------------------------

final QuerySnapshot<Map<String, dynamic>>
submissionsSnapshot =
await _firestore
    .collection(
CollectionNames.submissions,
)
    .get();

// ----------------------------------------------------------
// APPLICATION COUNT
// ----------------------------------------------------------

final int applications =
applicationsSnapshot.docs.length;

// ----------------------------------------------------------
// ACTIVE BATCH COUNT
// ----------------------------------------------------------

final int activeBatches =
batchesSnapshot.docs.length;

// ==========================================================
// STUDENTS
// ==========================================================
//
// Coordinator ko users collection ke tamam student
// documents read karne ki zarurat nahi.
//
// Accepted applications ko enrolled/accepted students
// ke dashboard count ke liye use karte hain.
//
// ==========================================================

int students = 0;

final Set<String> acceptedStudentIds =
<String>{};

for (final applicationDoc
in applicationsSnapshot.docs) {
final Map<String, dynamic> data =
applicationDoc.data();

final String status =
(data['status'] ?? '')
    .toString()
    .trim()
    .toLowerCase();

final String studentId =
(data['studentId'] ?? '')
    .toString()
    .trim();

if (status == 'accepted') {
if (studentId.isNotEmpty) {
acceptedStudentIds.add(studentId);
}
}
}

students = acceptedStudentIds.length;

// ==========================================================
// SUBMITTED ASSIGNMENT IDS
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

// ==========================================================
// PENDING WORK
// ==========================================================

int pendingWork = 0;

for (final assignmentDoc
in assignmentsSnapshot.docs) {
final String assignmentId =
assignmentDoc.id;

if (!submittedAssignmentIds.contains(
assignmentId,
)) {
pendingWork++;
}
}

// ==========================================================
// DEBUG
// ==========================================================

print('');
print('==========================================');
print('     COORDINATOR DASHBOARD DATA');
print('==========================================');

print(
'Applications: $applications',
);

print(
'Active Batches: $activeBatches',
);

print(
'Accepted Students: $students',
);

print(
'Assignments: '
'${assignmentsSnapshot.docs.length}',
);

print(
'Submitted Assignments: '
'${submittedAssignmentIds.length}',
);

print(
'Pending Assignments: '
'$pendingWork',
);

print('==========================================');
print('');

// ==========================================================
// RETURN
// ==========================================================

return CoordinatorDashboardData(
applications: applications,
activeBatches: activeBatches,
students: students,
pendingWork: pendingWork,
);
} catch (e, stackTrace) {
print('');
print(
'ERROR LOADING COORDINATOR DASHBOARD:',
);
print(e);
print('');
print('StackTrace:');
print(stackTrace);
print('');

rethrow;
}
}
}
