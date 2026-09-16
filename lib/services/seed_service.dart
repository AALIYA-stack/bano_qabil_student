
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/seed_data/application_seed_data.dart';
import '../data/seed_data/student_seed_data.dart';

class SeedService {
SeedService._();

static final SeedService instance = SeedService._();

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

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
'No Firebase user is logged in. Please login first.',
);
}

print('');
print('Authenticated user: ${user.uid}');
print('Email: ${user.email ?? 'No email'}');
print('');
}

// ============================================================
// SAFE DATA CHECK
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

// Safe check hai.
// Student Home ko crash nahi karega.
print('Data check error ignored.');
print('');
}
}

// ============================================================
// CURRENT STUDENT CHECK
// ============================================================

Future<void> _checkCurrentStudent() async {
final user = _auth.currentUser;

if (user == null) {
print('No current Firebase user.');
return;
}

final doc = await _users.doc(user.uid).get();

if (!doc.exists) {
print(
'Current student profile not found for UID: ${user.uid}',
);
return;
}

final data = doc.data() ?? {};

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
// REAL DEMO SEED
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

if (count > 0) {
await batch.commit();
}

print('');
print('Students seeded successfully: $count');

// IMPORTANT:
// Enrollment ab Firestore users query se calculate nahi hoga.
// StudentSeedData se directly calculate hoga.
await _updateAllStudentBatchEnrollments();
}

// ============================================================
// UPDATE ALL STUDENT BATCH ENROLLMENTS
//
// IMPORTANT FIX
//
// Firestore users query:
//
// .where('role', isEqualTo: 'student')
// .where('batchId', isEqualTo: batchId)
//
// remove kar di gayi hai.
//
// Enrollment StudentSeedData.students se calculate hoga.
// Is se permission-denied issue nahi aayega.
// ============================================================

Future<void> _updateAllStudentBatchEnrollments() async {
print('');
print('==========================================');
print('    UPDATING STUDENT BATCH ENROLLMENTS');
print('==========================================');

// ----------------------------------------------------------
// STEP 1:
// StudentSeedData se unique batch IDs collect karein.
// ----------------------------------------------------------

final Set<String> batchIds = {};

for (final student in StudentSeedData.students) {
final String batchId =
(student['batchId'] ?? '').toString().trim();

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

for (final batchId in batchIds) {
print('→ $batchId');
}

print('');

// ----------------------------------------------------------
// STEP 2:
// Har batch ka enrollment update karein.
// ----------------------------------------------------------

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

// ----------------------------------------------------------
// STEP 1:
// Batch Firebase se read karein.
// ----------------------------------------------------------

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

// ----------------------------------------------------------
// STEP 2:
// Total seats read karein.
// ----------------------------------------------------------

final int seats = _toInt(batchData['seats']);

// ----------------------------------------------------------
// STEP 3:
// StudentSeedData se enrolled students count karein.
//
// Example:
// 12 students have batchId flutter-batch-01
// therefore enrolledStudents = 12
// ----------------------------------------------------------

int enrolledStudents = 0;

for (final student in StudentSeedData.students) {
final String studentBatchId =
(student['batchId'] ?? '').toString().trim();

if (studentBatchId == batchId) {
enrolledStudents++;
}
}

// ----------------------------------------------------------
// STEP 4:
// Seats left calculate karein.
// ----------------------------------------------------------

final int seatsLeft =
seats > enrolledStudents
? seats - enrolledStudents
    : 0;

// ----------------------------------------------------------
// STEP 5:
// Firebase batch update karein.
// ----------------------------------------------------------

await batchRef.set(
{
'enrolledStudents': enrolledStudents,
'seatsLeft': seatsLeft,
},
SetOptions(merge: true),
);

// ----------------------------------------------------------
// RESULT
// ----------------------------------------------------------

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
final Map<String, dynamic> data = doc.data();

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
final Map<String, dynamic> data = doc.data();

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
final Map<String, dynamic> data = doc.data();

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

// Firebase users query use nahi hogi.
// Seed data ke batch IDs se enrollment recalculate hoga.
await _updateAllStudentBatchEnrollments();
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


