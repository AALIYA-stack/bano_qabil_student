import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionSeedData {
SubmissionSeedData._();

static final List<Map<String, dynamic>> submissions = [
{
'id': 'submission_001',
'assignmentId': 'assignment_003',
'studentId': 'student_001',
'batchId': 'flutter-batch-01',
'answerText':
'I connected the Flutter application with Firebase Firestore and tested reading and writing documents.',
'fileUrl': null,
'fileName': null,
'status': 'submitted',
'submittedAt': Timestamp.now(),
'marks': null,
'feedback': null,
'markedAt': null,
'markedBy': null,
},
{
'id': 'submission_002',
'assignmentId': 'assignment_004',
'studentId': 'student_002',
'batchId': 'flutter-batch-01',
'answerText':
'I created a Flutter student application with Firebase integration.',
'fileUrl': null,
'fileName': null,
'status': 'marked',
'submittedAt': Timestamp.now(),
'marks': 85,
'feedback':
'Good implementation. UI and Firebase integration are working well.',
'markedAt': Timestamp.now(),
'markedBy': '',
},
];
}
