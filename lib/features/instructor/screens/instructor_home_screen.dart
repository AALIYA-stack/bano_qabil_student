import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';

class InstructorHomeScreen extends StatefulWidget {
const InstructorHomeScreen({super.key});

@override
State<InstructorHomeScreen> createState() =>
_InstructorHomeScreenState();
}

class _InstructorHomeScreenState
extends State<InstructorHomeScreen> {
final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

final FirebaseAuth _auth =
FirebaseAuth.instance;

bool _isLoading = true;

String _instructorName = 'Instructor';
String _courseName = 'Course';
String _batchName = 'Batch';

int _studentCount = 0;

String _campusName = 'Lahore Campus';
String _campusId = '';

// ============================================================
// NOTICES
// ============================================================

List<Map<String, dynamic>> _notices = [];

@override
void initState() {
super.initState();
_loadInstructorData();
}

// ============================================================
// LOAD INSTRUCTOR DATA
// ============================================================

Future<void> _loadInstructorData() async {
try {
final user = _auth.currentUser;

if (user == null) {
throw Exception(
'Instructor is not logged in.',
);
}

debugPrint(
'================================================',
);
debugPrint(
'INSTRUCTOR DASHBOARD START',
);
debugPrint(
'AUTH UID: ${user.uid}',
);
debugPrint(
'AUTH EMAIL: ${user.email}',
);

// ----------------------------------------------------------
// 1. LOAD INSTRUCTOR PROFILE
// ----------------------------------------------------------

final userDoc = await _firestore
    .collection('users')
    .doc(user.uid)
    .get();

if (!userDoc.exists ||
userDoc.data() == null) {
throw Exception(
'Instructor profile was not found.',
);
}

final userData = userDoc.data()!;

debugPrint(
'INSTRUCTOR USER DATA: $userData',
);

final role =
(userData['role'] ?? '')
    .toString()
    .trim()
    .toLowerCase();

if (role != 'instructor') {
throw Exception(
'This account is not an instructor. Role: $role',
);
}

final name =
(userData['name'] ??
userData['fullName'] ??
'Instructor')
    .toString();

String courseName = 'Course';
String batchName = 'Batch';
String campusName = 'Lahore Campus';

int studentCount = 0;

// Reset campus ID before loading.
_campusId = '';

// ----------------------------------------------------------
// 2. FIND BATCH ASSIGNED TO THIS INSTRUCTOR
// ----------------------------------------------------------

debugPrint(
'SEARCHING BATCH FOR INSTRUCTOR UID: ${user.uid}',
);

QuerySnapshot<Map<String, dynamic>> batchQuery;

try {
batchQuery = await _firestore
    .collection('batches')
    .where(
'instructorId',
isEqualTo: user.uid,
)
    .where(
'isOpen',
isEqualTo: true,
)
    .limit(1)
    .get();
} catch (e) {
debugPrint(
'BATCH QUERY WITH isOpen FAILED: $e',
);

// Fallback:
// If isOpen field is missing in an old batch,
// search only by instructorId.
batchQuery = await _firestore
    .collection('batches')
    .where(
'instructorId',
isEqualTo: user.uid,
)
    .limit(1)
    .get();
}

// ----------------------------------------------------------
// 3. BATCH FOUND
// ----------------------------------------------------------

if (batchQuery.docs.isNotEmpty) {
final batchDoc = batchQuery.docs.first;
final batchData = batchDoc.data();

debugPrint(
'================================================',
);
debugPrint(
'ASSIGNED BATCH FOUND',
);
debugPrint(
'BATCH ID: ${batchDoc.id}',
);
debugPrint(
'BATCH DATA: $batchData',
);

batchName =
(batchData['name'] ??
batchData['title'] ??
batchData['batchName'] ??
batchDoc.id)
    .toString();

// --------------------------------------------------------
// STUDENT COUNT
// --------------------------------------------------------

studentCount =
_getStudentCount(batchData);

debugPrint(
'STUDENT COUNT: $studentCount',
);

// --------------------------------------------------------
// COURSE ID FROM BATCH
// --------------------------------------------------------

final batchCourseId =
(batchData['courseId'] ?? '')
    .toString()
    .trim();

// If batch doesn't have courseId,
// fallback to instructor user document.
final userCourseId =
(userData['courseId'] ?? '')
    .toString()
    .trim();

final courseId =
batchCourseId.isNotEmpty
? batchCourseId
    : userCourseId;

debugPrint(
'COURSE ID: $courseId',
);

// --------------------------------------------------------
// LOAD COURSE
// --------------------------------------------------------

if (courseId.isNotEmpty) {
final courseDoc = await _firestore
    .collection('courses')
    .doc(courseId)
    .get();

if (courseDoc.exists &&
courseDoc.data() != null) {
final courseData =
courseDoc.data()!;

courseName =
(courseData['title'] ??
courseData['name'] ??
courseId)
    .toString();

debugPrint(
'COURSE NAME: $courseName',
);
} else {
debugPrint(
'COURSE NOT FOUND: $courseId',
);
}
}

// --------------------------------------------------------
// CAMPUS
// --------------------------------------------------------

final campusId =
(batchData['campusId'] ??
userData['campusId'] ??
'')
    .toString()
    .trim();

debugPrint(
'CAMPUS ID: $campusId',
);

// Save campus ID for notices.
_campusId = campusId;

if (campusId.isNotEmpty) {
final campusDoc = await _firestore
    .collection('campuses')
    .doc(campusId)
    .get();

if (campusDoc.exists &&
campusDoc.data() != null) {
final campusData =
campusDoc.data()!;

campusName =
(campusData['name'] ??
campusData['title'] ??
campusId)
    .toString();

debugPrint(
'CAMPUS NAME: $campusName',
);
}
}
} else {
// --------------------------------------------------------
// NO BATCH FOUND
// --------------------------------------------------------

debugPrint(
'================================================',
);
debugPrint(
'NO BATCH FOUND FOR THIS INSTRUCTOR',
);
debugPrint(
'INSTRUCTOR UID: ${user.uid}',
);
debugPrint(
'================================================',
);

// If no batch exists, try instructor's own campusId.
final fallbackCampusId =
(userData['campusId'] ?? '')
    .toString()
    .trim();

if (fallbackCampusId.isNotEmpty) {
_campusId = fallbackCampusId;

debugPrint(
'FALLBACK CAMPUS ID: $_campusId',
);

final campusDoc = await _firestore
    .collection('campuses')
    .doc(_campusId)
    .get();

if (campusDoc.exists &&
campusDoc.data() != null) {
final campusData =
campusDoc.data()!;

campusName =
(campusData['name'] ??
campusData['title'] ??
_campusId)
    .toString();
}
}
}

if (!mounted) return;

setState(() {
_instructorName = name;
_courseName = courseName;
_batchName = batchName;
_studentCount = studentCount;
_campusName = campusName;
_isLoading = false;
});

// ----------------------------------------------------------
// LOAD CAMPUS NOTICES
// ----------------------------------------------------------

if (_campusId.isNotEmpty) {
await _loadCampusNotices(_campusId);
} else {
debugPrint(
'NOTICE: Campus ID is empty. Cannot load notices.',
);

if (mounted) {
setState(() {
_notices = [];
});
}
}

debugPrint(
'================================================',
);
debugPrint(
'INSTRUCTOR DASHBOARD COMPLETE',
);
debugPrint(
'NAME: $_instructorName',
);
debugPrint(
'COURSE: $_courseName',
);
debugPrint(
'BATCH: $_batchName',
);
debugPrint(
'STUDENTS: $_studentCount',
);
debugPrint(
'CAMPUS ID: $_campusId',
);
debugPrint(
'CAMPUS: $_campusName',
);
debugPrint(
'NOTICES: ${_notices.length}',
);
debugPrint(
'================================================',
);
} catch (e, stackTrace) {
debugPrint(
'INSTRUCTOR DASHBOARD ERROR: $e',
);

debugPrint(
'STACK TRACE: $stackTrace',
);

if (!mounted) return;

setState(() {
_isLoading = false;
});

_showError(
'Unable to load instructor data.',
);
}
}

// ============================================================
// LOAD CAMPUS NOTICES
// ============================================================

Future<void> _loadCampusNotices(
String campusId,
) async {
if (campusId.trim().isEmpty) {
debugPrint(
'NOTICE: Campus ID is empty.',
);

if (mounted) {
setState(() {
_notices = [];
});
}

return;
}

try {
debugPrint(
'================================================',
);

debugPrint(
'LOADING INSTRUCTOR NOTICES',
);

debugPrint(
'CAMPUS ID: $campusId',
);

final snapshot = await _firestore
    .collection('notices')
    .where(
'campusId',
isEqualTo: campusId.trim(),
)
    .where(
'isActive',
isEqualTo: true,
)
    .get();

final notices =
snapshot.docs.map((doc) {
final data = doc.data();

return {
'id': doc.id,
...data,
};
}).toList();

// ----------------------------------------------------------
// SORT LATEST FIRST
// ----------------------------------------------------------

notices.sort((a, b) {
final aValue = a['createdAt'];
final bValue = b['createdAt'];

DateTime? aDate;
DateTime? bDate;

if (aValue is Timestamp) {
aDate = aValue.toDate();
} else if (aValue is DateTime) {
aDate = aValue;
}

if (bValue is Timestamp) {
bDate = bValue.toDate();
} else if (bValue is DateTime) {
bDate = bValue;
}

if (aDate == null && bDate == null) {
return 0;
}

if (aDate == null) {
return 1;
}

if (bDate == null) {
return -1;
}

return bDate.compareTo(aDate);
});

debugPrint(
'NOTICES FOUND: ${notices.length}',
);

for (final notice in notices) {
debugPrint(
'NOTICE ID: ${notice['id']}',
);

debugPrint(
'NOTICE TITLE: ${notice['title']}',
);

debugPrint(
'NOTICE CAMPUS: ${notice['campusId']}',
);

debugPrint(
'NOTICE ACTIVE: ${notice['isActive']}',
);
}

if (!mounted) return;

setState(() {
_notices = notices;
});

debugPrint(
'================================================',
);
} catch (e, stackTrace) {
debugPrint(
'ERROR LOADING INSTRUCTOR NOTICES: $e',
);

debugPrint(
'NOTICE STACK TRACE: $stackTrace',
);

if (!mounted) return;

setState(() {
_notices = [];
});
}
}

// ============================================================
// GET STUDENT COUNT
// ============================================================

int _getStudentCount(
Map<String, dynamic> batchData,
) {
// ----------------------------------------------------------
// OPTION 1:
// enrolledStudents is a number
// ----------------------------------------------------------

final enrolled =
batchData['enrolledStudents'];

if (enrolled is int) {
return enrolled;
}

if (enrolled is num) {
return enrolled.toInt();
}

// ----------------------------------------------------------
// OPTION 2:
// enrolledStudents is a List
// ----------------------------------------------------------

if (enrolled is List) {
return enrolled.length;
}

// ----------------------------------------------------------
// OPTION 3:
// studentIds is a List
// ----------------------------------------------------------

final studentIds =
batchData['studentIds'];

if (studentIds is List) {
return studentIds.length;
}

// ----------------------------------------------------------
// NOTHING FOUND
// ----------------------------------------------------------

return 0;
}

// ============================================================
// LOGOUT
// ============================================================

Future<void> _logout() async {
await _auth.signOut();

if (!mounted) return;

Navigator.pushNamedAndRemoveUntil(
context,
AppRoutes.login,
(route) => false,
);
}

// ============================================================
// ERROR
// ============================================================

void _showError(String message) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
behavior: SnackBarBehavior.floating,
),
);
}

// ============================================================
// OPEN ATTENDANCE
// ============================================================

void _openAttendance() {
Navigator.pushNamed(
context,
AppRoutes.instructorAttendance,
);
}

// ============================================================
// OPEN STUDENTS
// ============================================================

void _openStudents() {
Navigator.pushNamed(
context,
AppRoutes.instructorStudents,
);
}

// ============================================================
// OPEN ASSIGNMENTS
// ============================================================

void _openAssignments() {
Navigator.pushNamed(
context,
AppRoutes.instructorAssignments,
);
}

// ============================================================
// OPEN MARKS
// ============================================================

void _openMarks() {
Navigator.pushNamed(
context,
AppRoutes.instructorMarks,
);
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor:
const Color(0xFFF6F8FC),

// --------------------------------------------------------
// APP BAR
// --------------------------------------------------------

appBar: AppBar(
title: const Text(
'Instructor Dashboard',
style: TextStyle(
fontWeight: FontWeight.w700,
),
),
centerTitle: false,
actions: [
IconButton(
tooltip: 'Logout',
onPressed: _logout,
icon: const Icon(
Icons.logout_rounded,
),
),
],
),

// --------------------------------------------------------
// BODY
// --------------------------------------------------------

body: _isLoading
? const Center(
child: CircularProgressIndicator(),
)
    : RefreshIndicator(
onRefresh: _loadInstructorData,
child: ListView(
physics:
const AlwaysScrollableScrollPhysics(),
padding:
const EdgeInsets.all(20),
children: [
_buildWelcomeCard(),

const SizedBox(height: 20),

_buildSectionTitle(
'Your Teaching Overview',
),

const SizedBox(height: 12),

_buildStatsGrid(),

const SizedBox(height: 24),

_buildSectionTitle(
'Quick Actions',
),

const SizedBox(height: 12),

_buildQuickActions(),

const SizedBox(height: 24),

_buildSectionTitle(
'Assigned Batch',
),

const SizedBox(height: 12),

_buildBatchCard(),

const SizedBox(height: 24),

_buildSectionTitle(
'Upcoming Class',
),

const SizedBox(height: 12),

_buildUpcomingClass(),

const SizedBox(height: 24),

_buildSectionTitle(
'Campus Notices',
),

const SizedBox(height: 12),

_buildNoticesSection(),

const SizedBox(height: 20),
],
),
),
);
}

// ============================================================
// WELCOME CARD
// ============================================================

Widget _buildWelcomeCard() {
return Container(
padding:
const EdgeInsets.all(20),
decoration: BoxDecoration(
borderRadius:
BorderRadius.circular(20),
gradient:
const LinearGradient(
colors: [
Color(0xFF6DC015),
Color(0xA315C023),
],
),
),
child: Row(
children: [
Container(
width: 58,
height: 58,
decoration: BoxDecoration(
color:
Colors.white.withOpacity(
0.18,
),
shape: BoxShape.circle,
),
child: const Icon(
Icons.school_rounded,
color: Colors.white,
size: 30,
),
),

const SizedBox(width: 16),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Welcome back 👋',
style: TextStyle(
color:
Colors.white70,
fontSize: 14,
),
),

const SizedBox(height: 4),

Text(
_instructorName,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
color: Colors.white,
fontSize: 22,
fontWeight:
FontWeight.w800,
),
),

const SizedBox(height: 4),

Text(
_courseName,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
color: Colors.white,
fontSize: 14,
),
),
],
),
),
],
),
);
}

// ============================================================
// SECTION TITLE
// ============================================================

Widget _buildSectionTitle(
String title,
) {
return Text(
title,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.w800,
color: Color(0xFF172033),
),
);
}

// ============================================================
// STATS
// ============================================================

Widget _buildStatsGrid() {
return GridView.count(
crossAxisCount: 2,
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),
mainAxisSpacing: 12,
crossAxisSpacing: 12,
childAspectRatio: 1.45,
children: [
_buildStatCard(
icon:
Icons.people_alt_rounded,
title: 'Students',
value:
_studentCount.toString(),
),

_buildStatCard(
icon:
Icons.menu_book_rounded,
title: 'Course',
value: '1',
),

_buildStatCard(
icon:
Icons.groups_rounded,
title: 'Batch',
value: _batchName
    .replaceAll(
'batch',
'',
)
    .trim(),
),

_buildStatCard(
icon:
Icons.calendar_month_rounded,
title: 'Classes',
value: '3 / week',
),
],
);
}

Widget _buildStatCard({
required IconData icon,
required String title,
required String value,
}) {
return Card(
elevation: 0,
child: Padding(
padding:
const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
icon,
color:
const Color(0xFF1565C0),
size: 25,
),

const Spacer(),

Text(
value,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
fontSize: 19,
fontWeight:
FontWeight.w800,
),
),

const SizedBox(height: 3),

Text(
title,
style:
const TextStyle(
color:
Color(0xFF697386),
fontSize: 12,
),
),
],
),
),
);
}

// ============================================================
// QUICK ACTIONS
// ============================================================

Widget _buildQuickActions() {
return Column(
children: [
Row(
children: [
Expanded(
child:
_buildActionCard(
icon:
Icons.fact_check_rounded,
title:
'Attendance',
subtitle:
'Mark attendance',
onTap:
_openAttendance,
),
),

const SizedBox(width: 12),

Expanded(
child:
_buildActionCard(
icon:
Icons.people_alt_rounded,
title:
'Students',
subtitle:
'View students',
onTap:
_openStudents,
),
),
],
),

const SizedBox(height: 12),

Row(
children: [
Expanded(
child:
_buildActionCard(
icon:
Icons.assignment_rounded,
title:
'Assignments',
subtitle:
'Manage work',
onTap:
_openAssignments,
),
),

const SizedBox(width: 12),

Expanded(
child:
_buildActionCard(
icon:
Icons.grade_rounded,
title: 'Marks',
subtitle:
'Marks & feedback',
onTap:
_openMarks,
),
),
],
),
],
);
}

Widget _buildActionCard({
required IconData icon,
required String title,
required String subtitle,
required VoidCallback onTap,
}) {
return Card(
elevation: 0,
child: InkWell(
onTap: onTap,
borderRadius:
BorderRadius.circular(16),
child: Padding(
padding:
const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 46,
height: 46,
decoration:
BoxDecoration(
color:
const Color(
0xFFE8F1FF,
),
borderRadius:
BorderRadius.circular(
14,
),
),
child: Icon(
icon,
color:
const Color(
0xFF1BC015,
),
),
),

const SizedBox(height: 12),

Text(
title,
style:
const TextStyle(
fontWeight:
FontWeight.w700,
fontSize: 15,
),
),

const SizedBox(height: 3),

Text(
subtitle,
style:
const TextStyle(
fontSize: 12,
color:
Color(0xFF697386),
),
),
],
),
),
),
);
}

// ============================================================
// BATCH CARD
// ============================================================

Widget _buildBatchCard() {
return Card(
elevation: 0,
child: Padding(
padding:
const EdgeInsets.all(18),
child: Row(
children: [
Container(
width: 52,
height: 52,
decoration:
BoxDecoration(
color:
const Color(
0xFFE8F1FF,
),
borderRadius:
BorderRadius.circular(
15,
),
),
child: const Icon(
Icons.groups_rounded,
color:
Color(0xFF1BC015),
),
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
_batchName,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w700,
),
),

const SizedBox(height: 5),

Text(
_courseName,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
color:
Color(0xFF697386),
),
),

const SizedBox(height: 4),

Text(
_campusName,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
color:
Color(0xFF697386),
fontSize: 12,
),
),
],
),
),

const SizedBox(width: 8),

Text(
'$_studentCount students',
style:
const TextStyle(
fontSize: 12,
fontWeight:
FontWeight.w600,
color:
Color(0xFF1565C0),
),
),
],
),
),
);
}

// ============================================================
// UPCOMING CLASS
// ============================================================

Widget _buildUpcomingClass() {
return Card(
elevation: 0,
child: Padding(
padding:
const EdgeInsets.all(18),
child: Column(
children: [
Row(
children: [
Container(
width: 50,
height: 50,
decoration:
BoxDecoration(
color:
const Color(
0xFFE8F1FF,
),
borderRadius:
BorderRadius.circular(
14,
),
),
child: const Icon(
Icons
    .calendar_today_rounded,
color:
AppColors.primary,
),
),

const SizedBox(width: 14),

const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Next Class',
style:
TextStyle(
fontSize: 13,
color:
Color(
0xFF697386,
),
),
),

SizedBox(height: 4),

Text(
'Monday • 5:00 PM',
style:
TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w700,
),
),
],
),
),
],
),

const SizedBox(height: 16),

const Divider(),

const SizedBox(height: 10),

Row(
children: [
const Icon(
Icons.room_rounded,
size: 20,
color:
Color(0xFF697386),
),

const SizedBox(width: 8),

const Text(
'Lab 1',
style:
TextStyle(
fontWeight:
FontWeight.w600,
),
),

const Spacer(),

Text(
_batchName,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
color:
Color(0xFF697386),
fontSize: 12,
),
),
],
),
],
),
),
);
}

// ============================================================
// CAMPUS NOTICES
// ============================================================

Widget _buildNoticesSection() {
if (_notices.isEmpty) {
return Card(
elevation: 0,
child: Padding(
padding:
const EdgeInsets.all(20),
child: Row(
children: [
Container(
width: 46,
height: 46,
decoration:
BoxDecoration(
color:
const Color(
0xFFE8F1FF,
),
borderRadius:
BorderRadius.circular(
14,
),
),
child: const Icon(
Icons.campaign_outlined,
color:
Color(0xFF1565C0),
),
),

const SizedBox(width: 14),

const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'No new notices',
style: TextStyle(
fontWeight:
FontWeight.w700,
fontSize: 15,
),
),

SizedBox(height: 4),

Text(
'There are no active campus notices right now.',
style: TextStyle(
fontSize: 12,
color:
Color(0xFF697386),
),
),
],
),
),
],
),
),
);
}

// Show maximum 3 latest notices.
final visibleNotices =
_notices.take(3).toList();

return Column(
children:
visibleNotices.map((notice) {
return _buildNoticeCard(
notice,
);
}).toList(),
);
}

// ============================================================
// NOTICE CARD
// ============================================================

Widget _buildNoticeCard(
Map<String, dynamic> notice,
) {
final title =
notice['title']
    ?.toString()
    .trim() ??
'';

// Coordinator currently saves "message".
// We also support "description" for older notices.
final message =
notice['message']
    ?.toString()
    .trim()
    .isNotEmpty ==
true
? notice['message']
    .toString()
    .trim()
    : notice['description']
    ?.toString()
    .trim() ??
'';

final campusName =
notice['campusName']
    ?.toString()
    .trim() ??
_campusName;

return Card(
elevation: 0,
margin:
const EdgeInsets.only(
bottom: 12,
),
child: Padding(
padding:
const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 42,
height: 42,
decoration:
BoxDecoration(
color:
const Color(
0xFFE8F1FF,
),
borderRadius:
BorderRadius.circular(
12,
),
),
child: const Icon(
Icons.campaign_rounded,
color:
Color(0xFF1565C0),
),
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
title.isEmpty
? 'Campus Notice'
    : title,
maxLines: 2,
overflow:
TextOverflow
    .ellipsis,
style:
const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w800,
),
),

const SizedBox(height: 4),

Text(
campusName.isEmpty
? _campusName
    : campusName,
maxLines: 1,
overflow:
TextOverflow
    .ellipsis,
style:
const TextStyle(
fontSize: 11,
color:
Color(
0xFF697386,
),
fontWeight:
FontWeight.w600,
),
),
],
),
),
],
),

const SizedBox(height: 12),

Text(
message.isEmpty
? 'No message available.'
    : message,
maxLines: 4,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
fontSize: 13,
height: 1.45,
),
),

const SizedBox(height: 10),

Row(
children: [
const Icon(
Icons
    .access_time_rounded,
size: 15,
color:
Color(0xFF697386),
),

const SizedBox(width: 5),

Text(
_formatNoticeDate(
notice['createdAt'],
),
style:
const TextStyle(
fontSize: 11,
color:
Color(0xFF697386),
),
),
],
),
],
),
),
);
}

// ============================================================
// NOTICE DATE
// ============================================================

String _formatNoticeDate(
dynamic value,
) {
DateTime? date;

if (value is Timestamp) {
date = value.toDate();
} else if (value is DateTime) {
date = value;
} else if (value is String) {
date = DateTime.tryParse(value);
}

if (date == null) {
return 'Just now';
}

final day =
date.day
    .toString()
    .padLeft(2, '0');

final month =
date.month
    .toString()
    .padLeft(2, '0');

final hour =
date.hour
    .toString()
    .padLeft(2, '0');

final minute =
date.minute
    .toString()
    .padLeft(2, '0');

return '$day/$month/${date.year} '
'$hour:$minute';
}
}

