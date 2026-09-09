import 'package:cloud_firestore/cloud_firestore.dart';

class CareerProgressModel {
  final String studentId;
  final bool cvReady;
  final bool githubReady;
  final int projectsCompleted;
  final bool mockInterviewDone;
  final int jobsApplied;
  final DateTime? updatedAt;

  const CareerProgressModel({
    required this.studentId,
    required this.cvReady,
    required this.githubReady,
    required this.projectsCompleted,
    required this.mockInterviewDone,
    required this.jobsApplied,
    required this.updatedAt,
  });

  double get readinessPercentage {
    double score = 0;

    if (cvReady) {
      score += 25;
    }

    if (githubReady) {
      score += 20;
    }

    score +=
        (projectsCompleted.clamp(0, 3) / 3) * 30;

    if (mockInterviewDone) {
      score += 15;
    }

    if (jobsApplied > 0) {
      score += 10;
    }

    return score.clamp(0, 100).toDouble();
  }

  bool get isJobReady {
    return readinessPercentage >= 80;
  }

  factory CareerProgressModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    DateTime? updatedAt;

    final updatedAtValue = data['updatedAt'];

    if (updatedAtValue is Timestamp) {
      updatedAt = updatedAtValue.toDate();
    }

    return CareerProgressModel(
      studentId:
      data['studentId']?.toString() ?? doc.id,
      cvReady:
      data['cvReady'] == true,
      githubReady:
      data['githubReady'] == true,
      projectsCompleted:
      (data['projectsCompleted'] as num?)
          ?.toInt() ??
          0,
      mockInterviewDone:
      data['mockInterviewDone'] == true,
      jobsApplied:
      (data['jobsApplied'] as num?)
          ?.toInt() ??
          0,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'cvReady': cvReady,
      'githubReady': githubReady,
      'projectsCompleted':
      projectsCompleted,
      'mockInterviewDone':
      mockInterviewDone,
      'jobsApplied':
      jobsApplied,
      'updatedAt':
      FieldValue.serverTimestamp(),
    };
  }
}