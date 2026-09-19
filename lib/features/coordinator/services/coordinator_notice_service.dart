import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/collection_names.dart';

class CoordinatorNoticeService {
CoordinatorNoticeService._();

static final CoordinatorNoticeService instance =
CoordinatorNoticeService._();

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

// ============================================================
// GET NOTICES
// ============================================================

Future<List<Map<String, dynamic>>> getNotices() async {
try {
final snapshot = await _firestore
    .collection(CollectionNames.notices)
    .orderBy(
'createdAt',
descending: true,
)
    .get();

return snapshot.docs.map((doc) {
final data = doc.data();

return {
'id': doc.id,
...data,
};
}).toList();
} catch (e) {
print('ERROR GETTING NOTICES: $e');
rethrow;
}
}

// ============================================================
// CREATE NOTICE
// ============================================================

Future<String> createNotice({
required String title,
required String message,
required String campusId,
required String campusName,
}) async {
try {
final cleanTitle = title.trim();
final cleanMessage = message.trim();
final cleanCampusId = campusId.trim();
final cleanCampusName = campusName.trim();

if (cleanTitle.isEmpty) {
throw Exception('Notice title is required.');
}

if (cleanMessage.isEmpty) {
throw Exception('Notice message is required.');
}

final doc =
await _firestore
    .collection(CollectionNames.notices)
    .add({
'title': cleanTitle,
'message': cleanMessage,
'campusId': cleanCampusId,
'campusName': cleanCampusName,
'createdAt':
FieldValue.serverTimestamp(),
'updatedAt':
FieldValue.serverTimestamp(),
'isActive': true,
});

return doc.id;
} catch (e) {
print('ERROR CREATING NOTICE: $e');
rethrow;
}
}

// ============================================================
// UPDATE NOTICE
// ============================================================

Future<void> updateNotice({
required String noticeId,
required String title,
required String message,
required String campusId,
required String campusName,
}) async {
try {
final cleanTitle = title.trim();
final cleanMessage = message.trim();

if (noticeId.trim().isEmpty) {
throw Exception('Notice ID is required.');
}

if (cleanTitle.isEmpty) {
throw Exception('Notice title is required.');
}

if (cleanMessage.isEmpty) {
throw Exception('Notice message is required.');
}

await _firestore
    .collection(CollectionNames.notices)
    .doc(noticeId.trim())
    .update({
'title': cleanTitle,
'message': cleanMessage,
'campusId': campusId.trim(),
'campusName': campusName.trim(),
'updatedAt':
FieldValue.serverTimestamp(),
});
} catch (e) {
print('ERROR UPDATING NOTICE: $e');
rethrow;
}
}

// ============================================================
// ACTIVATE / DEACTIVATE
// ============================================================

Future<void> setNoticeActiveStatus({
required String noticeId,
required bool isActive,
}) async {
try {
if (noticeId.trim().isEmpty) {
throw Exception('Notice ID is required.');
}

await _firestore
    .collection(CollectionNames.notices)
    .doc(noticeId.trim())
    .update({
'isActive': isActive,
'updatedAt':
FieldValue.serverTimestamp(),
});
} catch (e) {
print(
'ERROR CHANGING NOTICE STATUS: $e',
);
rethrow;
}
}
}
