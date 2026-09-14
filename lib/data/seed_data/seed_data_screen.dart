import 'package:flutter/material.dart';

import '../../services/seed_service.dart';

class SeedDataScreen extends StatefulWidget {
const SeedDataScreen({super.key});

@override
State<SeedDataScreen> createState() => _SeedDataScreenState();
}

class _SeedDataScreenState extends State<SeedDataScreen> {
bool _isLoading = false;
String _message = 'Ready to seed demo data.';

Future<void> _seedStudents() async {
if (_isLoading) return;

setState(() {
_isLoading = true;
_message = 'Seeding 12 students...';
});

try {
await SeedService.instance.seedOnlyStudents();

if (!mounted) return;

setState(() {
_isLoading = false;
_message =
'Success!\n\n'
'12 students have been added to Firebase.\n'
'Flutter batch enrollment has been updated.';
});

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'12 students seeded successfully!',
),
),
);
} catch (e) {
if (!mounted) return;

setState(() {
_isLoading = false;
_message =
'Seed failed.\n\n'
'Error:\n$e';
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Seed failed: $e',
),
),
);
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Seed Demo Data'),
),
body: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(
Icons.cloud_upload_outlined,
size: 80,
),

const SizedBox(height: 24),

const Text(
'Bano Qabil Demo Data',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 12),

const Text(
'This will create 12 demo students '
'and connect them with the Flutter batch.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 16,
),
),

const SizedBox(height: 30),

Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: Colors.grey.shade300,
),
),
child: const Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Data that will be created:',
style: TextStyle(
fontSize: 17,
fontWeight: FontWeight.bold,
),
),

SizedBox(height: 12),

Text('• 12 student profiles'),

Text('• Course: Flutter'),

Text('• Campus: Lahore'),

Text(
'• Batch: flutter-batch-01',
),

Text(
'• Batch enrollment: 12',
),

Text(
'• Seats left: 18',
),
],
),
),

const SizedBox(height: 30),

SizedBox(
width: double.infinity,
height: 52,
child: ElevatedButton.icon(
onPressed:
_isLoading ? null : _seedStudents,
icon: _isLoading
? const SizedBox(
width: 20,
height: 20,
child:
CircularProgressIndicator(
strokeWidth: 2,
),
)
    : const Icon(
Icons.cloud_upload,
),
label: Text(
_isLoading
? 'Seeding...'
    : 'Seed 12 Students',
),
),
),

const SizedBox(height: 24),

Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.grey.shade100,
borderRadius:
BorderRadius.circular(12),
),
child: Text(
_message,
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 14,
),
),
),
],
),
),
),
);
}
}

