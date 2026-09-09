import 'package:flutter/material.dart';

import '../../../../../../../app/theme/app_colors.dart';

class UpcomingClassCard extends StatelessWidget {
  final String day;
  final String time;
  final String room;
  final String instructor;

  const UpcomingClassCard({
    super.key,
    required this.day,
    required this.time,
    required this.room,
    required this.instructor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Upcoming Class',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _Info(
                icon: Icons.calendar_today_outlined,
                text: day,
              ),
              const SizedBox(width: 18),
              _Info(
                icon: Icons.schedule_outlined,
                text: time,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _Info(
                icon: Icons.meeting_room_outlined,
                text: room,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _Info(
                  icon: Icons.person_outline_rounded,
                  text: instructor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Info({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}