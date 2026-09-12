import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/collection_names.dart';
import '../models/student_dashboard_model.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/batch_model.dart';
import '../models/progress_model.dart';
import '../models/submission_model.dart';
import '../models/career_progress_model.dart';

import 'auth_service.dart';
import 'batch_service.dart';
import 'assignment_service.dart';
import 'submission_service.dart';
import 'progress_service.dart';
import 'career_service.dart';
import 'notification_service.dart';

class StudentHomeService {
StudentHomeService._();

static final StudentHomeService instance =
StudentHomeService._();

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

final FirebaseAuth _auth =
FirebaseAuth.instance;

final AuthService _authService =
AuthService.instance;

final BatchService _batchService =
BatchService.instance;

final AssignmentService _assignmentService =
AssignmentService.instance;

final SubmissionService _submissionService =
SubmissionService.instance;

final ProgressService _progressService =
ProgressService.instance;

final CareerService _careerService =
CareerService.instance;

final NotificationService _notificationService =
NotificationService.instance;

// ============================================================
// GET STUDENT DASHBOARD
// ============================================================

Future<StudentDashboardModel> getDashboard() async {
final firebaseUser = _auth.currentUser;

if (firebaseUser == null) {
throw Exception(
'User is not logged in.',
);
}

final String uid = firebaseUser.uid;

// ==========================================================
// 1. USER PROFILE
// ==========================================================

final UserModel? user =
await _authService.getCurrentUserProfile();

if (user == null) {
throw Exception(
'Student profile was not found in Firestore.',
);
}

// ==========================================================
// 2. RESOLVE STUDENT APPLICATION
// ==========================================================
//
// IMPORTANT:
// Official project flow:
//
// Auth UID
//    ↓
// users
//    ↓
// applications
//    ↓
// accepted application
//    ↓
// batchId + courseId
//
// This prevents the old:
// "batchId is missing from your application"
// problem when users/{uid} does not contain batchId.
// ==========================================================

final Map<String, dynamic>? application =
await _getStudentApplication(uid);

// ==========================================================
// 3. RESOLVE COURSE ID
// ==========================================================

String? courseId =
_readString(application?['courseId']);

// Backward compatibility:
// If application doesn't have courseId,
// use users/{uid}.courseId.
if (courseId == null ||
courseId.trim().isEmpty) {
courseId = user.courseId;
}

// ==========================================================
// 4. RESOLVE BATCH ID
// ==========================================================

String? batchId =
_readString(application?['batchId']);

// Backward compatibility:
// Existing users may already have batchId in users document.
if (batchId == null ||
batchId.trim().isEmpty) {
batchId = user.batchId;
}

// ==========================================================
// 5. COURSE
// ==========================================================

CourseModel? course;

if (courseId != null &&
courseId.trim().isNotEmpty) {
try {
course = await _getCourseById(
courseId.trim(),
);
} catch (_) {
course = null;
}
}

// ==========================================================
// 6. BATCH
// ==========================================================

BatchModel? batch;

if (batchId != null &&
batchId.trim().isNotEmpty) {
try {
batch = await _batchService.getBatchById(
batchId.trim(),
);
} catch (_) {
batch = null;
}
}

// ==========================================================
// 7. DEFAULT CAREER PROGRESS
// ==========================================================

final defaultCareerProgress =
CareerProgressModel(
studentId: uid,
cvReady: false,
githubReady: false,
projectsCompleted: 0,
mockInterviewDone: false,
jobsApplied: 0,
updatedAt: null,
);

// ==========================================================
// 8. DEFAULT PROGRESS
// ==========================================================

ProgressModel progress =
ProgressModel(
completedModules: 0,
totalModules: 0,
attendancePercentage: 0,
assignmentAverage: 0,
careerProgress:
defaultCareerProgress,
);

double attendancePercentage = 0;

int totalAssignments = 0;
int pendingAssignments = 0;
int submittedAssignments = 0;
int lateAssignments = 0;
int markedAssignments = 0;

// ==========================================================
// 9. BATCH BASED DATA
// ==========================================================

if (batchId != null &&
batchId.trim().isNotEmpty) {
final String cleanBatchId =
batchId.trim();

// --------------------------------------------------------
// PROGRESS
// --------------------------------------------------------

if (courseId != null &&
courseId.trim().isNotEmpty) {
try {
progress =
await _progressService.getMyProgress(
batchId: cleanBatchId,
courseId: courseId.trim(),
);

attendancePercentage =
progress.attendancePercentage;
} catch (_) {
progress = ProgressModel(
completedModules: 0,
totalModules: 0,
attendancePercentage: 0,
assignmentAverage: 0,
careerProgress:
defaultCareerProgress,
);

attendancePercentage = 0;
}
}

// --------------------------------------------------------
// ASSIGNMENTS
// --------------------------------------------------------

try {
final assignmentData =
await _loadAssignmentData(
cleanBatchId,
);

totalAssignments =
assignmentData.total;

pendingAssignments =
assignmentData.pending;

submittedAssignments =
assignmentData.submitted;

lateAssignments =
assignmentData.late;

markedAssignments =
assignmentData.marked;
} catch (_) {
totalAssignments = 0;
pendingAssignments = 0;
submittedAssignments = 0;
lateAssignments = 0;
markedAssignments = 0;
}
}

// ==========================================================
// 10. CAREER PROGRESS
// ==========================================================

CareerProgressModel? careerProgress;

try {
careerProgress =
await _careerService
    .getMyCareerProgress();
} catch (_) {
careerProgress = null;
}

// ==========================================================
// 11. MERGE CAREER DATA INTO PROGRESS
// ==========================================================

if (careerProgress != null) {
progress = progress.copyWith(
careerProgress:
careerProgress,
);
}

// ==========================================================
// 12. NOTIFICATIONS
// ==========================================================

int unreadNotifications = 0;

try {
unreadNotifications =
await _notificationService
    .getUnreadCount();
} catch (_) {
unreadNotifications = 0;
}

// ==========================================================
// 13. FINAL DASHBOARD
// ==========================================================

return StudentDashboardModel(
user: user,
course: course,
batch: batch,
attendancePercentage:
attendancePercentage,
totalAssignments:
totalAssignments,
pendingAssignments:
pendingAssignments,
submittedAssignments:
submittedAssignments,
lateAssignments:
lateAssignments,
markedAssignments:
markedAssignments,
progress: progress,
careerProgress:
careerProgress,
unreadNotifications:
unreadNotifications,
);
}

// ============================================================
// GET STUDENT APPLICATION
// ============================================================

Future<Map<String, dynamic>?>
_getStudentApplication(
String uid,
) async {
final String cleanUid = uid.trim();

if (cleanUid.isEmpty) {
return null;
}

final QuerySnapshot<Map<String, dynamic>>
snapshot = await _firestore
    .collection('applications')
    .where(
'studentId',
isEqualTo: cleanUid,
)
    .get();

if (snapshot.docs.isEmpty) {
return null;
}

// ----------------------------------------------------------
// Prefer an ACCEPTED application
// ----------------------------------------------------------

for (final doc in snapshot.docs) {
final data = doc.data();

final String status =
(_readString(data['status']) ?? '')
    .trim()
    .toLowerCase();

if (status == 'accepted') {
return data;
}
}

// ----------------------------------------------------------
// If no accepted application exists,
// use the most recent available application.
// ----------------------------------------------------------

final docs =
List<QueryDocumentSnapshot<
Map<String, dynamic>>>.from(
snapshot.docs,
);

docs.sort(
(a, b) {
final Timestamp? aDate =
a.data()['createdAt']
as Timestamp?;

final Timestamp? bDate =
b.data()['createdAt']
as Timestamp?;

if (aDate == null &&
bDate == null) {
return 0;
}

if (aDate == null) {
return 1;
}

if (bDate == null) {
return -1;
}

return bDate.compareTo(aDate);
},
);

return docs.first.data();
}

// ============================================================
// GET COURSE BY ID
// ============================================================

Future<CourseModel?> _getCourseById(
String courseId,
) async {
final String cleanCourseId =
courseId.trim();

if (cleanCourseId.isEmpty) {
return null;
}

final DocumentSnapshot<
Map<String, dynamic>> doc =
await _firestore
    .collection(
CollectionNames.courses,
)
    .doc(cleanCourseId)
    .get();

if (!doc.exists) {
return null;
}

return CourseModel.fromFirestore(doc);
}

// ============================================================
// LOAD ASSIGNMENT DATA
// ============================================================

Future<_AssignmentDashboardData>
_loadAssignmentData(
String batchId,
) async {
final String cleanBatchId =
batchId.trim();

if (cleanBatchId.isEmpty) {
return const _AssignmentDashboardData(
total: 0,
pending: 0,
submitted: 0,
late: 0,
marked: 0,
);
}

// ----------------------------------------------------------
// GET ASSIGNMENTS FOR CURRENT BATCH
// ----------------------------------------------------------

final assignments =
await _assignmentService
    .getAssignmentsForBatch(
cleanBatchId,
);

// ----------------------------------------------------------
// GET CURRENT STUDENT SUBMISSIONS
// ----------------------------------------------------------

final submissions =
await _submissionService
    .getMySubmissions();

// ----------------------------------------------------------
// ONLY CURRENT BATCH SUBMISSIONS
// ----------------------------------------------------------

final batchSubmissions =
submissions.where(
(submission) =>
submission.batchId ==
cleanBatchId,
).toList();

// ----------------------------------------------------------
// ASSIGNMENT ID → SUBMISSION
// ----------------------------------------------------------

final Map<String, SubmissionModel>
submissionByAssignment = {};

for (final submission
in batchSubmissions) {
submissionByAssignment[
submission.assignmentId] =
submission;
}

// ----------------------------------------------------------
// COUNTERS
// ----------------------------------------------------------

int pending = 0;
int submitted = 0;
int late = 0;
int marked = 0;

// ----------------------------------------------------------
// CHECK EVERY ASSIGNMENT
// ----------------------------------------------------------

for (final assignment
in assignments) {
final submission =
submissionByAssignment[
assignment.id];

// No submission yet
if (submission == null) {
pending++;
continue;
}

// Submitted
if (submission.isSubmitted) {
submitted++;
}

// Late
if (submission.isLate) {
late++;
}

// Marked
if (submission.isMarked) {
marked++;
}
}

return _AssignmentDashboardData(
total: assignments.length,
pending: pending,
submitted: submitted,
late: late,
marked: marked,
);
}

// ============================================================
// SAFE STRING READER
// ============================================================

String? _readString(
dynamic value,
) {
if (value == null) {
return null;
}

final String result =
value.toString().trim();

if (result.isEmpty) {
return null;
}

return result;
}
}

// ============================================================
// PRIVATE ASSIGNMENT DASHBOARD DATA
// ============================================================

class _AssignmentDashboardData {
final int total;
final int pending;
final int submitted;
final int late;
final int marked;

const _AssignmentDashboardData({
required this.total,
required this.pending,
required this.submitted,
required this.late,
required this.marked,
});
}