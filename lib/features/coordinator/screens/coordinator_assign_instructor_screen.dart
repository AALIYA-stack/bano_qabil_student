import 'package:flutter/material.dart';

import '../../../models/batch_model.dart';
import '../services/coordinator_batch_service.dart';
import '../services/coordinator_instructor_service.dart';

class CoordinatorAssignInstructorScreen extends StatefulWidget {
const CoordinatorAssignInstructorScreen({
super.key,
});

@override
State<CoordinatorAssignInstructorScreen> createState() =>
_CoordinatorAssignInstructorScreenState();
}

class _CoordinatorAssignInstructorScreenState
extends State<CoordinatorAssignInstructorScreen> {
final CoordinatorBatchService _batchService =
CoordinatorBatchService.instance;

final CoordinatorInstructorService _instructorService =
CoordinatorInstructorService.instance;

bool _isLoading = true;
String? _error;

List<BatchModel> _batches = [];
List<Map<String, dynamic>> _instructors = [];

@override
void initState() {
super.initState();
_loadData();
}

// ============================================================
// LOAD DATA
// ============================================================

Future<void> _loadData() async {
if (mounted) {
setState(() {
_isLoading = true;
_error = null;
});
}

try {
final batchesFuture = _batchService.getBatches();
final instructorsFuture = _instructorService.getInstructors();

final results = await Future.wait([
batchesFuture,
instructorsFuture,
]);

if (!mounted) return;

setState(() {
_batches = results[0] as List<BatchModel>;
_instructors = results[1] as List<Map<String, dynamic>>;
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
// INSTRUCTOR NAME
// ============================================================

String _instructorName(String instructorId) {
if (instructorId.trim().isEmpty) {
return 'Not assigned';
}

for (final instructor in _instructors) {
if (instructor['id']?.toString() == instructorId) {
return instructor['name']?.toString().trim().isNotEmpty == true
? instructor['name'].toString()
    : 'Instructor';
}
}

return instructorId;
}

// ============================================================
// ASSIGN / CHANGE INSTRUCTOR
// ============================================================

Future<void> _assignInstructor(BatchModel batch) async {
if (_instructors.isEmpty) {
_showMessage(
'No active instructors found.',
);
return;
}

String? selectedInstructor =
batch.instructorId.trim().isEmpty ? null : batch.instructorId;

final result = await showDialog<String>(
context: context,
builder: (dialogContext) {
return StatefulBuilder(
builder: (
context,
setDialogState,
) {
return AlertDialog(
title: Text(
batch.instructorId.trim().isEmpty
? 'Assign Instructor'
    : 'Change Instructor',
),
content: SizedBox(
width: 450,
child: DropdownButtonFormField<String>(
initialValue: _instructors.any(
(instructor) =>
instructor['id']?.toString() == selectedInstructor,
)
? selectedInstructor
    : null,
decoration: const InputDecoration(
labelText: 'Instructor',
prefixIcon: Icon(
Icons.person_outline,
),
),
isExpanded: true,
items: _instructors.map(
(instructor) {
final id =
instructor['id']?.toString().trim() ?? '';

final name =
instructor['name']?.toString().trim() ?? '';

final email =
instructor['email']?.toString().trim() ?? '';

return DropdownMenuItem<String>(
value: id,
child: Text(
email.isEmpty
? name
    : '$name • $email',
overflow: TextOverflow.ellipsis,
),
);
},
).toList(),
onChanged: (value) {
setDialogState(() {
selectedInstructor = value;
});
},
),
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext);
},
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: selectedInstructor == null
? null
    : () {
Navigator.pop(
dialogContext,
selectedInstructor,
);
},
child: Text(
batch.instructorId.trim().isEmpty
? 'Assign'
    : 'Change',
),
),
],
);
},
);
},
);

if (result == null || result.trim().isEmpty) {
return;
}

try {
await _instructorService.assignInstructor(
batchId: batch.id,
instructorId: result,
);

if (!mounted) return;

_showMessage(
'Instructor assigned successfully.',
);

await _loadData();
} catch (e) {
if (!mounted) return;

_showMessage(
'Unable to assign instructor: $e',
);
}
}

// ============================================================
// REMOVE INSTRUCTOR
// ============================================================

Future<void> _removeInstructor(BatchModel batch) async {
if (batch.instructorId.trim().isEmpty) {
return;
}

final confirmed = await showDialog<bool>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text(
'Remove Instructor?',
),
content: Text(
'Remove ${_instructorName(batch.instructorId)} '
'from this batch?',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(
dialogContext,
false,
);
},
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () {
Navigator.pop(
dialogContext,
true,
);
},
child: const Text('Remove'),
),
],
);
},
);

if (confirmed != true) {
return;
}

try {
await _instructorService.removeInstructor(
batchId: batch.id,
instructorId: batch.instructorId,
);

if (!mounted) return;

_showMessage(
'Instructor removed successfully.',
);

await _loadData();
} catch (e) {
if (!mounted) return;

_showMessage(
'Unable to remove instructor: $e',
);
}
}

// ============================================================
// MESSAGE
// ============================================================

void _showMessage(String message) {
if (!mounted) return;

ScaffoldMessenger.of(context)
..hideCurrentSnackBar()
..showSnackBar(
SnackBar(
content: Text(message),
),
);
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
'Assign Instructor',
),
actions: [
IconButton(
onPressed: _isLoading ? null : _loadData,
tooltip: 'Refresh',
icon: const Icon(
Icons.refresh,
),
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
size: 56,
),
const SizedBox(height: 16),
const Text(
'Unable to load data',
style: TextStyle(
fontSize: 20,
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
onPressed: _loadData,
icon: const Icon(
Icons.refresh,
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

if (_batches.isEmpty) {
return RefreshIndicator(
onRefresh: _loadData,
child: ListView(
physics: const AlwaysScrollableScrollPhysics(),
children: const [
SizedBox(height: 220),
Center(
child: Text(
'No batches found.',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w600,
),
),
),
],
),
);
}

return RefreshIndicator(
onRefresh: _loadData,
child: ListView.builder(
physics: const AlwaysScrollableScrollPhysics(),
padding: const EdgeInsets.all(16),
itemCount: _batches.length,
itemBuilder: (context, index) {
return _buildBatchCard(
_batches[index],
);
},
),
);
}

// ============================================================
// BATCH CARD
// ============================================================

Widget _buildBatchCard(BatchModel batch) {
final instructor = _instructorName(
batch.instructorId,
);

final hasInstructor =
batch.instructorId.trim().isNotEmpty;

return Card(
margin: const EdgeInsets.only(
bottom: 14,
),
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
const Icon(
Icons.groups_outlined,
),
const SizedBox(width: 10),
Expanded(
child: Text(
batch.id,
style: const TextStyle(
fontSize: 17,
fontWeight: FontWeight.bold,
),
overflow: TextOverflow.ellipsis,
),
),
const SizedBox(width: 8),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 9,
vertical: 5,
),
decoration: BoxDecoration(
borderRadius:
BorderRadius.circular(16),
color: batch.isOpen
? Colors.green.withValues(
alpha: 0.12,
)
    : Colors.grey.withValues(
alpha: 0.12,
),
),
child: Text(
batch.isOpen
? 'OPEN'
    : 'CLOSED',
style: TextStyle(
fontSize: 11,
fontWeight: FontWeight.bold,
color: batch.isOpen
? Colors.green.shade700
    : Colors.grey.shade700,
),
),
),
],
),

const SizedBox(height: 14),

Text(
'Instructor: $instructor',
style: const TextStyle(
fontWeight: FontWeight.w600,
),
),

const SizedBox(height: 6),

Text(
'Seats: ${batch.enrolledStudents}/${batch.seats} '
'• ${batch.seatsLeft} available',
),

const SizedBox(height: 14),

Row(
children: [
Expanded(
child: ElevatedButton.icon(
onPressed: () =>
_assignInstructor(batch),
icon: const Icon(
Icons.person_add_outlined,
),
label: Text(
hasInstructor
? 'Change'
    : 'Assign',
),
),
),
if (hasInstructor) ...[
const SizedBox(width: 10),
OutlinedButton(
onPressed: () =>
_removeInstructor(batch),
child: const Text(
'Remove',
),
),
],
],
),
],
),
),
);
}
}

