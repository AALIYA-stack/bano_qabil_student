import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../models/assignment_model.dart';
import '../../../../models/submission_model.dart';
import 'submit_assignment_screen.dart';

class AssignmentDetailScreen
    extends StatelessWidget {
  final AssignmentModel assignment;
  final SubmissionModel? submission;
  final String batchId;

  const AssignmentDetailScreen({
    super.key,
    required this.assignment,
    required this.submission,
    required this.batchId,
  });

  // ============================================================
  // CAN SUBMIT
  // ============================================================

  bool get _canSubmit {
    return submission == null;
  }

  // ============================================================
  // STATUS
  // ============================================================

  String get _status {
    return submission?.status
        .toLowerCase() ??
        'pending';
  }

  String get _statusLabel {
    switch (_status) {
      case 'submitted':
        return 'Submitted';

      case 'late':
        return 'Late Submission';

      case 'marked':
        return 'Marked';

      default:
        return 'Pending';
    }
  }

  Color get _statusColor {
    switch (_status) {
      case 'submitted':
        return AppColors.info;

      case 'late':
        return AppColors.error;

      case 'marked':
        return AppColors.success;

      default:
        return AppColors.warning;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      AppColors.background,

      appBar: AppBar(
        title: const Text(
          'Assignment Details',
        ),
      ),

      body: ListView(
        padding:
        const EdgeInsets.all(
          AppDimensions.paddingMedium,
        ),

        children: [
          FadeSlideAnimation(
            child: _buildHeader(),
          ),

          const SizedBox(
            height: 16,
          ),

          FadeSlideAnimation(
            delay:
            const Duration(
              milliseconds: 100,
            ),
            child: _buildSection(
              title: 'Description',
              icon:
              Icons.description_outlined,
              child: Text(
                assignment.description
                    .isEmpty
                    ? 'No description provided.'
                    : assignment.description,
                style:
                AppTextStyles.bodyLarge
                    .copyWith(
                  height: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          FadeSlideAnimation(
            delay:
            const Duration(
              milliseconds: 160,
            ),
            child: _buildSection(
              title: 'Instructions',
              icon:
              Icons.rule_folder_outlined,
              child: Text(
                assignment.instructions
                    .isEmpty
                    ? 'No special instructions provided.'
                    : assignment.instructions,
                style:
                AppTextStyles.bodyLarge
                    .copyWith(
                  height: 1.5,
                ),
              ),
            ),
          ),

          if (submission != null) ...[
            const SizedBox(
              height: 14,
            ),

            FadeSlideAnimation(
              delay:
              const Duration(
                milliseconds: 220,
              ),
              child:
              _buildSubmission(),
            ),
          ],

          if (_canSubmit) ...[
            const SizedBox(
              height: 18,
            ),

            FadeSlideAnimation(
              delay:
              const Duration(
                milliseconds: 250,
              ),

              child: SizedBox(
                height:
                AppDimensions
                    .buttonHeight,

                child:
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SubmitAssignmentScreen(
                              assignment:
                              assignment,
                              batchId:
                              batchId,
                            ),
                      ),
                    );
                  },

                  icon: const Icon(
                    Icons
                        .upload_file_rounded,
                  ),

                  label: const Text(
                    'Submit Assignment',
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      padding:
      const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient:
        const LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
          ],
        ),

        borderRadius:
        BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            assignment.title
                .isEmpty
                ? 'Assignment'
                : assignment.title,

            style:
            const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          Row(
            children: [
              const Icon(
                Icons
                    .calendar_today_outlined,
                size: 17,
                color:
                Colors.white70,
              ),

              const SizedBox(
                width: 7,
              ),

              Expanded(
                child: Text(
                  assignment.dueDate ==
                      null
                      ? 'No due date'
                      : 'Due ${DateFormat('dd MMM yyyy, hh:mm a').format(assignment.dueDate!)}',

                  style:
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 9,
          ),

          Row(
            children: [
              const Icon(
                Icons.stars_outlined,
                size: 17,
                color:
                Colors.white70,
              ),

              const SizedBox(
                width: 7,
              ),

              Text(
                '${assignment.totalMarks} marks',

                style:
                const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          Container(
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 10,
              vertical: 7,
            ),

            decoration:
            BoxDecoration(
              color:
              Colors.white.withValues(
                alpha: 0.12,
              ),

              borderRadius:
              BorderRadius.circular(
                20,
              ),
            ),

            child: Text(
              _statusLabel,

              style:
              const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color:
        AppColors.surface,

        borderRadius:
        BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),

        border: Border.all(
          color:
          AppColors.border,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(
                icon,
                color:
                AppColors.primary,
                size: 20,
              ),

              const SizedBox(
                width: 8,
              ),

              Text(
                title,
                style:
                AppTextStyles.heading3,
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          child,
        ],
      ),
    );
  }

  // ============================================================
  // SUBMISSION
  // ============================================================

  Widget _buildSubmission() {
    return Container(
      padding:
      const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color:
        AppColors.surface,

        borderRadius:
        BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),

        border: Border.all(
          color:
          AppColors.border,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(
                Icons.task_alt_rounded,
                color:
                AppColors.success,
              ),

              const SizedBox(
                width: 8,
              ),

              const Text(
                'Your Submission',
                style:
                AppTextStyles.heading3,
              ),

              const Spacer(),

              Container(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),

                decoration:
                BoxDecoration(
                  color:
                  _statusColor
                      .withValues(
                    alpha: 0.10,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),

                child: Text(
                  _statusLabel,

                  style:
                  TextStyle(
                    color:
                    _statusColor,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          if (submission!.answerText
              .isNotEmpty) ...[
            const Text(
              'Answer',
              style:
              AppTextStyles.bodySmall,
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              submission!.answerText,

              style:
              AppTextStyles.bodyLarge
                  .copyWith(
                height: 1.5,
              ),
            ),

            const SizedBox(
              height: 14,
            ),
          ],

          if (submission!.fileName !=
              null)
            Row(
              children: [
                const Icon(
                  Icons
                      .attach_file_rounded,
                  size: 18,
                  color:
                  AppColors.primary,
                ),

                const SizedBox(
                  width: 7,
                ),

                Expanded(
                  child: Text(
                    submission!.fileName!,

                    style:
                    AppTextStyles
                        .bodyMedium,

                    overflow:
                    TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          if (submission!
              .submittedAt !=
              null) ...[
            const SizedBox(
              height: 12,
            ),

            Text(
              'Submitted: ${DateFormat('dd MMM yyyy, hh:mm a').format(submission!.submittedAt!)}',

              style:
              AppTextStyles.bodySmall,
            ),
          ],

          if (submission!.marks !=
              null) ...[
            const SizedBox(
              height: 18,
            ),

            Container(
              padding:
              const EdgeInsets.all(
                14,
              ),

              decoration:
              BoxDecoration(
                color:
                AppColors.success
                    .withValues(
                  alpha: 0.08,
                ),

                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons
                        .workspace_premium_outlined,
                    color:
                    AppColors.success,
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Text(
                    'Marks: ${submission!.marks} / ${assignment.totalMarks}',

                    style:
                    const TextStyle(
                      color:
                      AppColors.success,
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (submission!.feedback !=
              null &&
              submission!
                  .feedback!
                  .isNotEmpty) ...[
            const SizedBox(
              height: 14,
            ),

            const Text(
              'Instructor Feedback',
              style:
              AppTextStyles.bodySmall,
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              submission!.feedback!,

              style:
              AppTextStyles.bodyLarge
                  .copyWith(
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}