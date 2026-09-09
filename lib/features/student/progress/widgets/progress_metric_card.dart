import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/animations/animated_counter.dart';

class ProgressMetricCard extends StatelessWidget {
final String title;
final double percentage;
final IconData icon;
final Color iconColor;

const ProgressMetricCard({
super.key,
required this.title,
required this.percentage,
required this.icon,
required this.iconColor,
});

@override
Widget build(BuildContext context) {
return Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: AppColors.border,
),
boxShadow: const [
BoxShadow(
color: AppColors.shadow,
blurRadius: 12,
offset: Offset(0, 4),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 42,
height: 42,
decoration: BoxDecoration(
color: iconColor.withOpacity(0.10),
borderRadius:
BorderRadius.circular(12),
),
child: Icon(
icon,
color: iconColor,
size: 22,
),
),

const SizedBox(height: 14),

AnimatedCounter(
value: percentage,
suffix: '%',
decimalPlaces: 0,
style: const TextStyle(
fontSize: 24,
fontWeight: FontWeight.w700,
color: AppColors.textPrimary,
),
),

const SizedBox(height: 4),

Text(
title,
style: const TextStyle(
fontSize: 13,
color: AppColors.textSecondary,
),
),
],
),
);
}
}

