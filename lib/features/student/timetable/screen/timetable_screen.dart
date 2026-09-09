import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../models/batch_model.dart';
import '../../../../models/user_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/batch_service.dart';

class TimetableScreen extends StatefulWidget {
const TimetableScreen({
super.key,
});

@override
State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
final AuthService _authService = AuthService.instance;
final BatchService _batchService = BatchService.instance;

UserModel? _profile;
BatchModel? _batch;

bool _isLoading = true;
String? _error;

@override
void initState() {
super.initState();
_loadTimetable();
}

Future<void> _loadTimetable() async {
if (!mounted) return;

setState(() {
_isLoading = true;
_error = null;
});

try {
final profile = await _authService.getCurrentUserProfile();

if (!mounted) return;

if (profile == null) {
setState(() {
_error = 'Student profile was not found.';
_isLoading = false;
});
return;
}

_profile = profile;

final batchId = profile.batchId;

if (batchId == null || batchId.trim().isEmpty) {
setState(() {
_error = 'No batch has been assigned to your profile yet.';
_isLoading = false;
});
return;
}

final batch = await _batchService.getBatchById(
batchId,
);

if (!mounted) return;

if (batch == null) {
setState(() {
_error = 'Batch information could not be found.';
_isLoading = false;
});
return;
}

setState(() {
_batch = batch;
_isLoading = false;
});
} catch (e) {
if (!mounted) return;

setState(() {
_error = _cleanError(e);
_isLoading = false;
});
}
}

String _cleanError(Object error) {
final message = error.toString();

if (message.startsWith('Exception: ')) {
return message.substring(11);
}

return message;
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.background,
appBar: AppBar(
backgroundColor: AppColors.background,
elevation: 0,
title: const Text(
'Class Timetable',
),
centerTitle: false,
actions: [
IconButton(
onPressed: _isLoading ? null : _loadTimetable,
tooltip: 'Refresh',
icon: const Icon(
Icons.refresh_rounded,
),
),
],
),
body: _buildBody(),
);
}

Widget _buildBody() {
if (_isLoading) {
return const Center(
child: LoadingWidget(),
);
}

if (_error != null) {
return _buildErrorState();
}

if (_batch == null) {
return _buildEmptyState();
}

return RefreshIndicator(
onRefresh: _loadTimetable,
child: SingleChildScrollView(
physics: const AlwaysScrollableScrollPhysics(),
padding: const EdgeInsets.all(
AppDimensions.paddingMedium,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
FadeSlideAnimation(
child: _buildStudentCard(),
),
const SizedBox(height: 20),
FadeSlideAnimation(
child: _buildBatchCard(),
),
const SizedBox(height: 20),
FadeSlideAnimation(
child: _buildScheduleCard(),
),
const SizedBox(height: 24),
FadeSlideAnimation(
child: _buildWeeklyTimetable(),
),
],
),
),
);
}

Widget _buildErrorState() {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.error_outline_rounded,
size: 60,
color: Colors.red.shade400,
),
const SizedBox(height: 16),
const Text(
'Something went wrong',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 21,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 10),
Text(
_error ?? 'Unable to load timetable.',
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 14,
),
),
const SizedBox(height: 24),
ElevatedButton.icon(
onPressed: _loadTimetable,
icon: const Icon(
Icons.refresh_rounded,
),
label: const Text(
'Retry',
),
),
],
),
),
);
}

Widget _buildEmptyState() {
return const Center(
child: Padding(
padding: EdgeInsets.all(24),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.calendar_month_outlined,
size: 60,
),
SizedBox(height: 16),
Text(
'No timetable available.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w600,
),
),
SizedBox(height: 8),
Text(
'Your class schedule will appear here once a batch is assigned.',
textAlign: TextAlign.center,
),
],
),
),
);
}

Widget _buildStudentCard() {
final name = _profile?.name.trim();

return Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: AppColors.border,
),
),
child: Row(
children: [
CircleAvatar(
radius: 28,
backgroundColor: AppColors.primary.withAlpha(25),
child: const Icon(
Icons.person_rounded,
size: 30,
color: AppColors.primary,
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Student',
style: AppTextStyles.bodySmall.copyWith(
color: AppColors.textSecondary,
),
),
const SizedBox(height: 4),
Text(
name == null || name.isEmpty
? 'Student'
    : name,
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: AppTextStyles.heading3,
),
if (_profile?.courseId != null &&
_profile!.courseId!.trim().isNotEmpty) ...[
const SizedBox(height: 4),
Text(
'Course ID: ${_profile!.courseId}',
style: AppTextStyles.bodySmall.copyWith(
color: AppColors.textSecondary,
),
),
],
],
),
),
],
),
);
}

Widget _buildBatchCard() {
final batch = _batch!;

return Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: AppColors.primary,
borderRadius: BorderRadius.circular(18),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Row(
children: [
Icon(
Icons.groups_rounded,
color: Colors.white,
size: 24,
),
SizedBox(width: 10),
Expanded(
child: Text(
'Batch Information',
style: TextStyle(
color: Colors.white,
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
),
],
),
const SizedBox(height: 18),
_buildBatchInfoRow(
icon: Icons.badge_outlined,
label: 'Batch ID',
value: batch.id,
),
const SizedBox(height: 12),
_buildBatchInfoRow(
icon: Icons.calendar_today_rounded,
label: 'Class Day',
value: batch.classDay,
),
const SizedBox(height: 12),
_buildBatchInfoRow(
icon: Icons.access_time_rounded,
label: 'Class Time',
value: batch.classTime,
),
if (batch.room.trim().isNotEmpty) ...[
const SizedBox(height: 12),
_buildBatchInfoRow(
icon: Icons.location_on_outlined,
label: 'Room',
value: batch.room,
),
],
],
),
);
}

Widget _buildBatchInfoRow({
required IconData icon,
required String label,
required String value,
}) {
return Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const SizedBox(
width: 24,
child: Icon(
Icons.circle,
size: 7,
color: Colors.white70,
),
),
const SizedBox(width: 8),
Expanded(
child: RichText(
text: TextSpan(
children: [
TextSpan(
text: '$label: ',
style: const TextStyle(
color: Colors.white70,
fontSize: 13,
),
),
TextSpan(
text: value.trim().isEmpty
? 'Not available'
    : value,
style: const TextStyle(
color: Colors.white,
fontSize: 14,
fontWeight: FontWeight.w600,
),
),
],
),
),
),
],
);
}

Widget _buildScheduleCard() {
final batch = _batch!;

String startDate = 'Not available';

if (batch.startDate != null) {
startDate = DateFormat(
'dd MMM yyyy',
).format(batch.startDate!);
}

return Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: AppColors.border,
),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
padding: const EdgeInsets.all(10),
decoration: BoxDecoration(
color: AppColors.accent.withAlpha(25),
borderRadius: BorderRadius.circular(12),
),
child: const Icon(
Icons.school_rounded,
color: AppColors.accent,
),
),
const SizedBox(width: 12),
const Expanded(
child: Text(
'Class Schedule',
style: AppTextStyles.heading3,
),
),
],
),
const SizedBox(height: 18),
_buildScheduleItem(
icon: Icons.calendar_month_rounded,
title: 'Starting Date',
value: startDate,
),
const SizedBox(height: 14),
_buildScheduleItem(
icon: Icons.event_rounded,
title: 'Class Day',
value: batch.classDay,
),
const SizedBox(height: 14),
_buildScheduleItem(
icon: Icons.schedule_rounded,
title: 'Class Time',
value: batch.classTime,
),
if (batch.room.trim().isNotEmpty) ...[
const SizedBox(height: 14),
_buildScheduleItem(
icon: Icons.meeting_room_outlined,
title: 'Room',
value: batch.room,
),
],
],
),
);
}

Widget _buildScheduleItem({
required IconData icon,
required String title,
required String value,
}) {
return Row(
children: [
Container(
padding: const EdgeInsets.all(9),
decoration: BoxDecoration(
color: AppColors.background,
borderRadius: BorderRadius.circular(10),
),
child: Icon(
icon,
size: 20,
color: AppColors.primary,
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: AppTextStyles.bodySmall.copyWith(
color: AppColors.textSecondary,
),
),
const SizedBox(height: 3),
Text(
value.trim().isEmpty
? 'Not available'
    : value,
style: AppTextStyles.bodyMedium.copyWith(
fontWeight: FontWeight.w600,
),
),
],
),
),
],
);
}

Widget _buildWeeklyTimetable() {
final batch = _batch!;

return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Weekly Timetable',
style: AppTextStyles.heading2,
),
const SizedBox(height: 12),
_buildClassDayCard(
day: batch.classDay,
time: batch.classTime,
room: batch.room,
),
],
);
}

Widget _buildClassDayCard({
required String day,
required String time,
required String room,
}) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: AppColors.primary.withAlpha(60),
),
),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: 50,
height: 50,
decoration: BoxDecoration(
color: AppColors.primary.withAlpha(25),
borderRadius: BorderRadius.circular(14),
),
child: const Icon(
Icons.calendar_today_rounded,
color: AppColors.primary,
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
day.trim().isEmpty
? 'Class Day'
    : day,
style: AppTextStyles.heading3,
),
const SizedBox(height: 8),
Row(
children: [
const Icon(
Icons.access_time_rounded,
size: 17,
color: AppColors.textSecondary,
),
const SizedBox(width: 6),
Expanded(
child: Text(
time.trim().isEmpty
? 'Time not available'
    : time,
style: AppTextStyles.bodyMedium,
),
),
],
),
if (room.trim().isNotEmpty) ...[
const SizedBox(height: 7),
Row(
children: [
const Icon(
Icons.location_on_outlined,
size: 17,
color: AppColors.textSecondary,
),
const SizedBox(width: 6),
Expanded(
child: Text(
room,
style: AppTextStyles.bodySmall.copyWith(
color: AppColors.textSecondary,
),
),
),
],
),
],
],
),
),
],
),
);
}
}
