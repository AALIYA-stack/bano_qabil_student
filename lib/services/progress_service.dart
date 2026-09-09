import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/collection_names.dart';
import '../models/progress_model.dart';

class ProgressService {
ProgressService._();

static final ProgressService instance =
ProgressService._();

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

final FirebaseAuth _auth =
FirebaseAuth.instance;

String get _uid {
final user = _auth.currentUser;

if (user == null) {
throw Exception(
'User is not logged in.',
);
}

return user.uid;
}

Future<ProgressModel> getMyProgress({
required String batchId,
}) async {
final attendanceSnapshot =
await _firestore
    .collection(
CollectionNames.attendance,
)
    .where(
'studentId',
isEqualTo: _uid,
)
    .where(
'batchId',
isEqualTo: batchId,
)
    .get();

double attendancePercentage = 0;

final attendanceDocs =
attendanceSnapshot.docs;

if (attendanceDocs.isNotEmpty) {
int attendedClasses = 0;

for (final doc in attendanceDocs) {
final data = doc.data();

final status = data['status']
    ?.toString()
    .trim()
    .toLowerCase();

if (status == 'present' ||
status == 'late') {
attendedClasses++;
}
}

attendancePercentage =
(attendedClasses /
attendanceDocs.length) *
100;
}

final submissionSnapshot =
await _firestore
    .collection(
CollectionNames.submissions,
)
    .where(
'studentId',
isEqualTo: _uid,
)
    .where(
'batchId',
isEqualTo: batchId,
)
    .get();

final submissionDocs =
submissionSnapshot.docs;

double assignmentAverage = 0;

final markedSubmissions =
submissionDocs.where((doc) {
return doc.data()['marks'] is num;
}).toList();

if (markedSubmissions.isNotEmpty) {
double totalMarks = 0;

for (final doc in markedSubmissions) {
final marks =
(doc.data()['marks'] as num)
    .toDouble();

totalMarks += marks;
}

assignmentAverage =
totalMarks /
markedSubmissions.length;
}

/*
     * Module progress abhi ModuleService ke through
     * CourseModulesScreen mein handle ho raha hai.
     *
     * Jab exact Firestore module-progress structure
     * confirm hoga, yahan completedModules aur
     * totalModules bhi connect kar denge.
     */
return ProgressModel(
completedModules: 0,
totalModules: 0,
attendancePercentage:
attendancePercentage,
assignmentAverage:
assignmentAverage,
);
}
}
