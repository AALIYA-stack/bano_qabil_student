import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/collection_names.dart';
import '../data/seed_data/assignment_seed_data.dart';
import '../data/seed_data/module_seed_data.dart';
import '../data/seed_data/notice_seed_data.dart';
import '../data/seed_data/notification_seed_data.dart';

class SeedService {
SeedService._();

static final SeedService instance = SeedService._();

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

// ============================================================
// SEED ASSIGNMENTS
// ============================================================

Future<void> seedAssignments() async {
final batch = _firestore.batch();

for (final assignment in AssignmentSeedData.assignments) {
final id = assignment['id'].toString();

final data = Map<String, dynamic>.from(
assignment,
);

data.remove('id');

final docRef = _firestore
    .collection(
CollectionNames.assignments,
)
    .doc(id);

batch.set(
docRef,
data,
SetOptions(merge: true),
);
}

await batch.commit();
}

// ============================================================
// SEED MODULES
// ============================================================

Future<void> seedModules() async {
final batch = _firestore.batch();

for (final module in ModuleSeedData.modules) {
final id = module['id'].toString();

final data = Map<String, dynamic>.from(
module,
);

data.remove('id');

final docRef = _firestore
    .collection(
CollectionNames.courseModules,
)
    .doc(id);

batch.set(
docRef,
data,
SetOptions(merge: true),
);
}

await batch.commit();
}

// ============================================================
// SEED NOTICES
// ============================================================

Future<void> seedNotices() async {
final batch = _firestore.batch();

for (final notice in NoticeSeedData.notices) {
final id = notice['id'].toString();

final data = Map<String, dynamic>.from(
notice,
);

data.remove('id');

final docRef = _firestore
    .collection(
CollectionNames.notices,
)
    .doc(id);

batch.set(
docRef,
data,
SetOptions(merge: true),
);
}

await batch.commit();
}

// ============================================================
// SEED ALL BASIC DATA
// ============================================================

Future<void> seedAll() async {
await seedAssignments();
await seedModules();
await seedNotices();
}

// ============================================================
// SEED NOTIFICATIONS FOR A STUDENT
// ============================================================

Future<void> seedNotifications({
required String studentId,
}) async {
if (studentId.trim().isEmpty) {
throw Exception(
'Student ID cannot be empty.',
);
}

final batch = _firestore.batch();

for (
final notification
in NotificationSeedData.notifications
) {
final id = notification['id'].toString();

final data = Map<String, dynamic>.from(
notification,
);

data['studentId'] = studentId;
data.remove('id');

final docRef = _firestore
    .collection(
CollectionNames.notifications,
)
    .doc(id);

batch.set(
docRef,
data,
SetOptions(merge: true),
);
}

await batch.commit();
}
}

