import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../models/assignment_model.dart';
import '../../../../models/submission_model.dart';
import '../../../../services/submission_service.dart';
import 'submit_assignment_screen.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final AssignmentModel assignment;
  final SubmissionModel? submission;
  final String batchId;

  const AssignmentDetailScreen({
    super.key,
    required this.assignment,
    required this.submission,
    required this.batchId,
  });

  @override
  State<AssignmentDetailScreen> createState() =>
      _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState
    extends State<AssignmentDetailScreen> {
  SubmissionModel? _submission;

  bool _isLoading = true;
  bool _isOpeningSubmit = false;

  @override
  void initState() {
    super.initState();

    _submission = widget.submission;

    _loadSubmission();
  }

  // ============================================================
  // LOAD SUBMISSION
  // ============================================================

  Future<void> _loadSubmission() async {
    try {
      final SubmissionModel? submission =
      await SubmissionService.instance
          .getMySubmission(
        widget.assignment.id,
      );

      if (!mounted) return;

      setState(() {
        _submission = submission;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // OPEN SUBMIT SCREEN
  // ============================================================

  Future<void> _openSubmitScreen() async {
    if (_isOpeningSubmit) return;

    setState(() {
      _isOpeningSubmit = true;
    });

    try {
      final dynamic result =
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SubmitAssignmentScreen(
                assignment: widget.assignment,
                batchId: widget.batchId,
              ),
        ),
      );

      if (result == true) {
        await _loadSubmission();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningSubmit = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final AssignmentModel assignment =
        widget.assignment;

    final bool canSubmit =
        _submission == null;

    return Scaffold(
      backgroundColor:
      AppColors.background,
      appBar: AppBar(
        title: Text(
          assignment.isQuiz
              ? 'Quiz Details'
              : 'Assignment Details',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSubmission,
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(
            AppDimensions.paddingMedium,
          ),
          children: [
            FadeSlideAnimation(
              child:
              _buildAssignmentHeader(),
            ),

            const SizedBox(height: 16),

            FadeSlideAnimation(
              delay:
              const Duration(
                milliseconds: 100,
              ),
              child: _buildDescription(),
            ),

            const SizedBox(height: 16),

            if (assignment.instructions
                .trim()
                .isNotEmpty) ...[
              FadeSlideAnimation(
                delay:
                const Duration(
                  milliseconds: 150,
                ),
                child:
                _buildInstructions(),
              ),
              const SizedBox(height: 16),
            ],

            if (_isLoading)
              _buildLoadingCard()
            else if (_submission != null)
              _buildSubmissionCard(
                _submission!,
              )
            else
              _buildNotSubmittedCard(),

            const SizedBox(height: 20),

            if (!_isLoading &&
                canSubmit)
              SizedBox(
                height:
                AppDimensions.buttonHeight,
                child:
                ElevatedButton.icon(
                  onPressed:
                  _isOpeningSubmit
                      ? null
                      : _openSubmitScreen,
                  icon: _isOpeningSubmit
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                      Colors.white,
                    ),
                  )
                      : Icon(
                    assignment.isQuiz
                        ? Icons
                        .quiz_outlined
                        : Icons
                        .upload_file_outlined,
                  ),
                  label: Text(
                    assignment.isQuiz
                        ? 'Start Quiz'
                        : 'Submit Assignment',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildAssignmentHeader() {
    final AssignmentModel assignment =
        widget.assignment;

    return Container(
      padding:
      const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  assignment.title,
                  style:
                  AppTextStyles.heading2,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration:
                BoxDecoration(
                  color: assignment.isQuiz
                      ? AppColors.primary
                      .withValues(
                    alpha: 0.12,
                  )
                      : AppColors.success
                      .withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  assignment.isQuiz
                      ? 'Quiz'
                      : 'Assignment',
                  style:
                  AppTextStyles.bodySmall
                      .copyWith(
                    color:
                    assignment.isQuiz
                        ? AppColors
                        .primary
                        : AppColors
                        .success,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _infoRow(
            Icons.stars_outlined,
            '${assignment.totalMarks} marks',
          ),

          const SizedBox(height: 8),

          _infoRow(
            Icons.schedule_outlined,
            assignment.dueDate == null
                ? 'No due date'
                : 'Due ${DateFormat(
              'dd MMM yyyy, hh:mm a',
            ).format(
              assignment.dueDate!,
            )}',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  Widget _buildDescription() {
    return _sectionCard(
      title: 'Description',
      icon: Icons.description_outlined,
      child: Text(
        widget.assignment.description
            .trim()
            .isEmpty
            ? 'No description provided.'
            : widget.assignment.description,
        style:
        AppTextStyles.bodyMedium,
      ),
    );
  }

  // ============================================================
  // INSTRUCTIONS
  // ============================================================

  Widget _buildInstructions() {
    return _sectionCard(
      title: 'Instructions',
      icon: Icons.info_outline_rounded,
      child: Text(
        widget.assignment.instructions,
        style:
        AppTextStyles.bodyMedium,
      ),
    );
  }

  // ============================================================
  // NOT SUBMITTED
  // ============================================================

  Widget _buildNotSubmittedCard() {
    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.pending_actions_rounded,
            color: AppColors.primary,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Not Submitted',
                  style:
                  AppTextStyles.heading3,
                ),
                SizedBox(height: 4),
                Text(
                  'You have not submitted this assignment yet.',
                  style:
                  AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBMISSION CARD
  // ============================================================

  Widget _buildSubmissionCard(
      SubmissionModel submission,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
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
              Icon(
                submission.isMarked
                    ? Icons
                    .verified_rounded
                    : submission.isLate
                    ? Icons
                    .warning_rounded
                    : Icons
                    .check_circle_rounded,
                color:
                submission.isMarked
                    ? AppColors.success
                    : submission.isLate
                    ? AppColors.error
                    : AppColors
                    .success,
              ),
              const SizedBox(width: 8),
              Text(
                'Submission',
                style:
                AppTextStyles.heading3,
              ),
            ],
          ),

          const SizedBox(height: 16),

          _submissionStatus(
            submission,
          ),

          if (submission.submittedAt !=
              null) ...[
            const SizedBox(height: 10),
            _infoRow(
              Icons.access_time_rounded,
              'Submitted ${DateFormat(
                'dd MMM yyyy, hh:mm a',
              ).format(
                submission.submittedAt!,
              )}',
            ),
          ],

          if (submission.answerText
              .trim()
              .isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              'Your Answer',
              style:
              AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(12),
              decoration:
              BoxDecoration(
                color:
                AppColors.background,
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              child: Text(
                submission.answerText,
                style:
                AppTextStyles.bodyMedium,
              ),
            ),
          ],

          if (submission.fileName !=
              null &&
              submission.fileName!
                  .trim()
                  .isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons
                      .attach_file_rounded,
                  color:
                  AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    submission.fileName!,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ],

          if (submission.marks !=
              null) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(14),
              decoration:
              BoxDecoration(
                color: AppColors.primary
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
                        .emoji_events_outlined,
                    color:
                    AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Marks: ${submission.marks} / ${widget.assignment.totalMarks}',
                    style:
                    AppTextStyles.heading3,
                  ),
                ],
              ),
            ),
          ],

          if (submission.feedback !=
              null &&
              submission.feedback!
                  .trim()
                  .isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Instructor Feedback',
              style:
              AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              submission.feedback!,
              style:
              AppTextStyles.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _submissionStatus(
      SubmissionModel submission,
      ) {
    String title;
    String description;
    IconData icon;
    Color color;

    if (submission.isMarked) {
      title = 'Marked';
      description =
      'Your instructor has checked this submission.';
      icon = Icons.verified_rounded;
      color = AppColors.success;
    } else if (submission.isLate) {
      title = 'Submitted Late';
      description =
      'This assignment was submitted after the due date.';
      icon = Icons.warning_rounded;
      color = AppColors.error;
    } else {
      title = 'Submitted';
      description =
      'Your assignment has been successfully submitted.';
      icon = Icons.check_circle_rounded;
      color = AppColors.success;
    }

    return Container(
      padding:
      const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                  AppTextStyles.heading3
                      .copyWith(
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style:
                  AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoadingCard() {
    return Container(
      padding:
      const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Center(
        child:
        CircularProgressIndicator(),
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
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
              Icon(
                icon,
                color:
                AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style:
                AppTextStyles.heading3,
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
      IconData icon,
      String text,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style:
            AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}