import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

debugPrint('');
debugPrint('Authenticated user: ${user.uid}');
debugPrint('Email: ${user.email ?? 'No email'}');
debugPrint('');
}

// ============================================================
// SEED ALL
// ============================================================

Future<void> seedAll() async {
debugPrint('');
debugPrint('==========================================');
debugPrint('           BANO QABIL SEED');
debugPrint('==========================================');

try {
// --------------------------------------------------------
// AUTH
// --------------------------------------------------------

debugPrint('');
debugPrint('Checking Firebase Authentication...');
_checkAuthentication();

// --------------------------------------------------------
// COURSES
// --------------------------------------------------------

debugPrint('');
debugPrint('1. Checking courses...');
await _checkCourses();

// --------------------------------------------------------
// CAMPUSES
// --------------------------------------------------------

debugPrint('');
debugPrint('2. Checking campuses...');
await _checkCampuses();

// --------------------------------------------------------
// BATCHES
// --------------------------------------------------------

debugPrint('');
debugPrint('3. Checking batches...');
await _checkBatches();

// --------------------------------------------------------
// STUDENTS
// --------------------------------------------------------

debugPrint('');
debugPrint('4. Seeding students...');
await seedStudents();

// --------------------------------------------------------
// APPLICATIONS
// --------------------------------------------------------

debugPrint('');
debugPrint('5. Seeding applications...');
await seedApplications();

// --------------------------------------------------------
// SUCCESS
// --------------------------------------------------------

debugPrint('');
debugPrint('==========================================');
debugPrint('       SEED COMPLETED SUCCESSFULLY');
debugPrint('==========================================');
debugPrint('');
} catch (e, stackTrace) {
debugPrint('');
debugPrint('==========================================');
debugPrint('             SEED FAILED');
debugPrint('==========================================');

debugPrint('');
debugPrint('Error: $e');

debugPrint('');
debugPrint('StackTrace:');
debugPrint(stackTrace.toString());
debugPrint('');
debugPrint('==========================================');

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

debugPrint(
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

debugPrint('');
debugPrint('Students seeded successfully: $count');

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

debugPrint('');
debugPrint('Updating batch enrollment...');
debugPrint('Batch: $batchId');

final DocumentReference<Map<String, dynamic>> batchRef =
_batches.doc(batchId);

final DocumentSnapshot<Map<String, dynamic>> batchSnapshot =
await batchRef.get();

if (!batchSnapshot.exists) {
debugPrint(
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

debugPrint('');
debugPrint('==========================================');
debugPrint('        BATCH ENROLLMENT UPDATED');
debugPrint('==========================================');
debugPrint('Batch ID: $batchId');
debugPrint('Total Seats: $seats');
debugPrint('Enrolled Students: $enrolledStudents');
debugPrint('Seats Left: $seatsLeft');
debugPrint('==========================================');
debugPrint('');
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

debugPrint(
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

debugPrint('');
debugPrint(
'Applications seeded successfully: $count',
);
}

// ============================================================
// CHECK COURSES
// ============================================================

Future<void> _checkCourses() async {
final QuerySnapshot<Map<String, dynamic>> snapshot =
await _courses.get();

debugPrint(
'Courses found: ${snapshot.docs.length}',
);

if (snapshot.docs.isEmpty) {
debugPrint(
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

debugPrint(
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

debugPrint(
'Campuses found: ${snapshot.docs.length}',
);

if (snapshot.docs.isEmpty) {
debugPrint(
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

debugPrint(
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

debugPrint(
'Batches found: ${snapshot.docs.length}',
);

if (snapshot.docs.isEmpty) {
debugPrint(
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

debugPrint(
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
debugPrint('');
debugPrint('==========================================');
debugPrint('        STUDENT SEED STARTED');
debugPrint('==========================================');

try {
_checkAuthentication();

await seedStudents();

debugPrint('');
debugPrint('Student seed completed successfully.');
} catch (e) {
debugPrint('');
debugPrint('Student seed failed: $e');
rethrow;
}
}

// ============================================================
// SEED ONLY APPLICATIONS
// ============================================================

// ============================================================
// SEED ONLY APPLICATIONS
// ============================================================

Future<void> seedOnlyApplications() async {
  debugPrint('');
  debugPrint('==========================================');
  debugPrint('      APPLICATION SEED STARTED');
  debugPrint('==========================================');

  try {
    _checkAuthentication();

    await seedApplications();

    debugPrint('');
    debugPrint(
      'Application seed completed successfully.',
    );
  } catch (e) {
    debugPrint('');
    debugPrint('Application seed failed: $e');
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

debugPrint(
'Student marked for deletion: $id',
);
}

if (count > 0) {
await batch.commit();
}

debugPrint('');
debugPrint(
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

debugPrint(
'Application marked for deletion: $id',
);
}

if (count > 0) {
await batch.commit();
}

debugPrint('');
debugPrint(
'Demo applications deleted: $count',
);
}

// ============================================================
// DELETE ALL DEMO DATA
// ============================================================

// ============================================================
// DELETE ALL DEMO DATA
// ============================================================

Future<void> deleteSeedData() async {
  debugPrint('');
  debugPrint('==========================================');
  debugPrint('      DELETE DEMO DATA STARTED');
  debugPrint('==========================================');

  try {
    _checkAuthentication();

    debugPrint('');
    debugPrint('Deleting demo students...');
    await deleteSeedStudents();

    debugPrint('');
    debugPrint('Deleting demo applications...');
    await deleteSeedApplications();

    debugPrint('');
    debugPrint('==========================================');
    debugPrint('      DEMO DATA DELETED');
    debugPrint('==========================================');
    debugPrint('');
  } catch (e) {
    debugPrint('');
    debugPrint('Delete seed data failed: $e');
    rethrow;
  }
}
}