import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../models/coordinator_report_model.dart';
import '../../../../services/coordinator_service.dart';

/// Coordinator's monthly report: applications this month, accepted
/// students, average attendance, and assignments pending review.
class CoordinatorReportScreen extends StatefulWidget {
  const CoordinatorReportScreen({super.key});

  @override
  State<CoordinatorReportScreen> createState() =>
      _CoordinatorReportScreenState();
}

class _CoordinatorReportScreenState
    extends State<CoordinatorReportScreen> {
  late Future<CoordinatorReportModel> _reportFuture;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    _reportFuture = CoordinatorService.instance.getMonthlyReport();
  }

  Future<void> _refresh() async {
    setState(_loadReport);
    await _reportFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Coordinator Report'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<CoordinatorReportModel>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(fullScreen: true);
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final report = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              children: [
                FadeSlideAnimation(
                  child: _ReportCard(
                    icon: Icons.description_outlined,
                    title: 'Applications This Month',
                    value: '${report.applicationsThisMonth}',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                FadeSlideAnimation(
                  delay: const Duration(milliseconds: 60),
                  child: _ReportCard(
                    icon: Icons.verified_outlined,
                    title: 'Accepted Students',
                    value: '${report.acceptedStudents}',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 12),
                FadeSlideAnimation(
                  delay: const Duration(milliseconds: 120),
                  child: _ReportCard(
                    icon: Icons.calendar_month_outlined,
                    title: 'Average Attendance',
                    value:
                        '${report.averageAttendancePercent.toStringAsFixed(0)}%',
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 12),
                FadeSlideAnimation(
                  delay: const Duration(milliseconds: 180),
                  child: _ReportCard(
                    icon: Icons.pending_actions_rounded,
                    title: 'Assignments Pending Review',
                    value: '${report.assignmentsPendingReview}',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
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