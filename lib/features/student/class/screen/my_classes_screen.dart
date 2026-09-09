import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';

class MyClassesScreen extends StatefulWidget {
const MyClassesScreen({super.key});

@override
State<MyClassesScreen> createState() => _MyClassesScreenState();
}

class _MyClassesScreenState extends State<MyClassesScreen>
with SingleTickerProviderStateMixin {
// =========================================================
// FIRESTORE
// =========================================================

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

// =========================================================
// ANIMATION
// =========================================================

late final AnimationController _animationController;
late final Animation<double> _fadeAnimation;
late final Animation<Offset> _slideAnimation;

@override
void initState() {
super.initState();

_animationController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 700),
);

_fadeAnimation = CurvedAnimation(
parent: _animationController,
curve: Curves.easeOutCubic,
);

_slideAnimation = Tween<Offset>(
begin: const Offset(0, 0.06),
end: Offset.zero,
).animate(
CurvedAnimation(
parent: _animationController,
curve: Curves.easeOutCubic,
),
);

_animationController.forward();
}

@override
void dispose() {
_animationController.dispose();
super.dispose();
}

// =========================================================
// BUILD
// =========================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.background,
appBar: AppBar(
title: const Text(
'My Classes',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
),
body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
stream: _firestore
    .collection('classes')
    .orderBy('date')
    .snapshots(),
builder: (context, snapshot) {
if (snapshot.hasError) {
return _buildErrorState();
}

if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

final classes = snapshot.data?.docs ?? [];

if (classes.isEmpty) {
return _buildEmptyState();
}

return RefreshIndicator(
onRefresh: () async {
await _firestore
    .collection('classes')
    .get();
},
child: FadeTransition(
opacity: _fadeAnimation,
child: SlideTransition(
position: _slideAnimation,
child: ListView.builder(
physics:
const AlwaysScrollableScrollPhysics(),
padding: const EdgeInsets.all(
AppDimensions.paddingLarge,
),
itemCount: classes.length,
itemBuilder: (context, index) {
final data =
classes[index].data();

return _buildClassCard(data);
},
),
),
),
);
},
),
);
}

// =========================================================
// CLASS CARD
// =========================================================

Widget _buildClassCard(
Map<String, dynamic> data,
) {
final String courseName =
(data['courseName'] ?? 'IT Course').toString();

final String title =
(data['title'] ?? 'Class').toString();

final String instructor =
(data['instructorName'] ?? 'Instructor')
    .toString();

final String date =
(data['date'] ?? 'Date not available').toString();

final String startTime =
(data['startTime'] ?? '').toString();

final String endTime =
(data['endTime'] ?? '').toString();

final String campus =
(data['campus'] ?? 'Campus not available')
    .toString();

final String room =
(data['room'] ?? 'Room not available')
    .toString();

final String status =
(data['status'] ?? 'upcoming').toString();

return Card(
elevation: 0,
margin: const EdgeInsets.only(
bottom: 16,
),
child: Padding(
padding: const EdgeInsets.all(
AppDimensions.paddingLarge,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// =================================================
// HEADER
// =================================================

Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 54,
height: 54,
decoration: BoxDecoration(
color: AppColors.accentLight,
borderRadius:
BorderRadius.circular(16),
),
child: Icon(
Icons.school_rounded,
color: AppColors.primary,
size: 28,
),
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
fontSize: 17,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 4),

Text(
courseName,
style: const TextStyle(
fontSize: 12,
color:
AppColors.textSecondary,
),
),
],
),
),

_buildStatusBadge(status),
],
),

const SizedBox(height: 20),

// =================================================
// DATE & TIME
// =================================================

_buildInfoRow(
Icons.calendar_today_outlined,
date,
),

const SizedBox(height: 10),

_buildInfoRow(
Icons.access_time_rounded,
'$startTime - $endTime',
),

const SizedBox(height: 10),

// =================================================
// INSTRUCTOR
// =================================================

_buildInfoRow(
Icons.person_outline_rounded,
instructor,
),

const SizedBox(height: 10),

// =================================================
// CAMPUS
// =================================================

_buildInfoRow(
Icons.location_on_outlined,
'$campus • $room',
),
],
),
),
);
}

// =========================================================
// INFO ROW
// =========================================================

Widget _buildInfoRow(
IconData icon,
String text,
) {
return Row(
children: [
Icon(
icon,
size: 18,
color: AppColors.primary,
),

const SizedBox(width: 9),

Expanded(
child: Text(
text,
style: const TextStyle(
fontSize: 13,
color: AppColors.textSecondary,
),
),
),
],
);
}

// =========================================================
// STATUS
// =========================================================

Widget _buildStatusBadge(
String status,
) {
final bool isCompleted =
status.toLowerCase() == 'completed';

final bool isCancelled =
status.toLowerCase() == 'cancelled';

String label = 'Upcoming';

if (isCompleted) {
label = 'Completed';
} else if (isCancelled) {
label = 'Cancelled';
}

return Container(
padding: const EdgeInsets.symmetric(
horizontal: 10,
vertical: 6,
),
decoration: BoxDecoration(
color: AppColors.accentLight,
borderRadius: BorderRadius.circular(20),
),
child: Text(
label,
style: const TextStyle(
fontSize: 10,
fontWeight: FontWeight.w700,
),
),
);
}

// =========================================================
// EMPTY STATE
// =========================================================

Widget _buildEmptyState() {
return Center(
child: Padding(
padding: const EdgeInsets.all(30),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons.event_busy_rounded,
size: 64,
color: AppColors.textSecondary,
),

const SizedBox(height: 16),

Text(
'No classes available',
style: AppTextStyles.heading2,
textAlign: TextAlign.center,
),

const SizedBox(height: 8),

const Text(
'Your upcoming classes will appear here.',
textAlign: TextAlign.center,
style: TextStyle(
color: AppColors.textSecondary,
),
),
],
),
),
);
}

// =========================================================
// ERROR STATE
// =========================================================

Widget _buildErrorState() {
return Center(
child: Padding(
padding: const EdgeInsets.all(30),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
const Icon(
Icons.error_outline_rounded,
size: 60,
color: AppColors.primary,
),

const SizedBox(height: 16),

Text(
'Unable to load classes',
style: AppTextStyles.heading2,
textAlign: TextAlign.center,
),

const SizedBox(height: 8),

const Text(
'Please check your internet connection and try again.',
textAlign: TextAlign.center,
style: TextStyle(
color: AppColors.textSecondary,
),
),
],
),
),
);
}
}

