import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../models/progress_model.dart';

class OverallProgressCard extends StatelessWidget {
  final ProgressModel progress;

  const OverallProgressCard({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
    progress.overallPercentage.clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(24),
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
        BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Overall Progress',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 22),

          TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0,
              end: percentage / 100,
            ),
            duration: const Duration(
              milliseconds: 1100,
            ),
            curve: Curves.easeOutCubic,
            builder: (
                context,
                value,
                child,
                ) {
              return SizedBox(
                width: 170,
                height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 170,
                      height: 170,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 13,
                        backgroundColor:
                        Colors.white24,
                        valueColor:
                        const AlwaysStoppedAnimation<
                            Color>(
                          Colors.white,
                        ),
                      ),
                    ),

                    Column(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Text(
                          '${(value * 100).toStringAsFixed(0)}%',
                          style:
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'Complete',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: Text(
              progress.overallLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Keep learning and stay consistent!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}