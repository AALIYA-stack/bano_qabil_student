import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class ApplicationStatusHelper {
  ApplicationStatusHelper._();

  static String label(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'Submitted';

      case 'under_review':
        return 'Under Review';

      case 'interview_test':
        return 'Interview / Test';

      case 'accepted':
        return 'Accepted';

      case 'waiting_list':
        return 'Waiting List';

      case 'rejected':
        return 'Rejected';

      default:
        return 'Unknown';
    }
  }

  static Color color(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return AppColors.info;

      case 'under_review':
        return AppColors.warning;

      case 'interview_test':
        return AppColors.primary;

      case 'accepted':
        return AppColors.success;

      case 'waiting_list':
        return AppColors.warning;

      case 'rejected':
        return AppColors.error;

      default:
        return AppColors.textSecondary;
    }
  }

  static IconData icon(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Icons.send_rounded;

      case 'under_review':
        return Icons.rate_review_outlined;

      case 'interview_test':
        return Icons.assignment_turned_in_outlined;

      case 'accepted':
        return Icons.check_circle_outline_rounded;

      case 'waiting_list':
        return Icons.hourglass_empty_rounded;

      case 'rejected':
        return Icons.cancel_outlined;

      default:
        return Icons.info_outline_rounded;
    }
  }
}