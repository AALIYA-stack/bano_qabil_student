import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentSeedData {
AssignmentSeedData._();

static final List<Map<String, dynamic>> assignments = [
{
'id': 'assignment_001',
'batchId': 'flutter-batch-01',
'courseId': 'flutter',
'title': 'Flutter UI Basics',
'description':
'Create a simple Flutter interface using basic widgets.',
'instructions':
'Build a clean Flutter screen using Column, Row, Container and Text widgets.',
'dueDate': Timestamp.fromDate(
DateTime.now().add(
const Duration(days: 7),
),
),
'totalMarks': 100,
'createdBy': '',
'createdAt': Timestamp.now(),
'isQuiz': false,
},
{
'id': 'assignment_002',
'batchId': 'flutter-batch-01',
'courseId': 'flutter',
'title': 'Flutter Navigation',
'description':
'Implement navigation between two Flutter screens.',
'instructions':
'Create two screens and navigate between them using Flutter routes.',
'dueDate': Timestamp.fromDate(
DateTime.now().add(
const Duration(days: 10),
),
),
'totalMarks': 100,
'createdBy': '',
'createdAt': Timestamp.now(),
'isQuiz': false,
},
{
'id': 'assignment_003',
'batchId': 'flutter-batch-01',
'courseId': 'flutter',
'title': 'Firebase Firestore Practice',
'description':
'Connect a Flutter application with Firebase Firestore.',
'instructions':
'Create a Firestore collection and read/write sample data from Flutter.',
'dueDate': Timestamp.fromDate(
DateTime.now().subtract(
const Duration(days: 2),
),
),
'totalMarks': 100,
'createdBy': '',
'createdAt': Timestamp.now(),
'isQuiz': false,
},
{
'id': 'assignment_004',
'batchId': 'flutter-batch-01',
'courseId': 'flutter',
'title': 'Student App Final Task',
'description':
'Build a small Flutter application demonstrating the course concepts.',
'instructions':
'Submit a working Flutter application with Firebase integration.',
'dueDate': Timestamp.fromDate(
DateTime.now().subtract(
const Duration(days: 5),
),
),
'totalMarks': 100,
'createdBy': '',
'createdAt': Timestamp.now(),
'isQuiz': false,
},
];
}
