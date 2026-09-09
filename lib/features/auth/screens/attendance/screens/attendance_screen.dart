import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/animations/fade_slide_animation.dart';
import '../../../../../models/attendance_model.dart';
import '../../../../../services/attendance_service.dart';
import '../../../../../services/auth_service.dart';
import '../../../../student/attendence/widget/attendance_status_badge.dart';
import '../../../../../core/widgets/loading_widget.dart';

class AttendanceScreen extends StatefulWidget {
const AttendanceScreen({
super.key,
});

@override
State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
bool _isLoading = true;
String? _error;

List<AttendanceModel> _records = [];

DateTime _selectedMonth = DateTime.now();

String? _batchId;

@override
void initState() {
super.initState();
_loadAttendance();
}

Future<void> _loadAttendance() async {
if (!mounted) return;

setState(() {
_isLoading = true;
_error = null;
});

try {
final profile =
await AuthService.instance.getCurrentUserProfile();

if (profile == null) {
throw Exception(
'Student profile was not found.',
);
}

final batchId = profile.batchId;

if (batchId == null || batchId.trim().isEmpty) {
if (!mounted) return;

setState(() {
_batchId = null;
_records = [];
_isLoading = false;
});

return;
}

final records =
await AttendanceService.instance.getMonthlyAttendance(
batchId: batchId,
year: _selectedMonth.year,
month: _selectedMonth.month,
);

if (!mounted) return;

setState(() {
_batchId = batchId;
_records = records;
_isLoading = false;
});
} catch (e) {
if (!mounted) return;

setState(() {
_error = e.toString().replaceFirst(
'Exception: ',
'',
);
_isLoading = false;
});
}
}

void _previousMonth() {
setState(() {
_selectedMonth = DateTime(
_selectedMonth.year,
_selectedMonth.month - 1,
);
});

_loadAttendance();
}

void _nextMonth() {
final now = DateTime.now();

final next = DateTime(
_selectedMonth.year,
_selectedMonth.month + 1,
);

if (next.isAfter(
DateTime(now.year, now.month),
)) {
return;
}

setState(() {
_selectedMonth = next;
});

_loadAttendance();
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.background,
appBar: AppBar(
title: const Text('Attendance'),
centerTitle: false,
),
body: _buildBody(),
);
}

Widget _buildBody() {
if (_isLoading) {
return const LoadingWidget();
}

if (_error != null) {
return _buildError();
}

if (_batchId == null) {
return _buildNoBatch();
}

return RefreshIndicator(
onRefresh: _loadAttendance,
child: ListView(
padding: const EdgeInsets.all(
AppDimensions.paddingMedium,
),
children: [
FadeSlideAnimation(
child: _buildSummaryCard(),
),

const SizedBox(height: 20),

FadeSlideAnimation(
delay: const Duration(milliseconds: 100),
child: _buildMonthSelector(),
),

const SizedBox(height: 16),

FadeSlideAnimation(
delay: const Duration(milliseconds: 150),
child: _buildCalendar(),
),

const SizedBox(height: 20),

FadeSlideAnimation(
delay: const Duration(milliseconds: 200),
child: _buildLegend(),
),

const SizedBox(height: 24),

FadeSlideAnimation(
delay: const Duration(milliseconds: 250),
child: _buildHistory(),
),
],
),
);
}

Widget _buildError() {
return Center(
child: Padding(
padding: const EdgeInsets.all(32),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Container(
width: 70,
height: 70,
decoration: BoxDecoration(
color: AppColors.error.withAlpha(20),
shape: BoxShape.circle,
),
child: const Icon(
Icons.error_outline_rounded,
color: AppColors.error,
size: 36,
),
),
const SizedBox(height: 18),
Text(
'Unable to Load Attendance',
style: AppTextStyles.heading2,
textAlign: TextAlign.center,
),
const SizedBox(height: 8),
Text(
_error ?? 'Something went wrong.',
style: AppTextStyles.bodyMedium,
textAlign: TextAlign.center,
),
const SizedBox(height: 20),
ElevatedButton.icon(
onPressed: _loadAttendance,
icon: const Icon(
Icons.refresh_rounded,
),
label: const Text('Try Again'),
),
],
),
),
);
}

Widget _buildNoBatch() {
return Center(
child: Padding(
padding: const EdgeInsets.all(32),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.school_outlined,
size: 64,
color: AppColors.primary.withAlpha(90),
),
const SizedBox(height: 16),
Text(
'No Batch Assigned',
style: AppTextStyles.heading2,
textAlign: TextAlign.center,
),
const SizedBox(height: 8),
Text(
'Your attendance will appear here once you are assigned to a batch.',
style: AppTextStyles.bodyMedium,
textAlign: TextAlign.center,
),
],
),
),
);
}

Widget _buildSummaryCard() {
final percentage =
AttendanceService.instance.calculatePercentage(
_records,
);

final present =
AttendanceService.instance.countStatus(
_records,
'present',
);

final absent =
AttendanceService.instance.countStatus(
_records,
'absent',
);

final leave =
AttendanceService.instance.countStatus(
_records,
'leave',
);

return Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
gradient: const LinearGradient(
colors: [
AppColors.primaryDark,
AppColors.primary,
],
),
borderRadius: BorderRadius.circular(
AppDimensions.radiusLarge,
),
boxShadow: [
BoxShadow(
color: AppColors.primary.withAlpha(46),
blurRadius: 18,
offset: const Offset(0, 8),
),
],
),
child: Row(
children: [
TweenAnimationBuilder<double>(
tween: Tween<double>(
begin: 0,
end: percentage / 100,
),
duration: const Duration(
milliseconds: 900,
),
curve: Curves.easeOutCubic,
builder: (
context,
value,
child,
) {
return SizedBox(
width: 105,
height: 105,
child: Stack(
alignment: Alignment.center,
children: [
SizedBox(
width: 100,
height: 100,
child: CircularProgressIndicator(
value: value.clamp(0.0, 1.0),
strokeWidth: 9,
backgroundColor:
Colors.white.withAlpha(46),
valueColor:
const AlwaysStoppedAnimation<Color>(
Colors.white,
),
),
),
Text(
'${percentage.round()}%',
style: const TextStyle(
color: Colors.white,
fontSize: 22,
fontWeight: FontWeight.w700,
),
),
],
),
);
},
),

const SizedBox(width: 20),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Monthly Attendance',
style: TextStyle(
color: Colors.white70,
fontSize: 13,
),
),
const SizedBox(height: 5),
Text(
DateFormat(
'MMMM yyyy',
).format(_selectedMonth),
style: const TextStyle(
color: Colors.white,
fontSize: 18,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 14),
Row(
children: [
_stat(
'Present',
present,
),
const SizedBox(width: 18),
_stat(
'Absent',
absent,
),
const SizedBox(width: 18),
_stat(
'Leave',
leave,
),
],
),
],
),
),
],
),
);
}

Widget _stat(
String label,
int value,
) {
return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'$value',
style: const TextStyle(
color: Colors.white,
fontSize: 17,
fontWeight: FontWeight.w700,
),
),
Text(
label,
style: const TextStyle(
color: Colors.white70,
fontSize: 11,
),
),
],
);
}

Widget _buildMonthSelector() {
final now = DateTime.now();

final isCurrentMonth =
_selectedMonth.year == now.year &&
_selectedMonth.month == now.month;

return Container(
padding: const EdgeInsets.symmetric(
horizontal: 8,
vertical: 8,
),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(
AppDimensions.radiusMedium,
),
border: Border.all(
color: AppColors.border,
),
),
child: Row(
children: [
IconButton(
onPressed: _previousMonth,
icon: const Icon(
Icons.chevron_left_rounded,
),
),

Expanded(
child: Text(
DateFormat(
'MMMM yyyy',
).format(_selectedMonth),
textAlign: TextAlign.center,
style: AppTextStyles.heading3,
),
),

IconButton(
onPressed:
isCurrentMonth ? null : _nextMonth,
icon: const Icon(
Icons.chevron_right_rounded,
),
),
],
),
);
}

Widget _buildCalendar() {
final firstDay = DateTime(
_selectedMonth.year,
_selectedMonth.month,
1,
);

final totalDays = DateTime(
_selectedMonth.year,
_selectedMonth.month + 1,
0,
).day;

final startingWeekday =
firstDay.weekday - 1;

final cells = <Widget>[];

const weekDays = [
'Mon',
'Tue',
'Wed',
'Thu',
'Fri',
'Sat',
'Sun',
];

for (final day in weekDays) {
cells.add(
Center(
child: Text(
day,
style: const TextStyle(
fontSize: 11,
fontWeight: FontWeight.w600,
color: AppColors.textSecondary,
),
),
),
);
}

for (int i = 0; i < startingWeekday; i++) {
cells.add(
const SizedBox(),
);
}

for (int day = 1; day <= totalDays; day++) {
final date = DateTime(
_selectedMonth.year,
_selectedMonth.month,
day,
);

final record = _findRecord(date);

cells.add(
_CalendarDay(
day: day,
status: record?.status,
),
);
}

return Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(
AppDimensions.radiusLarge,
),
border: Border.all(
color: AppColors.border,
),
),
child: GridView.count(
crossAxisCount: 7,
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),
mainAxisSpacing: 12,
crossAxisSpacing: 6,
children: cells,
),
);
}

AttendanceModel? _findRecord(
DateTime date,
) {
for (final record in _records) {
if (record.date.year == date.year &&
record.date.month == date.month &&
record.date.day == date.day) {
return record;
}
}

return null;
}

Widget _buildLegend() {
return const Wrap(
spacing: 14,
runSpacing: 8,
children: [
_LegendItem(
color: AppColors.success,
label: 'Present',
),
_LegendItem(
color: AppColors.error,
label: 'Absent',
),
_LegendItem(
color: AppColors.warning,
label: 'Leave',
),
_LegendItem(
color: AppColors.info,
label: 'Late',
),
_LegendItem(
color: AppColors.textLight,
label: 'No Record',
),
],
);
}

Widget _buildHistory() {
if (_records.isEmpty) {
return Container(
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(
AppDimensions.radiusLarge,
),
border: Border.all(
color: AppColors.border,
),
),
child: const Column(
children: [
Icon(
Icons.event_available_outlined,
size: 40,
color: AppColors.textLight,
),
SizedBox(height: 10),
Text(
'No attendance records',
style: AppTextStyles.heading3,
),
SizedBox(height: 5),
Text(
'Attendance records for this month will appear here.',
textAlign: TextAlign.center,
style: AppTextStyles.bodyMedium,
),
],
),
);
}

final sortedRecords =
List<AttendanceModel>.from(_records)
..sort(
(a, b) => b.date.compareTo(a.date),
);

return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Attendance History',
style: AppTextStyles.heading2,
),
const SizedBox(height: 12),

...sortedRecords.asMap().entries.map(
(entry) {
final index = entry.key;
final record = entry.value;

return Padding(
padding: const EdgeInsets.only(
bottom: 10,
),
child: FadeSlideAnimation(
delay: Duration(
milliseconds:
280 + (index * 60),
),
child: Container(
padding:
const EdgeInsets.all(14),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius:
BorderRadius.circular(
AppDimensions.radiusMedium,
),
border: Border.all(
color: AppColors.border,
),
),
child: Row(
children: [
Container(
width: 44,
height: 44,
decoration:
BoxDecoration(
color: AppColors.primary
    .withAlpha(20),
borderRadius:
BorderRadius.circular(
12,
),
),
child: const Icon(
Icons
    .calendar_today_outlined,
size: 20,
color:
AppColors.primary,
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
DateFormat(
'EEE, dd MMM yyyy',
).format(
record.date,
),
style: AppTextStyles
    .bodyLarge
    .copyWith(
fontWeight:
FontWeight
    .w600,
),
),
const SizedBox(
height: 3,
),
Text(
'Class attendance',
style:
AppTextStyles
    .bodySmall,
),
],
),
),

AttendanceStatusBadge(
status: record.status,
),
],
),
),
),
);
},
),
],
);
}
}

class _CalendarDay extends StatelessWidget {
final int day;
final String? status;

const _CalendarDay({
required this.day,
required this.status,
});

Color get _color {
switch (status?.trim().toLowerCase()) {
case 'present':
return AppColors.success;

case 'absent':
return AppColors.error;

case 'leave':
return AppColors.warning;

case 'late':
return AppColors.info;

default:
return AppColors.textLight;
}
}

@override
Widget build(BuildContext context) {
final hasStatus =
status != null &&
status!.trim().isNotEmpty;

return Container(
alignment: Alignment.center,
decoration: BoxDecoration(
color: !hasStatus
? Colors.transparent
    : _color.withAlpha(20),
borderRadius:
BorderRadius.circular(10),
),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Text(
'$day',
style: TextStyle(
fontSize: 13,
fontWeight: FontWeight.w600,
color: !hasStatus
? AppColors.textSecondary
    : _color,
),
),
const SizedBox(height: 4),
if (hasStatus)
Container(
width: 5,
height: 5,
decoration: BoxDecoration(
color: _color,
shape: BoxShape.circle,
),
),
],
),
);
}
}

class _LegendItem extends StatelessWidget {
final Color color;
final String label;

const _LegendItem({
required this.color,
required this.label,
});

@override
Widget build(BuildContext context) {
return Row(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 8,
height: 8,
decoration: BoxDecoration(
color: color,
shape: BoxShape.circle,
),
),
const SizedBox(width: 6),
Text(
label,
style: AppTextStyles.bodySmall,
),
],
);
}
}
