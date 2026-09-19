import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/campus_model.dart';
import '../../../services/campus_service.dart';
import '../services/coordinator_notice_service.dart';

class CoordinatorNoticesScreen extends StatefulWidget {
const CoordinatorNoticesScreen({
super.key,
});

@override
State<CoordinatorNoticesScreen> createState() =>
_CoordinatorNoticesScreenState();
}

class _CoordinatorNoticesScreenState
extends State<CoordinatorNoticesScreen> {
final CoordinatorNoticeService _noticeService =
CoordinatorNoticeService.instance;

final CampusService _campusService =
CampusService.instance;

bool _isLoading = true;
String? _error;

List<Map<String, dynamic>> _notices = [];
List<CampusModel> _campuses = [];

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
final noticesFuture = _noticeService.getNotices();
final campusesFuture = _campusService.getActiveCampuses();

final results = await Future.wait([
noticesFuture,
campusesFuture,
]);

if (!mounted) return;

setState(() {
_notices = results[0] as List<Map<String, dynamic>>;
_campuses = results[1] as List<CampusModel>;
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
// CREATE
// ============================================================

Future<void> _createNotice() async {
if (_campuses.isEmpty) {
_showMessage(
'No active campuses found. Please create a campus first.',
);
return;
}

await showDialog(
context: context,
builder: (dialogContext) {
return _NoticeFormDialog(
campuses: _campuses,
onSave: ({
required String title,
required String message,
required String campusId,
required String campusName,
}) async {
await _noticeService.createNotice(
title: title,
message: message,
campusId: campusId,
campusName: campusName,
);

if (!mounted) return;

Navigator.pop(dialogContext);

_showMessage(
'Notice posted successfully.',
);

await _loadData();
},
);
},
);
}

// ============================================================
// EDIT
// ============================================================

Future<void> _editNotice(
Map<String, dynamic> notice,
) async {
if (_campuses.isEmpty) {
_showMessage(
'No active campuses found.',
);
return;
}

await showDialog(
context: context,
builder: (dialogContext) {
return _NoticeFormDialog(
campuses: _campuses,
notice: notice,
onSave: ({
required String title,
required String message,
required String campusId,
required String campusName,
}) async {
await _noticeService.updateNotice(
noticeId: notice['id'].toString(),
title: title,
message: message,
campusId: campusId,
campusName: campusName,
);

if (!mounted) return;

Navigator.pop(dialogContext);

_showMessage(
'Notice updated successfully.',
);

await _loadData();
},
);
},
);
}

// ============================================================
// ACTIVE STATUS
// ============================================================

Future<void> _toggleNotice(
Map<String, dynamic> notice,
) async {
final isActive =
notice['isActive'] as bool? ?? true;

try {
await _noticeService.setNoticeActiveStatus(
noticeId: notice['id'].toString(),
isActive: !isActive,
);

if (!mounted) return;

_showMessage(
isActive
? 'Notice deactivated.'
    : 'Notice activated.',
);

await _loadData();
} catch (e) {
if (!mounted) return;

_showMessage(
'Unable to update notice: $e',
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
// DATE
// ============================================================

String _formatDate(dynamic value) {
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
date.day.toString().padLeft(2, '0');

final month =
date.month.toString().padLeft(2, '0');

final hour =
date.hour.toString().padLeft(2, '0');

final minute =
date.minute.toString().padLeft(2, '0');

return '$day/$month/${date.year} '
'$hour:$minute';
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
'Campus Notices',
),
actions: [
IconButton(
onPressed:
_isLoading ? null : _loadData,
tooltip: 'Refresh',
icon: const Icon(
Icons.refresh,
),
),
],
),
floatingActionButton:
FloatingActionButton.extended(
onPressed:
_isLoading ? null : _createNotice,
icon: const Icon(
Icons.add_alert_outlined,
),
label: const Text(
'Post Notice',
),
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
'Unable to load notices',
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

if (_notices.isEmpty) {
return RefreshIndicator(
onRefresh: _loadData,
child: ListView(
physics:
const AlwaysScrollableScrollPhysics(),
children: const [
SizedBox(height: 180),
Icon(
Icons.campaign_outlined,
size: 70,
),
SizedBox(height: 16),
Center(
child: Text(
'No notices yet.',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
),
SizedBox(height: 8),
Center(
child: Text(
'Post a notice for your campus.',
),
),
],
),
);
}

return RefreshIndicator(
onRefresh: _loadData,
child: ListView.builder(
physics:
const AlwaysScrollableScrollPhysics(),
padding: const EdgeInsets.fromLTRB(
16,
16,
16,
100,
),
itemCount: _notices.length,
itemBuilder: (context, index) {
return _buildNoticeCard(
_notices[index],
);
},
),
);
}

// ============================================================
// NOTICE CARD
// ============================================================

Widget _buildNoticeCard(
Map<String, dynamic> notice,
) {
final title =
notice['title']?.toString() ?? '';

final message =
notice['message']?.toString() ?? '';

final campusName =
notice['campusName']?.toString() ?? '';

final isActive =
notice['isActive'] as bool? ?? true;

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
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Icon(
Icons.campaign_outlined,
size: 26,
),
const SizedBox(width: 10),
Expanded(
child: Text(
title,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
),
Switch(
value: isActive,
onChanged: (_) =>
_toggleNotice(notice),
),
],
),

const SizedBox(height: 8),

Text(
message,
style: const TextStyle(
height: 1.4,
),
),

const SizedBox(height: 14),

Row(
children: [
const Icon(
Icons.location_on_outlined,
size: 17,
),
const SizedBox(width: 6),
Expanded(
child: Text(
campusName.isEmpty
? 'All Campuses'
    : campusName,
style: const TextStyle(
fontWeight: FontWeight.w600,
),
),
),
],
),

const SizedBox(height: 6),

Text(
_formatDate(
notice['createdAt'],
),
style: TextStyle(
fontSize: 12,
color: Colors.grey.shade600,
),
),

const Divider(
height: 24,
),

Align(
alignment:
Alignment.centerRight,
child: OutlinedButton.icon(
onPressed: () =>
_editNotice(notice),
icon: const Icon(
Icons.edit_outlined,
),
label: const Text(
'Edit',
),
),
),
],
),
),
);
}
}

// ==================================================================
// NOTICE FORM
// ==================================================================

class _NoticeFormDialog extends StatefulWidget {
final List<CampusModel> campuses;
final Map<String, dynamic>? notice;

final Future<void> Function({
required String title,
required String message,
required String campusId,
required String campusName,
}) onSave;

const _NoticeFormDialog({
required this.campuses,
required this.onSave,
this.notice,
});

@override
State<_NoticeFormDialog> createState() =>
_NoticeFormDialogState();
}

class _NoticeFormDialogState
extends State<_NoticeFormDialog> {
final _formKey =
GlobalKey<FormState>();

late final TextEditingController
_titleController;

late final TextEditingController
_messageController;

String _selectedCampusId = '';
String _selectedCampusName = '';

bool _saving = false;

bool get _isEdit =>
widget.notice != null;

@override
void initState() {
super.initState();

final notice = widget.notice;

_titleController =
TextEditingController(
text: notice?['title']?.toString() ?? '',
);

_messageController =
TextEditingController(
text: notice?['message']?.toString() ?? '',
);

final savedCampusId =
notice?['campusId']?.toString() ?? '';

final savedCampusName =
notice?['campusName']?.toString() ?? '';

final matchingCampus =
widget.campuses.where(
(campus) => campus.id == savedCampusId,
);

if (matchingCampus.isNotEmpty) {
_selectedCampusId =
matchingCampus.first.id;
_selectedCampusName =
matchingCampus.first.name;
} else {
_selectedCampusId = '';
_selectedCampusName =
savedCampusName;
}
}

@override
void dispose() {
_titleController.dispose();
_messageController.dispose();

super.dispose();
}

// ============================================================
// SAVE
// ============================================================

Future<void> _save() async {
if (!_formKey.currentState!.validate()) {
return;
}

if (_selectedCampusId.isEmpty) {
_showError(
'Please select a campus.',
);
return;
}

setState(() {
_saving = true;
});

try {
await widget.onSave(
title:
_titleController.text.trim(),
message:
_messageController.text.trim(),
campusId:
_selectedCampusId,
campusName:
_selectedCampusName,
);
} catch (e) {
if (!mounted) return;

setState(() {
_saving = false;
});

_showError(
e.toString().replaceFirst(
'Exception: ',
'',
),
);
}
}

void _showError(String message) {
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
return AlertDialog(
title: Text(
_isEdit
? 'Edit Notice'
    : 'Post Campus Notice',
),
content: SizedBox(
width: 520,
child: Form(
key: _formKey,
child: SingleChildScrollView(
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [
TextFormField(
controller:
_titleController,
textCapitalization:
TextCapitalization
    .sentences,
decoration:
const InputDecoration(
labelText:
'Notice Title',
hintText:
'e.g. Class Cancelled',
prefixIcon:
Icon(
Icons
    .title_outlined,
),
),
validator: (value) {
if (value == null ||
value
    .trim()
    .isEmpty) {
return 'Title is required.';
}

return null;
},
),

const SizedBox(
height: 16,
),

TextFormField(
controller:
_messageController,
minLines: 4,
maxLines: 7,
textCapitalization:
TextCapitalization
    .sentences,
decoration:
const InputDecoration(
labelText:
'Message',
hintText:
'Write your campus notice...',
prefixIcon:
Icon(
Icons
    .description_outlined,
),
alignLabelWithHint:
true,
),
validator: (value) {
if (value == null ||
value
    .trim()
    .isEmpty) {
return 'Message is required.';
}

return null;
},
),

const SizedBox(
height: 16,
),

DropdownButtonFormField<
String>(
initialValue:
_selectedCampusId
    .isEmpty
? null
    : widget.campuses.any(
(campus) =>
campus.id ==
_selectedCampusId,
)
? _selectedCampusId
    : null,
decoration:
const InputDecoration(
labelText:
'Campus',
prefixIcon:
Icon(
Icons
    .location_city_outlined,
),
),
isExpanded: true,
items: widget.campuses
    .map(
(campus) =>
DropdownMenuItem<
String>(
value:
campus.id,
child: Text(
campus.name,
overflow:
TextOverflow
    .ellipsis,
),
),
).toList(),
onChanged:
_saving
? null
    : (value) {
if (value ==
null) {
return;
}

final campus =
widget.campuses
    .firstWhere(
(item) =>
item.id ==
value,
);

setState(() {
_selectedCampusId =
campus.id;

_selectedCampusName =
campus.name;
});
},
validator: (value) {
if (value == null ||
value.isEmpty) {
return 'Select a campus.';
}

return null;
},
),
],
),
),
),
),
actions: [
TextButton(
onPressed: _saving
? null
    : () =>
Navigator.pop(
context,
),
child: const Text(
'Cancel',
),
),
ElevatedButton.icon(
onPressed:
_saving ? null : _save,
icon: _saving
? const SizedBox(
width: 18,
height: 18,
child:
CircularProgressIndicator(
strokeWidth: 2,
),
)
    : const Icon(
Icons.send_outlined,
),
label: Text(
_saving
? 'Posting...'
    : _isEdit
? 'Update Notice'
    : 'Post Notice',
),
),
],
);
}
}

