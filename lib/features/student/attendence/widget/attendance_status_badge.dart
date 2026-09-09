import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class AttendanceStatusBadge extends StatelessWidget {
  final String status;

  const AttendanceStatusBadge({
    super.key,
    required this.status,
  });

  Color get _color {
    switch (status.toLowerCase()) {
      case 'present':
        return AppColors.success;

      case 'absent':
        return AppColors.error;

      case 'leave':
        return AppColors.warning;

      case 'late':
        return AppColors.info;

      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle_outline_rounded;

      case 'absent':
        return Icons.cancel_outlined;

      case 'leave':
        return Icons.event_busy_outlined;

      case 'late':
        return Icons.schedule_rounded;

      default:
        return Icons.help_outline_rounded;
    }
  }

  String get _label {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Present';

      case 'absent':
        return 'Absent';

      case 'leave':
        return 'Leave';

      case 'late':
        return 'Late';

      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: 15,
            color: _color,
          ),
          const SizedBox(width: 5),
          Text(
            _label,
            style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}