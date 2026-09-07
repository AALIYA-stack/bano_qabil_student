class AppConstants {
  AppConstants._();

  // ============================================================
  // APP
  // ============================================================

  static const String appName = 'Bano Qabil';

  static const String appTagline =
      'Learn • Grow • Become Job Ready';

  static const String organizationName =
      'Bano Qabil';

  // ============================================================
  // ROLES
  // ============================================================

  static const String studentRole = 'student';

  static const String instructorRole = 'instructor';

  static const String coordinatorRole = 'coordinator';

  // ============================================================
  // VALIDATION
  // ============================================================

  static const int minPasswordLength = 6;

  static const int maxPasswordLength = 128;

  static const int minNameLength = 2;

  static const int maxNameLength = 60;

  static const int maxWhyJoinLength = 500;

  // ============================================================
  // FILE LIMITS
  // ============================================================

  static const int maxProfileImageSizeMb = 5;

  static const int maxSubmissionFileSizeMb = 10;

  // ============================================================
  // PAGINATION
  // ============================================================

  static const int defaultPageSize = 20;

  // ============================================================
  // DATE / TIME
  // ============================================================

  static const String dateFormat = 'dd MMM yyyy';

  static const String timeFormat = 'hh:mm a';

  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';

  // ============================================================
  // CAREER
  // ============================================================

  static const int requiredProjectsForJobReady = 3;

  static const double jobReadyThreshold = 80.0;

  // ============================================================
  // PROGRESS WEIGHTS
  // ============================================================

  static const double moduleProgressWeight = 0.40;

  static const double assignmentProgressWeight = 0.30;

  static const double attendanceProgressWeight = 0.30;
}