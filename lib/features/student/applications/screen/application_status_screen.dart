import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../models/application_model.dart';
import '../../../../services/application_service.dart';
import '../widgets/application_status.dart';

class ApplicationStatusScreen extends StatefulWidget {
  const ApplicationStatusScreen({
    super.key,
  });

  @override
  State<ApplicationStatusScreen> createState() =>
      _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState
    extends State<ApplicationStatusScreen> {
  late Future<ApplicationModel?> _applicationFuture;

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  void _loadApplication() {
    _applicationFuture =
        ApplicationService.instance.getMyApplication();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadApplication();
    });

    await _applicationFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Application',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FutureBuilder<ApplicationModel?>(
        future: _applicationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorView(
              onRetry: _refresh,
            );
          }

          final application = snapshot.data;

          if (application == null) {
            return const _NoApplicationView();
          }

          final status =
          application.status.toLowerCase();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                30,
              ),
              children: [
                FadeSlideAnimation(
                  child: _ApplicationHeader(
                    application: application,
                  ),
                ),

                const SizedBox(height: 20),

                FadeSlideAnimation(
                  delay: const Duration(
                    milliseconds: 100,
                  ),
                  child: _CourseInformation(
                    application: application,
                  ),
                ),

                const SizedBox(height: 20),

                FadeSlideAnimation(
                  delay: const Duration(
                    milliseconds: 180,
                  ),
                  child: _StatusTimeline(
                    status: application.status,
                  ),
                ),

                if (status == 'waiting_list') ...[
                  const SizedBox(height: 20),
                  FadeSlideAnimation(
                    delay: const Duration(
                      milliseconds: 220,
                    ),
                    child: const _WaitingListCard(),
                  ),
                ],

                if (status == 'rejected' &&
                    application.rejectionReason !=
                        null &&
                    application.rejectionReason!
                        .trim()
                        .isNotEmpty) ...[
                  const SizedBox(height: 20),
                  FadeSlideAnimation(
                    delay: const Duration(
                      milliseconds: 250,
                    ),
                    child: _RejectionCard(
                      reason:
                      application.rejectionReason!,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                FadeSlideAnimation(
                  delay: const Duration(
                    milliseconds: 300,
                  ),
                  child: _ApplicationDetails(
                    application: application,
                  ),
                ),

                const SizedBox(height: 20),

                const FadeSlideAnimation(
                  delay: Duration(
                    milliseconds: 350,
                  ),
                  child: _InfoBanner(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// APPLICATION HEADER
// ============================================================

class _ApplicationHeader extends StatelessWidget {
  final ApplicationModel application;

  const _ApplicationHeader({
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final color = ApplicationStatusHelper.color(
      application.status,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXLarge,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.14,
                  ),
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: Icon(
                  ApplicationStatusHelper.icon(
                    application.status,
                  ),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Application Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'Current Status',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 7),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.18,
              ),
              borderRadius:
              BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white24,
              ),
            ),
            child: Text(
              ApplicationStatusHelper.label(
                application.status,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'ID: ${application.id}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COURSE INFORMATION
// ============================================================

class _CourseInformation extends StatelessWidget {
  final ApplicationModel application;

  const _CourseInformation({
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Course Information',
      icon: Icons.school_outlined,
      child: Column(
        children: [
          _InfoItem(
            icon: Icons.school_rounded,
            title: 'Course',
            value: application.courseName,
          ),

          const Divider(height: 22),

          _InfoItem(
            icon: Icons.location_on_outlined,
            title: 'Campus',
            value: application.campusName,
          ),

          const Divider(height: 22),

          _InfoItem(
            icon: Icons.person_outline_rounded,
            title: 'Applicant',
            value: application.fullName,
          ),

          const Divider(height: 22),

          _InfoItem(
            icon: Icons.location_city_outlined,
            title: 'City',
            value: application.city,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STATUS TIMELINE
// ============================================================

class _StatusTimeline extends StatelessWidget {
  final String status;

  const _StatusTimeline({
    required this.status,
  });

  int get _currentStep {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 0;

      case 'under_review':
        return 1;

      case 'interview_test':
        return 2;

      case 'accepted':
        return 3;

      case 'waiting_list':
        return 2;

      case 'rejected':
        return 2;

      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _currentStep;

    const steps = [
      _TimelineStepData(
        title: 'Submitted',
        subtitle: 'Application received',
        icon: Icons.send_rounded,
      ),
      _TimelineStepData(
        title: 'Under Review',
        subtitle: 'Application is being reviewed',
        icon: Icons.rate_review_outlined,
      ),
      _TimelineStepData(
        title: 'Interview / Test',
        subtitle: 'Next admission stage',
        icon: Icons.assignment_turned_in_outlined,
      ),
      _TimelineStepData(
        title: 'Accepted',
        subtitle: 'Welcome to Bano Qabil',
        icon: Icons.check_circle_outline_rounded,
      ),
    ];

    return _SectionCard(
      title: 'Application Journey',
      icon: Icons.timeline_rounded,
      child: Column(
        children: List.generate(
          steps.length,
              (index) {
            final step = steps[index];

            final completed =
                index <= currentStep;

            final isLast =
                index == steps.length - 1;

            return FadeSlideAnimation(
              delay: Duration(
                milliseconds:
                100 + (index * 100),
              ),
              beginOffset:
              const Offset(0.06, 0),
              child: _TimelineItem(
                step: step,
                completed: completed,
                isLast: isLast,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// TIMELINE ITEM
// ============================================================

class _TimelineItem extends StatelessWidget {
  final _TimelineStepData step;
  final bool completed;
  final bool isLast;

  const _TimelineItem({
    required this.step,
    required this.completed,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = completed
        ? AppColors.success
        : AppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration:
                const Duration(
                  milliseconds: 300,
                ),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed
                      ? AppColors.success
                      : AppColors.background,
                  border: Border.all(
                    color: color,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  completed
                      ? Icons.check_rounded
                      : step.icon,
                  size: 20,
                  color: completed
                      ? Colors.white
                      : AppColors.textLight,
                ),
              ),

              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin:
                    const EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    color: completed
                        ? AppColors.success
                        : AppColors.border,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.only(
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w700,
                      color: completed
                          ? AppColors.textPrimary
                          : AppColors.textLight,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    step.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: completed
                          ? AppColors.textSecondary
                          : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WAITING LIST
// ============================================================

class _WaitingListCard extends StatelessWidget {
  const _WaitingListCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent,
        ),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            color: AppColors.warning,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              'You are currently on the waiting list. You will be notified if a seat becomes available.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REJECTION CARD
// ============================================================

class _RejectionCard extends StatelessWidget {
  final String reason;

  const _RejectionCard({
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(
          alpha: 0.07,
        ),
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.error,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Application Feedback',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// APPLICATION DETAILS
// ============================================================

class _ApplicationDetails extends StatelessWidget {
  final ApplicationModel application;

  const _ApplicationDetails({
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final date = application.createdAt == null
        ? 'Not available'
        : DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(
      application.createdAt!,
    );

    return _SectionCard(
      title: 'Application Details',
      icon: Icons.description_outlined,
      child: Column(
        children: [
          _InfoItem(
            icon: Icons.fingerprint_rounded,
            title: 'Application ID',
            value: application.id,
          ),

          const Divider(height: 22),

          _InfoItem(
            icon:
            Icons.calendar_today_outlined,
            title: 'Submitted',
            value: date,
          ),

          const Divider(height: 22),

          _InfoItem(
            icon: Icons.school_outlined,
            title: 'Education',
            value: application.education,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION CARD
// ============================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}

// ============================================================
// INFO ITEM
// ============================================================

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: AppColors.textSecondary,
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color:
                  AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value.isEmpty
                    ? 'Not available'
                    : value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// INFO BANNER
// ============================================================

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: AppColors.accent,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              'Application updates will appear here. Keep your notifications enabled so you do not miss important admission updates.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TIMELINE DATA
// ============================================================

class _TimelineStepData {
  final String title;
  final String subtitle;
  final IconData icon;

  const _TimelineStepData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

// ============================================================
// NO APPLICATION
// ============================================================

class _NoApplicationView extends StatelessWidget {
  const _NoApplicationView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 38,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No Application Found',
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'You have not submitted an application yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR VIEW
// ============================================================

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: AppColors.textLight,
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to load application',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}