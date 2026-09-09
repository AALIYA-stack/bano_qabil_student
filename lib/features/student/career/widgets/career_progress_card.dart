import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../models/career_progress_model.dart';

class CareerProgressCard extends StatelessWidget {
  final CareerProgressModel progress;

  const CareerProgressCard({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
        progress.readinessPercentage;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius:
        BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Text(
            'Career Readiness',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 18),

          TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0,
              end: percentage / 100,
            ),
            duration: const Duration(
              milliseconds: 1000,
            ),
            curve: Curves.easeOutCubic,
            builder: (
                context,
                value,
                child,
                ) {
              return SizedBox(
                height: 130,
                width: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 130,
                      width: 130,
                      child:
                      CircularProgressIndicator(
                        value: value,
                        strokeWidth: 11,
                        backgroundColor:
                        Colors.white24,
                        valueColor:
                        const AlwaysStoppedAnimation<
                            Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '${(value * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          Text(
            progress.isJobReady
                ? 'You are Job Ready! 🎉'
                : 'Keep building your career profile',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}