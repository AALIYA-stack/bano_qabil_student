import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../models/application_model.dart';
import '../../../../services/coordinator_service.dart';
import '../../../student/applications/widgets/application_status.dart';

/// Coordinator's applications inbox: filter by status, open an
/// application, and accept / waitlist / reject it (with a reason for
/// the latter two). Uses ApplicationStatusHelper for consistent
/// colors/icons/labels with the student-facing screens.
class ApplicationsInboxScreen extends StatefulWidget {
  const ApplicationsInboxScreen({super.key});

  @override
  State<ApplicationsInboxScreen> createState() =>
      _ApplicationsInboxScreenState();
}

class _ApplicationsInboxScreenState
    extends State<ApplicationsInboxScreen> {
  String _filter = 'submitted';

  final List<_FilterOption> _filters = const [
    _FilterOption('submitted', 'New'),
    _FilterOption('under_review', 'Under Review'),
    _FilterOption('interview_test', 'Interview / Test'),
    _FilterOption('accepted', 'Accepted'),
    _FilterOption('waiting_list', 'Waiting List'),
    _FilterOption('rejected', 'Rejected'),
    _FilterOption('all', 'All'),
  ];

  Future<void> _decide(
    ApplicationModel application,
    String newStatus,
  ) async {
    String? reason;

    if (newStatus == 'rejected' || newStatus == 'waiting_list') {
      reason = await _askForReason(newStatus);

      // User cancelled the dialog.
      if (reason == null) return;
    }

    try {
      await CoordinatorService.instance.decideApplication(
        applicationId: application.id,
        newStatus: newStatus,
        reason: reason,
      );

      if (!mounted) return;

      AppSnackbar.success(
        context,
        '${application.fullName} moved to '
        '${ApplicationStatusHelper.label(newStatus)}.',
      );
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<String?> _askForReason(String status) async {
    final controller = TextEditingController();
    final isReject = status == 'rejected';

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isReject
                ? 'Reject application'
                : 'Move to waiting list',
          ),
          content: TextField(
            controller: controller,
            maxLines: 3,
            autofocus: true,
            decoration: InputDecoration(
              hintText: isReject
                  ? 'Reason for rejection (shown to the student)'
                  : 'Note for the student (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (isReject && controller.text.trim().isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext, controller.text.trim());
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Applications')),
      body: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: 6,
              ),
              itemCount: _filters.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final option = _filters[index];

                return ChoiceChip(
                  label: Text(option.label),
                  selected: _filter == option.value,
                  onSelected: (_) {
                    setState(() {
                      _filter = option.value;
                    });
                  },
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ApplicationModel>>(
              stream: CoordinatorService.instance
                  .applicationsStream(statusFilter: _filter),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const LoadingWidget(fullScreen: true);
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Unable to load applications.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final applications = snapshot.data ?? [];

                if (applications.isEmpty) {
                  return const EmptyState(
                    title: 'No applications here',
                    message:
                        'Applications matching this filter will appear here.',
                    icon: Icons.inbox_outlined,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(
                    AppDimensions.paddingMedium,
                  ),
                  itemCount: applications.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final application = applications[index];

                    return FadeSlideAnimation(
                      delay: Duration(milliseconds: 40 * index),
                      child: _ApplicationCard(
                        application: application,
                        onDecide: (status) =>
                            _decide(application, status),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterOption {
  final String value;
  final String label;

  const _FilterOption(this.value, this.label);
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final void Function(String status) onDecide;

  const _ApplicationCard({
    required this.application,
    required this.onDecide,
  });

  @override
  Widget build(BuildContext context) {
    final color = ApplicationStatusHelper.color(application.status);
    final date = application.createdAt == null
        ? 'Date unavailable'
        : DateFormat('dd MMM yyyy').format(application.createdAt!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  ApplicationStatusHelper.icon(application.status),
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.fullName,
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${application.courseName} • ${application.campusName}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ApplicationStatusHelper.label(application.status),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.school_outlined,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(application.education, style: AppTextStyles.bodySmall),
              const SizedBox(width: 14),
              Icon(
                Icons.location_city_outlined,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(application.city, style: AppTextStyles.bodySmall),
              const Spacer(),
              Text(date, style: AppTextStyles.bodySmall),
            ],
          ),
          if (application.whyJoin.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                application.whyJoin,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _DecisionRow(
            status: application.status,
            onDecide: onDecide,
          ),
        ],
      ),
    );
  }
}

class _DecisionRow extends StatelessWidget {
  final String status;
  final void Function(String status) onDecide;

  const _DecisionRow({
    required this.status,
    required this.onDecide,
  });

  @override
  Widget build(BuildContext context) {
    // Final states offer no further action.
    if (status == 'accepted' || status == 'rejected') {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (status == 'submitted')
          OutlinedButton(
            onPressed: () => onDecide('under_review'),
            child: const Text('Start Review'),
          ),
        if (status == 'submitted' || status == 'under_review')
          OutlinedButton(
            onPressed: () => onDecide('interview_test'),
            child: const Text('Interview / Test'),
          ),
        FilledButton(
          onPressed: () => onDecide('accepted'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
          ),
          child: const Text('Accept'),
        ),
        OutlinedButton(
          onPressed: () => onDecide('waiting_list'),
          child: const Text('Waitlist'),
        ),
        OutlinedButton(
          onPressed: () => onDecide('rejected'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
          ),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}