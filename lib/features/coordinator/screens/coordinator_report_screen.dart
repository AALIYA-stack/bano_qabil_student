import 'package:flutter/material.dart';

import '../services/coordinator_report_service.dart';

class CoordinatorReportScreen
extends StatefulWidget {
const CoordinatorReportScreen({
super.key,
});

@override
State<CoordinatorReportScreen> createState() =>
_CoordinatorReportScreenState();
}

class _CoordinatorReportScreenState
extends State<CoordinatorReportScreen> {
final CoordinatorReportService _service =
CoordinatorReportService.instance;

bool _isLoading = true;
String? _error;
CoordinatorReportData? _report;

@override
void initState() {
super.initState();
_loadReport();
}

// ============================================================
// LOAD
// ============================================================

Future<void> _loadReport() async {
setState(() {
_isLoading = true;
_error = null;
});

try {
final report =
await _service.getReport();

if (!mounted) return;

setState(() {
_report = report;
_isLoading = false;
});
} catch (e) {
if (!mounted) return;

setState(() {
_error = e.toString();
_isLoading = false;
});
}
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
'Coordinator Report',
),
actions: [
IconButton(
onPressed:
_isLoading ? null : _loadReport,
icon: const Icon(Icons.refresh),
),
],
),
body: _buildBody(),
);
}

// ============================================================
// BODY
// ============================================================

Widget _buildBody() {
if (_isLoading) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (_error != null) {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(
Icons.error_outline,
size: 60,
),
const SizedBox(height: 16),
const Text(
'Unable to load report',
style: TextStyle(
fontSize: 21,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
Text(
_error!,
textAlign: TextAlign.center,
),
const SizedBox(height: 20),
ElevatedButton.icon(
onPressed: _loadReport,
icon: const Icon(Icons.refresh),
label: const Text('Retry'),
),
],
),
),
);
}

final report = _report;

if (report == null) {
return const Center(
child: Text(
'No report data available.',
),
);
}

return RefreshIndicator(
onRefresh: _loadReport,
child: ListView(
padding: const EdgeInsets.all(16),
children: [
const Text(
'Overview',
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 6),

Text(
'Current month and overall academic activity',
style: TextStyle(
color: Colors.grey.shade600,
),
),

const SizedBox(height: 20),

_buildStatCard(
icon: Icons.assignment_outlined,
title: 'Applications This Month',
value:
report.applicationsThisMonth
    .toString(),
),

const SizedBox(height: 12),

_buildStatCard(
icon: Icons.verified_outlined,
title: 'Accepted Students',
value:
report.acceptedStudents
    .toString(),
),

const SizedBox(height: 12),

_buildStatCard(
icon: Icons.fact_check_outlined,
title: 'Average Attendance',
value:
'${report.averageAttendance.toStringAsFixed(1)}%',
),

const SizedBox(height: 12),

_buildStatCard(
icon: Icons.pending_actions_outlined,
title: 'Assignments Pending',
value:
report.assignmentsPending
    .toString(),
),

const SizedBox(height: 28),

Card(
child: Padding(
padding:
const EdgeInsets.all(18),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Row(
children: [
Icon(
Icons.info_outline,
),
SizedBox(width: 10),
Text(
'Report Information',
style: TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),
],
),
const SizedBox(height: 14),
Text(
'Applications This Month is based on '
'application creation date. '
'Accepted Students counts applications '
'with accepted status. Attendance is '
'calculated from attendance records.',
style: TextStyle(
color:
Colors.grey.shade700,
height: 1.5,
),
),
],
),
),
),
],
),
);
}

// ============================================================
// STAT CARD
// ============================================================

Widget _buildStatCard({
required IconData icon,
required String title,
required String value,
}) {
return Card(
child: Padding(
padding:
const EdgeInsets.all(18),
child: Row(
children: [
Container(
width: 54,
height: 54,
decoration: BoxDecoration(
borderRadius:
BorderRadius.circular(14),
color: Theme.of(context)
    .colorScheme
    .primary
    .withValues(
alpha: 0.10,
),
),
child: Icon(
icon,
size: 28,
color: Theme.of(context)
    .colorScheme
    .primary,
),
),
const SizedBox(width: 16),
Expanded(
child: Text(
title,
style: const TextStyle(
fontSize: 15,
fontWeight:
FontWeight.w600,
),
),
),
Text(
value,
style: const TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
),
),
],
),
),
);
}
}
