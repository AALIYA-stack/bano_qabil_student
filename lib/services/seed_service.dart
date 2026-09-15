import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/seed_data/application_seed_data.dart';
import '../data/seed_data/student_seed_data.dart';

class SeedService {
SeedService._();

static final SeedService instance = SeedService._();

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

final FirebaseAuth _auth =
FirebaseAuth.instance;

// ============================================================
// COLLECTIONS
// ============================================================

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

// ============================================================
// AUTH CHECK
// ============================================================

void _checkAuthentication() {
final user = _auth.currentUser;

if (user == null) {
throw Exception(
'No Firebase user is logged in. '
'Please login first and then run seed.',
);
}

print('');
print('Authenticated user: ${user.uid}');
print('Email: ${user.email ?? 'No email'}');
print('');
}

// ============================================================
// SEED ALL
// ============================================================

Future<void> seedAll() async {
print('');
print('==========================================');
print('           BANO QABIL SEED');
print('==========================================');

try {
// --------------------------------------------------------
// AUTH
// --------------------------------------------------------

print('');
print('Checking Firebase Authentication...');
_checkAuthentication();

// --------------------------------------------------------
// COURSES
// --------------------------------------------------------

print('');
print('1. Checking courses...');
await _checkCourses();

// --------------------------------------------------------
// CAMPUSES
// --------------------------------------------------------

print('');
print('2. Checking campuses...');
await _checkCampuses();

// --------------------------------------------------------
// BATCHES
// --------------------------------------------------------

print('');
print('3. Checking batches...');
await _checkBatches();

// --------------------------------------------------------
// STUDENTS
// --------------------------------------------------------

print('');
print('4. Seeding students...');
await seedStudents();

// --------------------------------------------------------
// APPLICATIONS
// --------------------------------------------------------

print('');
print('5. Seeding applications...');
await seedApplications();

// --------------------------------------------------------
// SUCCESS
// --------------------------------------------------------

print('');
print('==========================================');
print('       SEED COMPLETED SUCCESSFULLY');
print('==========================================');
print('');
} catch (e, stackTrace) {
print('');
print('==========================================');
print('             SEED FAILED');
print('==========================================');

print('');
print('Error: $e');

print('');
print('StackTrace:');
print(stackTrace);

print('');
print('==========================================');

rethrow;
}
}

// ============================================================
// STUDENTS
// ============================================================

Future<void> seedStudents() async {
_checkAuthentication();

final WriteBatch batch = _firestore.batch();

int count = 0;

// ----------------------------------------------------------
// CREATE / UPDATE STUDENT DOCUMENTS
// ----------------------------------------------------------

for (final student in StudentSeedData.students) {
final String id = student['id'].toString();

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
'createdAt': student['createdAt'] ?? Timestamp.now(),
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

// ----------------------------------------------------------
// COMMIT STUDENTS
// ----------------------------------------------------------

if (count > 0) {
await batch.commit();
}

print('');
print('Students seeded successfully: $count');

// ----------------------------------------------------------
// UPDATE BATCH ENROLLMENT
// ----------------------------------------------------------

await _updateStudentBatchEnrollment();
}

// ============================================================
// UPDATE STUDENT BATCH ENROLLMENT
// ============================================================

Future<void> _updateStudentBatchEnrollment() async {
const String batchId = 'flutter-batch-01';

print('');
print('Updating batch enrollment...');
print('Batch: $batchId');

final DocumentReference<Map<String, dynamic>> batchRef =
_batches.doc(batchId);

final DocumentSnapshot<Map<String, dynamic>> batchSnapshot =
await batchRef.get();

if (!batchSnapshot.exists) {
print(
'WARNING: Batch $batchId was not found.',
);

return;
}

final Map<String, dynamic> batchData =
batchSnapshot.data() ?? {};

final int seats = _toInt(batchData['seats']);

// ----------------------------------------------------------
// Count students belonging to this batch
// ----------------------------------------------------------

final QuerySnapshot<Map<String, dynamic>> studentSnapshot =
await _users
    .where('role', isEqualTo: 'student')
    .where('batchId', isEqualTo: batchId)
    .get();

final int enrolledStudents =
studentSnapshot.docs.length;

final int seatsLeft =
seats > enrolledStudents
? seats - enrolledStudents
    : 0;

// ----------------------------------------------------------
// Update batch
// ----------------------------------------------------------

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

final DocumentReference<Map<String, dynamic>> docRef =
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
// CHECK COURSES
// ============================================================

Future<void> _checkCourses() async {
final QuerySnapshot<Map<String, dynamic>> snapshot =
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
// CHECK CAMPUSES
// ============================================================

Future<void> _checkCampuses() async {
final QuerySnapshot<Map<String, dynamic>> snapshot =
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
// CHECK BATCHES
// ============================================================

Future<void> _checkBatches() async {
final QuerySnapshot<Map<String, dynamic>> snapshot =
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
// SEED ONLY STUDENTS
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
print('Student seed completed successfully.');
} catch (e) {
print('');
print('Student seed failed: $e');
rethrow;
}
}

// ============================================================
// SEED ONLY APPLICATIONS
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
// DELETE DEMO STUDENTS
// ============================================================

Future<void> deleteSeedStudents() async {
_checkAuthentication();

final WriteBatch batch = _firestore.batch();

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

// ----------------------------------------------------------
// Recalculate batch after deleting students
// ----------------------------------------------------------

await _updateStudentBatchEnrollment();
}

// ============================================================
// DELETE DEMO APPLICATIONS
// ============================================================

Future<void> deleteSeedApplications() async {
_checkAuthentication();

final WriteBatch batch = _firestore.batch();

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
// DELETE ALL DEMO DATA
// ============================================================

Future<void> deleteSeedData() async {
print('');
print('==========================================');
print('       DELETE DEMO DATA STARTED');
print('==========================================');

try {
_checkAuthentication();

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
print('Delete seed data failed: $e');
rethrow;
}
}
}

