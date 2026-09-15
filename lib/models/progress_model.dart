import 'career_progress_model.dart';

class ProgressModel {
  final int completedModules;
  final int totalModules;
  final double attendancePercentage;
  final double assignmentAverage;
  final CareerProgressModel careerProgress;

  const ProgressModel({
    required this.completedModules,
    required this.totalModules,
    required this.attendancePercentage,
    required this.assignmentAverage,
    required this.careerProgress,
  });

  // ============================================================
  // MODULE PERCENTAGE
  // ============================================================

  double get modulePercentage {
    if (totalModules <= 0) {
      return 0;
    }

    return (completedModules / totalModules) * 100;
  }

  // ============================================================
  // CAREER READINESS
  // ============================================================

  double get careerReadinessPercentage {
    return careerProgress.readinessPercentage;
  }

  bool get isJobReady {
    return careerProgress.isJobReady;
  }

  // ============================================================
  // OVERALL PERCENTAGE
  // ============================================================

  double get overallPercentage {
    return (
        modulePercentage +
            attendancePercentage +
            assignmentAverage
    ) /
        3;
  }

  // ============================================================
  // OVERALL LABEL
  // ============================================================

  String get overallLabel {
    if (overallPercentage >= 80) {
      return 'Excellent';
    }

    if (overallPercentage >= 60) {
      return 'Good';
    }

    if (overallPercentage >= 40) {
      return 'Needs Improvement';
    }

    return 'Getting Started';
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  ProgressModel copyWith({
    int? completedModules,
    int? totalModules,
    double? attendancePercentage,
    double? assignmentAverage,
    CareerProgressModel? careerProgress,
  }) {
    return ProgressModel(
      completedModules:
      completedModules ??
          this.completedModules,

      totalModules:
      totalModules ??
          this.totalModules,

      attendancePercentage:
      attendancePercentage ??
          this.attendancePercentage,

      assignmentAverage:
      assignmentAverage ??
          this.assignmentAverage,

      careerProgress:
      careerProgress ??
          this.careerProgress,
    );
  }
}