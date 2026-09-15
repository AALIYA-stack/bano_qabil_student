import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../models/application_model.dart';
import '../../../../services/application_service.dart';


class MyApplicationScreen extends StatefulWidget {
  const MyApplicationScreen({super.key});

  @override
  State<MyApplicationScreen> createState() =>
      _MyApplicationScreenState();
}

class _MyApplicationScreenState
    extends State<MyApplicationScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  ApplicationModel? _application;

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  Future<void> _loadApplication() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final application =
      await ApplicationService.instance.getMyApplication();

      if (!mounted) return;

      setState(() {
        _application = application;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      case 'under_review':
        return Colors.orange;

      case 'interview_test':
        return Colors.blue;

      case 'waiting_list':
        return Colors.deepPurple;

      default:
        return AppColors.primary;
    }
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'Submitted';

      case 'under_review':
        return 'Under Review';

      case 'interview_test':
        return 'Interview / Test';

      case 'accepted':
        return 'Accepted';

      case 'rejected':
        return 'Rejected';

      case 'waiting_list':
        return 'Waiting List';

      default:
        return status;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle;

      case 'rejected':
        return Icons.cancel;

      case 'under_review':
        return Icons.hourglass_top;

      case 'interview_test':
        return Icons.assignment;

      case 'waiting_list':
        return Icons.schedule;

      default:
        return Icons.send;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not available';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'My Application',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadApplication,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load application',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadApplication,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_application == null) {
      return _buildNoApplication();
    }

    return RefreshIndicator(
      onRefresh: _loadApplication,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildApplicationDetails(),
          const SizedBox(height: 16),
          _buildCourseDetails(),
          const SizedBox(height: 16),
          _buildWhyJoin(),
          if (_application!.isRejected &&
              (_application!.rejectionReason?.isNotEmpty ?? false))
            ...[
              const SizedBox(height: 16),
              _buildRejectionCard(),
            ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNoApplication() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Application Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have not submitted a course application yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.school_outlined),
              label: const Text('Explore Courses'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final application = _application!;
    final color = _statusColor(application.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statusIcon(application.status),
              size: 42,
              color: color,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Application Status',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _statusText(application.status),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _statusMessage(application.status),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _statusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'Your application has been submitted successfully.';

      case 'under_review':
        return 'Your application is currently being reviewed.';

      case 'interview_test':
        return 'You may be required to complete an interview or test.';

      case 'accepted':
        return 'Congratulations! Your application has been accepted.';

      case 'rejected':
        return 'Unfortunately, your application was not accepted.';

      case 'waiting_list':
        return 'You are currently on the waiting list.';

      default:
        return 'Your application status has been updated.';
    }
  }

  Widget _buildApplicationDetails() {
    final application = _application!;

    return _sectionCard(
      title: 'Application Details',
      icon: Icons.person_outline,
      children: [
        _detailRow(
          'Full Name',
          application.fullName,
          Icons.person,
        ),
        _detailRow(
          'CNIC',
          application.cnic,
          Icons.badge_outlined,
        ),
        _detailRow(
          'Education',
          application.education,
          Icons.school_outlined,
        ),
        _detailRow(
          'City',
          application.city,
          Icons.location_city_outlined,
        ),
        _detailRow(
          'Application Date',
          _formatDate(application.createdAt),
          Icons.calendar_today_outlined,
        ),
      ],
    );
  }

  Widget _buildCourseDetails() {
    final application = _application!;

    return _sectionCard(
      title: 'Course Details',
      icon: Icons.menu_book_outlined,
      children: [
        _detailRow(
          'Course',
          application.courseName,
          Icons.code,
        ),
        _detailRow(
          'Campus',
          application.campusName,
          Icons.location_on_outlined,
        ),
        _detailRow(
          'Batch',
          application.batchId,
          Icons.groups_outlined,
        ),
      ],
    );
  }

  Widget _buildWhyJoin() {
    final application = _application!;

    return _sectionCard(
      title: 'Why I Want to Join',
      icon: Icons.lightbulb_outline,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            application.whyJoin.isEmpty
                ? 'No reason provided.'
                : application.whyJoin,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRejectionCard() {
    final application = _application!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.red,
              ),
              SizedBox(width: 8),
              Text(
                'Rejection Reason',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            application.rejectionReason!,
            style: const TextStyle(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(
      String label,
      String value,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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