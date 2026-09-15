import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../models/application_model.dart';
import '../../../../models/progress_model.dart';
import '../../../../services/application_service.dart';
import '../../../../services/career_service.dart';
import '../../../../services/progress_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() =>
      _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isLoading = true;

  ProgressModel? _progress;
  ApplicationModel? _application;

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  // ============================================================
  // LOAD PROGRESS
  // ============================================================

  Future<void> _loadProgress() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // --------------------------------------------------------
      // STEP 1: CHECK LOGIN
      // --------------------------------------------------------

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(
          'No logged-in student found.',
        );
      }

      debugPrint('');
      debugPrint('==========================================');
      debugPrint('       PROGRESS SCREEN START');
      debugPrint('==========================================');
      debugPrint('Current UID: ${user.uid}');

      // --------------------------------------------------------
      // STEP 2: GET APPLICATION
      // --------------------------------------------------------

      debugPrint('');
      debugPrint('Getting student application...');

      final application =
      await ApplicationService.instance
          .getMyApplication();

      if (application == null) {
        throw Exception(
          'No application found for this student.',
        );
      }

      debugPrint(
        'Application found: ${application.id}',
      );

      debugPrint(
        'Application batchId: ${application.batchId}',
      );

      debugPrint(
        'Application courseId: ${application.courseId}',
      );

      // --------------------------------------------------------
      // CHECK BATCH ID
      // --------------------------------------------------------

      final String batchId =
      application.batchId.trim();

      if (batchId.isEmpty) {
        throw Exception(
          'Batch ID is missing from your application.',
        );
      }

      // --------------------------------------------------------
      // CHECK COURSE ID
      // --------------------------------------------------------

      final String courseId =
      application.courseId.trim();

      if (courseId.isEmpty) {
        throw Exception(
          'Course ID is missing from your application.',
        );
      }

      // --------------------------------------------------------
      // STEP 3: CAREER PROGRESS
      // --------------------------------------------------------

      debugPrint('');
      debugPrint('Checking career progress...');

      try {
        final career =
        await CareerService.instance
            .getMyCareerProgress();

        if (career == null) {
          debugPrint(
            'Career progress not found. Creating default...',
          );

          await CareerService.instance
              .updateCareerProgress(
            cvReady: false,
            githubReady: false,
            projectsCompleted: 0,
            mockInterviewDone: false,
            jobsApplied: 0,
          );
        }
      } catch (e) {
        debugPrint(
          'Career progress warning: $e',
        );
      }

      // --------------------------------------------------------
      // STEP 4: MAIN PROGRESS
      // --------------------------------------------------------

      debugPrint('');
      debugPrint('Loading main progress...');

      final ProgressModel progress =
      await ProgressService.instance.getMyProgress(
        batchId: batchId,
        courseId: courseId,
      );

      debugPrint('');
      debugPrint('Progress loaded successfully.');

      if (!mounted) return;

      setState(() {
        _application = application;
        _progress = progress;
        _isLoading = false;
      });

      debugPrint('==========================================');
      debugPrint('       PROGRESS SCREEN SUCCESS');
      debugPrint('==========================================');
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==========================================');
      debugPrint('       PROGRESS SCREEN ERROR');
      debugPrint('==========================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==========================================');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    await _loadProgress();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return _ErrorView(
        message: _errorMessage,
        onRetry: _refresh,
      );
    }

    if (_progress == null) {
      return _ErrorView(
        message:
        'Progress data could not be loaded.',
        onRetry: _refresh,
      );
    }

    return _ProgressContent(
      progress: _progress!,
      application: _application,
      onRefresh: _refresh,
    );
  }
}

// ================================================================
// PROGRESS CONTENT
// ================================================================

class _ProgressContent extends StatelessWidget {
  final ProgressModel progress;
  final ApplicationModel? application;
  final Future<void> Function() onRefresh;

  const _ProgressContent({
    required this.progress,
    required this.application,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // ------------------------------------------------------------
    // MODULE PERCENTAGE
    // ------------------------------------------------------------

    final double modulePercentage =
    progress.totalModules == 0
        ? 0.0
        : ((progress.completedModules /
        progress.totalModules) *
        100)
        .toDouble();

    // ------------------------------------------------------------
    // ATTENDANCE
    // ------------------------------------------------------------

    final double attendance =
    progress.attendancePercentage
        .clamp(0, 100)
        .toDouble();

    // ------------------------------------------------------------
    // ASSIGNMENT
    // ------------------------------------------------------------

    final double assignment =
    progress.assignmentAverage
        .clamp(0, 100)
        .toDouble();

    // ------------------------------------------------------------
    // CAREER
    // ------------------------------------------------------------

    final career = progress.careerProgress;

    final List<bool> careerItems = [
      career.cvReady,
      career.githubReady,
      career.projectsCompleted >= 3,
      career.mockInterviewDone,
      career.jobsApplied > 0,
    ];

    final int completedCareerItems =
        careerItems
            .where((item) => item)
            .length;

    // ------------------------------------------------------------
    // CAREER PERCENTAGE
    // ------------------------------------------------------------

    final double careerPercentage =
    careerItems.isEmpty
        ? 0.0
        : ((completedCareerItems /
        careerItems.length) *
        100)
        .toDouble();

    // ------------------------------------------------------------
    // OVERALL PERCENTAGE
    // ------------------------------------------------------------

    final double overall =
    ((modulePercentage +
        attendance +
        assignment +
        careerPercentage) /
        4)
        .clamp(0, 100)
        .toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Progress',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --------------------------------------------------
            // COURSE
            // --------------------------------------------------

            if (application != null)
              _CourseHeader(
                courseName:
                application!.courseName,
                batchId:
                application!.batchId,
              ),

            const SizedBox(height: 16),

            // --------------------------------------------------
            // OVERALL
            // --------------------------------------------------

            _OverallCard(
              percentage: overall,
            ),

            const SizedBox(height: 16),

            // --------------------------------------------------
            // MODULE PROGRESS
            // --------------------------------------------------

            _ProgressCard(
              title: 'Course Modules',
              icon:
              Icons.menu_book_outlined,
              value:
              '${progress.completedModules} / ${progress.totalModules}',
              percentage:
              modulePercentage,
              subtitle:
              'Modules completed',
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // ATTENDANCE
            // --------------------------------------------------

            _ProgressCard(
              title: 'Attendance',
              icon:
              Icons.calendar_month_outlined,
              value:
              '${attendance.toStringAsFixed(0)}%',
              percentage:
              attendance,
              subtitle:
              'Class attendance',
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // ASSIGNMENTS
            // --------------------------------------------------

            _ProgressCard(
              title: 'Assignments',
              icon:
              Icons.assignment_outlined,
              value:
              '${assignment.toStringAsFixed(0)}%',
              percentage:
              assignment,
              subtitle:
              'Average assignment marks',
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // CAREER
            // --------------------------------------------------

            _CareerCard(
              career: career,
              percentage:
              careerPercentage,
            ),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // STATUS
            // --------------------------------------------------

            _StatusCard(
              percentage: overall,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// COURSE HEADER
// ================================================================

class _CourseHeader extends StatelessWidget {
  final String courseName;
  final String batchId;

  const _CourseHeader({
    required this.courseName,
    required this.batchId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration:
              BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
                borderRadius:
                BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.school_outlined,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    courseName.isEmpty
                        ? 'My Course'
                        : courseName,
                    style:
                    const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Batch: $batchId',
                    style: TextStyle(
                      color:
                      Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// OVERALL CARD
// ================================================================

class _OverallCard
    extends StatelessWidget {
  final double percentage;

  const _OverallCard({
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(22),
        child: Column(
          children: [
            const Text(
              'Overall Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 130,
              width: 130,
              child: Stack(
                alignment:
                Alignment.center,
                children: [
                  SizedBox(
                    height: 130,
                    width: 130,
                    child:
                    CircularProgressIndicator(
                      value:
                      percentage / 100,
                      strokeWidth: 12,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style:
                    const TextStyle(
                      fontSize: 25,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getStatus(
                percentage,
              ),
              style: TextStyle(
                fontWeight:
                FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatus(
      double value,
      ) {
    if (value >= 80) {
      return 'Excellent progress';
    }

    if (value >= 60) {
      return 'Good progress';
    }

    if (value >= 40) {
      return 'Keep improving';
    }

    return 'Just getting started';
  }
}

// ================================================================
// PROGRESS CARD
// ================================================================

class _ProgressCard
    extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final double percentage;
  final String subtitle;

  const _ProgressCard({
    required this.title,
    required this.icon,
    required this.value,
    required this.percentage,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final double safePercentage =
    percentage
        .clamp(0, 100)
        .toDouble();

    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style:
                    const TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  value,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value:
              safePercentage / 100,
              minHeight: 8,
              borderRadius:
              BorderRadius.circular(
                20,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment:
              Alignment.centerLeft,
              child: Text(
                subtitle,
                style: TextStyle(
                  color:
                  Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// CAREER CARD
// ================================================================

class _CareerCard
    extends StatelessWidget {
  final dynamic career;
  final double percentage;

  const _CareerCard({
    required this.career,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.work_outline,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Career Readiness',
                    style:
                    TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value:
              percentage / 100,
              minHeight: 8,
              borderRadius:
              BorderRadius.circular(
                20,
              ),
            ),
            const SizedBox(height: 18),
            _CareerRow(
              title: 'CV Ready',
              completed:
              career.cvReady,
            ),
            _CareerRow(
              title: 'GitHub Ready',
              completed:
              career.githubReady,
            ),
            _CareerRow(
              title:
              'Projects Completed',
              completed:
              career.projectsCompleted >=
                  3,
            ),
            _CareerRow(
              title:
              'Mock Interview',
              completed:
              career.mockInterviewDone,
            ),
            _CareerRow(
              title:
              'Jobs Applied',
              completed:
              career.jobsApplied > 0,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// CAREER ROW
// ================================================================

class _CareerRow
    extends StatelessWidget {
  final String title;
  final bool completed;

  const _CareerRow({
    required this.title,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.check_circle
                : Icons
                .radio_button_unchecked,
            size: 20,
            color: completed
                ? Colors.green
                : Colors.grey,
          ),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
    );
  }
}

// ================================================================
// STATUS CARD
// ================================================================

class _StatusCard
    extends StatelessWidget {
  final double percentage;

  const _StatusCard({
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String message;

    if (percentage >= 80) {
      title = 'Excellent';
      message =
      'You are making excellent progress. Keep it up!';
    } else if (percentage >= 60) {
      title = 'Good';
      message =
      'Your progress is going well. Keep improving!';
    } else if (percentage >= 40) {
      title = 'Needs Improvement';
      message =
      'Focus on attendance, assignments and modules.';
    } else {
      title = 'Getting Started';
      message =
      'Complete your classes and assignments to improve your progress.';
    }

    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.insights_outlined,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                    const TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ERROR VIEW
// ================================================================

class _ErrorView
    extends StatelessWidget {
  final String message;
  final Future<void> Function()
  onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text('My Progress'),
      ),
      body: Center(
        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color:
                Colors.red.shade400,
              ),
              const SizedBox(height: 18),
              const Text(
                'Unable to load progress',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color:
                  Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh,
                ),
                label:
                const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}