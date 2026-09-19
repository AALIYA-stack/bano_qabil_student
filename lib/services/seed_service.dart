import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/seed_data/application_seed_data.dart';
import '../data/seed_data/assignment_seed_data.dart';
import '../data/seed_data/student_seed_data.dart';
import '../data/seed_data/submission_seed_data.dart';

class SeedService {
SeedService._();

static final SeedService instance = SeedService._();

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

final FirebaseAuth _auth =
FirebaseAuth.instance;

CollectionReference<Map<String, dynamic>> get _users =>
_firestore.collection('users');

CollectionReference<Map<String, dynamic>> get _applications =>
_firestore.collection('applications');

CollectionReference<Map<String, dynamic>> get _courses =>
_firestore.collection('courses');

CollectionReference<Map<String, dynamic>> get _campuses =>
_firestore.collection('campuses');

CollectionReference<Map<String, dynamic>> get _batches =>
_firestore.collection('batches');

CollectionReference<Map<String, dynamic>> get _assignments =>
_firestore.collection('assignments');

CollectionReference<Map<String, dynamic>> get _submissions =>
_firestore.collection('submissions');

// ============================================================
// AUTHENTICATION
// ============================================================

void _checkAuthentication() {
final User? user = _auth.currentUser;

if (user == null) {
throw Exception(
'No Firebase user is logged in. Please login first.',
);
}

print('');
print('Authenticated user: ${user.uid}');
print('Email: ${user.email ?? 'No email'}');
print('');
}

// ============================================================
// SEED ALL / DATA CHECK
// ============================================================

Future<void> seedAll() async {
print('');
print('==========================================');
print('       BANO QABIL DATA CHECK');
print('==========================================');

try {
_checkAuthentication();

print('');
print('Checking courses...');
await _checkCourses();

print('');
print('Checking campuses...');
await _checkCampuses();

print('');
print('Checking batches...');
await _checkBatches();

print('');
print('Checking assignments...');
await _checkAssignments();

print('');
print('Checking submissions...');
await _checkSubmissions();

print('');
print('Checking current student profile...');
await _checkCurrentStudent();

print('');
print('==========================================');
print('       DATA CHECK COMPLETED');
print('==========================================');
print('');
} catch (e, stackTrace) {
print('');
print('==========================================');
print('          DATA CHECK FAILED');
print('==========================================');
print('');
print('Error: $e');
print('');
print('StackTrace:');
print(stackTrace);
print('');
print('Data check error ignored.');
print('');
}
}

// ============================================================
// CURRENT STUDENT CHECK
// ============================================================

Future<void> _checkCurrentStudent() async {
final User? user = _auth.currentUser;

if (user == null) {
print('No current Firebase user.');
return;
}

final DocumentSnapshot<Map<String, dynamic>> doc =
await _users.doc(user.uid).get();

if (!doc.exists) {
print(
'Current student profile not found for UID: ${user.uid}',
);
return;
}

final Map<String, dynamic> data =
doc.data() ?? <String, dynamic>{};

print('');
print('Current Student Profile');
print('UID: ${user.uid}');
print('Name: ${data['name'] ?? ''}');
print('Email: ${data['email'] ?? ''}');
print('Role: ${data['role'] ?? ''}');
print('Course: ${data['courseId'] ?? ''}');
print('Batch: ${data['batchId'] ?? ''}');
print('Campus: ${data['campus'] ?? ''}');
print('');
}

// ============================================================
// COMPLETE DEMO SEED
// ============================================================

Future<void> seedDemoData() async {
print('');
print('==========================================');
print('       BANO QABIL DEMO SEED');
print('==========================================');

_checkAuthentication();

print('');
print('1. Checking courses...');
await _checkCourses();

print('');
print('2. Checking campuses...');
await _checkCampuses();

print('');
print('3. Checking batches...');
await _checkBatches();

print('');
print('4. Seeding students...');
await seedStudents();

print('');
print('5. Seeding applications...');
await seedApplications();

print('');
print('6. Seeding assignments...');
await seedAssignments();

print('');
print('7. Seeding submissions...');
await seedSubmissions();

print('');
print('8. Updating batch enrollments...');
await _updateAllStudentBatchEnrollments();

print('');
print('==========================================');
print('       DEMO SEED COMPLETED');
print('==========================================');
print('');
}

// ============================================================
// STUDENTS
// ============================================================

Future<void> seedStudents() async {
_checkAuthentication();

final WriteBatch batch = _firestore.batch();

int count = 0;

for (final student in StudentSeedData.students) {
final String id =
student['id'].toString();

final DocumentReference<Map<String, dynamic>> docRef =
_users.doc(id);

final Map<String, dynamic> data = {
'name': student['name'],
'phone': student['phone'],
'email': student['email'],
'role': 'student',
'city': student['city'],
'campus': student['campus'],
'isActive': true,
'photoUrl': student['photoUrl'],
'courseId': student['courseId'],
'batchId': student['batchId'],
'createdAt':
student['createdAt'] ?? Timestamp.now(),
};

batch.set(
docRef,
data,
SetOptions(merge: true),
);

count++;

print(
'Student prepared: $id '
'→ ${student['name']} '
'| course: ${student['courseId']} '
'| batch: ${student['batchId']}',
);
}

if (count > 0) {
await batch.commit();
}

print('');
print('Students seeded successfully: $count');
}

// ============================================================
// UPDATE ALL STUDENT BATCH ENROLLMENTS
// ============================================================

Future<void> _updateAllStudentBatchEnrollments() async {
print('');
print('==========================================');
print('    UPDATING STUDENT BATCH ENROLLMENTS');
print('==========================================');

final Set<String> batchIds = <String>{};

for (final student in StudentSeedData.students) {
final String batchId =
(student['batchId'] ?? '')
    .toString()
    .trim();

if (batchId.isNotEmpty) {
batchIds.add(batchId);
}
}

if (batchIds.isEmpty) {
print('No batchIds found in StudentSeedData.');
print('Nothing to update.');
return;
}

print('');
print('Student batch IDs found:');

for (final String batchId in batchIds) {
print('→ $batchId');
}

print('');

for (final String batchId in batchIds) {
await _updateSingleBatchEnrollment(batchId);
}

print('');
print('==========================================');
print('    BATCH ENROLLMENTS UPDATED');
print('==========================================');
print('');
}

// ============================================================
// UPDATE SINGLE BATCH ENROLLMENT
// ============================================================

Future<void> _updateSingleBatchEnrollment(
String batchId,
) async {
print('');
print('Updating batch enrollment...');
print('Batch: $batchId');

final DocumentReference<Map<String, dynamic>> batchRef =
_batches.doc(batchId);

final DocumentSnapshot<Map<String, dynamic>>
batchSnapshot =
await batchRef.get();

if (!batchSnapshot.exists) {
print(
'WARNING: Batch $batchId was not found.',
);
return;
}

final Map<String, dynamic> batchData =
batchSnapshot.data() ?? <String, dynamic>{};

final int seats =
_toInt(batchData['seats']);

int enrolledStudents = 0;

for (final student in StudentSeedData.students) {
final String studentBatchId =
(student['batchId'] ?? '')
    .toString()
    .trim();

if (studentBatchId == batchId) {
enrolledStudents++;
}
}

final int seatsLeft =
seats > enrolledStudents
? seats - enrolledStudents
    : 0;

await batchRef.set(
{
'enrolledStudents': enrolledStudents,
'seatsLeft': seatsLeft,
},
SetOptions(merge: true),
);

print('');
print('==========================================');
print('        BATCH ENROLLMENT UPDATED');
print('==========================================');
print('Batch ID: $batchId');
print('Total Seats: $seats');
print('Enrolled Students: $enrolledStudents');
print('Seats Left: $seatsLeft');
print('==========================================');
print('');
}

// ============================================================
// APPLICATIONS
// ============================================================

Future<void> seedApplications() async {
_checkAuthentication();

final WriteBatch batch = _firestore.batch();

int count = 0;

for (final application
in ApplicationSeedData.applications) {
final String id =
application['id'].toString();

final DocumentReference<Map<String, dynamic>>
docRef =
_applications.doc(id);

final Map<String, dynamic> data =
ApplicationSeedData.toFirestore(
application,
);

batch.set(
docRef,
data,
SetOptions(merge: true),
);

count++;

print(
'Application prepared: $id '
'→ ${application['fullName']} '
'| course: ${application['courseId']} '
'| batch: ${application['batchId']} '
'| status: ${application['status']}',
);
}

if (count > 0) {
await batch.commit();
}

print('');
print(
'Applications seeded successfully: $count',
);
}

// ============================================================
// ASSIGNMENTS
// ============================================================

Future<void> seedAssignments() async {
_checkAuthentication();

final WriteBatch batch =
_firestore.batch();

int count = 0;

final User? currentUser =
_auth.currentUser;

final String createdBy =
currentUser?.uid ?? '';

for (final assignment
in AssignmentSeedData.assignments) {
final String id =
assignment['id'].toString();

final DocumentReference<Map<String, dynamic>>
docRef =
_assignments.doc(id);

final Map<String, dynamic> data = {
'batchId':
assignment['batchId'],
'courseId':
assignment['courseId'],
'title':
assignment['title'],
'description':
assignment['description'],
'instructions':
assignment['instructions'],
'dueDate':
assignment['dueDate'],
'totalMarks':
assignment['totalMarks'],
'createdBy':
createdBy.isNotEmpty
? createdBy
    : assignment['createdBy'],
'createdAt':
assignment['createdAt'] ??
Timestamp.now(),
'isQuiz':
assignment['isQuiz'] ?? false,
};

batch.set(
docRef,
data,
SetOptions(merge: true),
);

count++;

print(
'Assignment prepared: $id '
'→ ${assignment['title']}',
);
}

if (count > 0) {
await batch.commit();
}

print('');
print(
'Assignments seeded successfully: $count',
);
}

// ============================================================
// SUBMISSIONS
// ============================================================

Future<void> seedSubmissions() async {
_checkAuthentication();

final WriteBatch batch =
_firestore.batch();

int count = 0;

final User? currentUser =
_auth.currentUser;

final String currentUid =
currentUser?.uid ?? '';

for (final submission
in SubmissionSeedData.submissions) {
final String id =
submission['id'].toString();

final DocumentReference<Map<String, dynamic>>
docRef =
_submissions.doc(id);

final String originalMarkedBy =
submission['markedBy']
    ?.toString() ??
'';

final Map<String, dynamic> data = {
'assignmentId':
submission['assignmentId'],
'studentId':
submission['studentId'],
'batchId':
submission['batchId'],
'answerText':
submission['answerText'],
'fileUrl':
submission['fileUrl'],
'fileName':
submission['fileName'],
'status':
submission['status'],
'submittedAt':
submission['submittedAt'],
'marks':
submission['marks'],
'feedback':
submission['feedback'],
'markedAt':
submission['markedAt'],
'markedBy':
originalMarkedBy.isNotEmpty
? originalMarkedBy
    : (submission['status'] == 'marked'
? currentUid
    : null),
};

batch.set(
docRef,
data,
SetOptions(merge: true),
);

count++;

print(
'Submission prepared: $id '
'| assignment: ${submission['assignmentId']} '
'| student: ${submission['studentId']} '
'| status: ${submission['status']}',
);
}

if (count > 0) {
await batch.commit();
}

print('');
print(
'Submissions seeded successfully: $count',
);
}

// ============================================================
// COURSE CHECK
// ============================================================

Future<void> _checkCourses() async {
final QuerySnapshot<Map<String, dynamic>>
snapshot =
await _courses.get();

print(
'Courses found: ${snapshot.docs.length}',
);

if (snapshot.docs.isEmpty) {
print(
'WARNING: No courses found in Firestore.',
);
return;
}

for (final doc in snapshot.docs) {
final Map<String, dynamic> data =
doc.data();

final dynamic title =
data['title'] ??
data['name'] ??
'Unknown Course';

final dynamic isActive =
data['isActive'] ?? false;

print(
'Course: ${doc.id} '
'| $title '
'| isActive: $isActive',
);
}
}

// ============================================================
// CAMPUS CHECK
// ============================================================

Future<void> _checkCampuses() async {
final QuerySnapshot<Map<String, dynamic>>
snapshot =
await _campuses.get();

print(
'Campuses found: ${snapshot.docs.length}',
);

if (snapshot.docs.isEmpty) {
print(
'WARNING: No campuses found in Firestore.',
);
return;
}

for (final doc in snapshot.docs) {
final Map<String, dynamic> data =
doc.data();

final dynamic name =
data['name'] ?? 'Unknown Campus';

final dynamic city =
data['city'] ?? '';

final dynamic isActive =
data['isActive'] ?? false;

print(
'Campus: ${doc.id} '
'| $name '
'| city: $city '
'| isActive: $isActive',
);
}
}

// ============================================================
// BATCH CHECK
// ============================================================

Future<void> _checkBatches() async {
final QuerySnapshot<Map<String, dynamic>>
snapshot =
await _batches.get();

print(
'Batches found: ${snapshot.docs.length}',
);

if (snapshot.docs.isEmpty) {
print(
'WARNING: No batches found in Firestore.',
);
return;
}

for (final doc in snapshot.docs) {
final Map<String, dynamic> data =
doc.data();

final dynamic courseId =
data['courseId'] ?? '';

final dynamic campusId =
data['campusId'] ?? '';

final dynamic isOpen =
data['isOpen'] ?? false;

final int seats =
_toInt(data['seats']);

final int enrolled =
_toInt(data['enrolledStudents']);

final int seatsLeft =
data['seatsLeft'] != null
? _toInt(data['seatsLeft'])
    : (seats - enrolled > 0
? seats - enrolled
    : 0);

print(
'Batch: ${doc.id} '
'| courseId: $courseId '
'| campusId: $campusId '
'| isOpen: $isOpen '
'| seats: $seats '
'| enrolled: $enrolled '
'| seatsLeft: $seatsLeft',
);
}
}

// ============================================================
// ASSIGNMENT CHECK
// ============================================================

Future<void> _checkAssignments() async {
final QuerySnapshot<Map<String, dynamic>>
snapshot =
await _assignments.get();

print(
'Assignments found: ${snapshot.docs.length}',
);

if (snapshot.docs.isEmpty) {
print(
'WARNING: No assignments found in Firestore.',
);
return;
}

for (final doc in snapshot.docs) {
final Map<String, dynamic> data =
doc.data();

print(
'Assignment: ${doc.id} '
'| title: ${data['title'] ?? ''} '
'| batchId: ${data['batchId'] ?? ''} '
'| courseId: ${data['courseId'] ?? ''}',
);
}
}

// ============================================================
// SUBMISSION CHECK
// ============================================================

Future<void> _checkSubmissions() async {
final QuerySnapshot<Map<String, dynamic>>
snapshot =
await _submissions.get();

print(
'Submissions found: ${snapshot.docs.length}',
);

if (snapshot.docs.isEmpty) {
print(
'WARNING: No submissions found in Firestore.',
);
return;
}

for (final doc in snapshot.docs) {
final Map<String, dynamic> data =
doc.data();

print(
'Submission: ${doc.id} '
'| assignmentId: ${data['assignmentId'] ?? ''} '
'| studentId: ${data['studentId'] ?? ''} '
'| status: ${data['status'] ?? ''} '
'| marks: ${data['marks'] ?? '-'}',
);
}
}

// ============================================================
// ONLY STUDENTS
// ============================================================

Future<void> seedOnlyStudents() async {
print('');
print('==========================================');
print('        STUDENT SEED STARTED');
print('==========================================');

try {
_checkAuthentication();

await seedStudents();

print('');
print(
'Student seed completed successfully.',
);
} catch (e) {
print('');
print('Student seed failed: $e');
rethrow;
}
}

// ============================================================
// ONLY APPLICATIONS
// ============================================================

Future<void> seedOnlyApplications() async {
print('');
print('==========================================');
print('      APPLICATION SEED STARTED');
print('==========================================');

try {
_checkAuthentication();

await seedApplications();

print('');
print(
'Application seed completed successfully.',
);
} catch (e) {
print('');
print('Application seed failed: $e');
rethrow;
}
}

// ============================================================
// ONLY ASSIGNMENTS
// ============================================================

Future<void> seedOnlyAssignments() async {
print('');
print('==========================================');
print('       ASSIGNMENT SEED STARTED');
print('==========================================');

try {
_checkAuthentication();

await seedAssignments();

print('');
print(
'Assignment seed completed successfully.',
);
} catch (e) {
print('');
print('Assignment seed failed: $e');
rethrow;
}
}

// ============================================================
// ONLY SUBMISSIONS
// ============================================================

Future<void> seedOnlySubmissions() async {
print('');
print('==========================================');
print('       SUBMISSION SEED STARTED');
print('==========================================');

try {
_checkAuthentication();

await seedSubmissions();

print('');
print(
'Submission seed completed successfully.',
);
} catch (e) {
print('');
print('Submission seed failed: $e');
rethrow;
}
}

// ============================================================
// DELETE STUDENTS
// ============================================================

Future<void> deleteSeedStudents() async {
_checkAuthentication();

final WriteBatch batch =
_firestore.batch();

int count = 0;

for (final student
in StudentSeedData.students) {
final String id =
student['id'].toString();

batch.delete(
_users.doc(id),
);

count++;

print(
'Student marked for deletion: $id',
);
}

if (count > 0) {
await batch.commit();
}

print('');
print(
'Demo students deleted: $count',
);

await _updateAllStudentBatchEnrollments();
}

// ============================================================
// DELETE APPLICATIONS
// ============================================================

Future<void> deleteSeedApplications() async {
_checkAuthentication();

final WriteBatch batch =
_firestore.batch();

int count = 0;

for (final application
in ApplicationSeedData.applications) {
final String id =
application['id'].toString();

batch.delete(
_applications.doc(id),
);

count++;

print(
'Application marked for deletion: $id',
);
}

if (count > 0) {
await batch.commit();
}

print('');
print(
'Demo applications deleted: $count',
);
}

// ============================================================
// DELETE ASSIGNMENTS
// ============================================================

Future<void> deleteSeedAssignments() async {
_checkAuthentication();

final WriteBatch batch =
_firestore.batch();

int count = 0;

for (final assignment
in AssignmentSeedData.assignments) {
final String id =
assignment['id'].toString();

batch.delete(
_assignments.doc(id),
);

count++;

print(
'Assignment marked for deletion: $id',
);
}

if (count > 0) {
await batch.commit();
}

print('');
print(
'Demo assignments deleted: $count',
);
}

// ============================================================
// DELETE SUBMISSIONS
// ============================================================

Future<void> deleteSeedSubmissions() async {
_checkAuthentication();

final WriteBatch batch =
_firestore.batch();

int count = 0;

for (final submission
in SubmissionSeedData.submissions) {
final String id =
submission['id'].toString();

batch.delete(
_submissions.doc(id),
);

count++;

print(
'Submission marked for deletion: $id',
);
}

if (count > 0) {
await batch.commit();
}

print('');
print(
'Demo submissions deleted: $count',
);
}

// ============================================================
// DELETE COMPLETE DEMO DATA
// ============================================================

Future<void> deleteSeedData() async {
print('');
print('==========================================');
print('       DELETE DEMO DATA STARTED');
print('==========================================');

try {
_checkAuthentication();

print('');
print('Deleting demo submissions...');
await deleteSeedSubmissions();

print('');
print('Deleting demo assignments...');
await deleteSeedAssignments();

print('');
print('Deleting demo students...');
await deleteSeedStudents();

print('');
print('Deleting demo applications...');
await deleteSeedApplications();

print('');
print('==========================================');
print('       DEMO DATA DELETED');
print('==========================================');
print('');
} catch (e) {
print('');
print(
'Delete seed data failed: $e',
);
rethrow;
}
}

// ============================================================
// INTEGER HELPER
// ============================================================

int _toInt(dynamic value) {
if (value is int) {
return value;
}

if (value is num) {
return value.toInt();
}

if (value is String) {
return int.tryParse(value) ?? 0;
}

return 0;
}
}
