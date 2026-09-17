/// Aggregated numbers for the coordinator's report screen.
///
/// - [applicationsThisMonth]: applications created in the current
///   calendar month (any status).
/// - [acceptedStudents]: total applications with status 'accepted'.
/// - [averageAttendancePercent]: (present + late) / total attendance
///   records, across every batch, expressed as a percentage.
/// - [assignmentsPendingReview]: submissions that have been submitted
///   by students but not yet marked by an instructor (marks == null).
class CoordinatorReportModel {
  final int applicationsThisMonth;
  final int acceptedStudents;
  final double averageAttendancePercent;
  final int assignmentsPendingReview;

  const CoordinatorReportModel({
    required this.applicationsThisMonth,
    required this.acceptedStudents,
    required this.averageAttendancePercent,
    required this.assignmentsPendingReview,
  });
}

/// Minimal option used when the coordinator picks an instructor
/// to assign to a batch. Backed by `users` where role == 'instructor'.
class InstructorOption {
  final String uid;
  final String name;
  final String email;

  const InstructorOption({
    required this.uid,
    required this.name,
    required this.email,
  });
}