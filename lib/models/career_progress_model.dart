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

    // CV = 25%
    if (cvReady) {
      score += 25;
    }

    // GitHub = 20%
    if (githubReady) {
      score += 20;
    }

    // Projects = 30%
    score +=
        (projectsCompleted.clamp(0, 3) / 3) * 30;

    // Mock Interview = 15%
    if (mockInterviewDone) {
      score += 15;
    }

    // Jobs Applied = 10%
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
    final data =
        doc.data() ?? <String, dynamic>{};

    final updatedAt =
    _parseDate(data['updatedAt']);

    return CareerProgressModel(
      studentId:
      data['studentId']?.toString() ??
          doc.id,

      cvReady:
      data['cvReady'] == true,

      githubReady:
      data['githubReady'] == true,

      projectsCompleted:
      _parseInt(
        data['projectsCompleted'],
      ).clamp(0, 3),

      mockInterviewDone:
      data['mockInterviewDone'] == true,

      jobsApplied:
      _parseInt(
        data['jobsApplied'],
      ).clamp(0, 999999),

      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'cvReady': cvReady,
      'githubReady': githubReady,
      'projectsCompleted':
      projectsCompleted.clamp(0, 3),
      'mockInterviewDone':
      mockInterviewDone,
      'jobsApplied':
      jobsApplied < 0 ? 0 : jobsApplied,
      'updatedAt':
      FieldValue.serverTimestamp(),
    };
  }

  CareerProgressModel copyWith({
    String? studentId,
    bool? cvReady,
    bool? githubReady,
    int? projectsCompleted,
    bool? mockInterviewDone,
    int? jobsApplied,
    DateTime? updatedAt,
  }) {
    return CareerProgressModel(
      studentId:
      studentId ?? this.studentId,
      cvReady:
      cvReady ?? this.cvReady,
      githubReady:
      githubReady ?? this.githubReady,
      projectsCompleted:
      projectsCompleted ??
          this.projectsCompleted,
      mockInterviewDone:
      mockInterviewDone ??
          this.mockInterviewDone,
      jobsApplied:
      jobsApplied ?? this.jobsApplied,
      updatedAt:
      updatedAt ?? this.updatedAt,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}