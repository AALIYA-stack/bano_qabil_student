import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../core/constants/collection_names.dart';
import '../../../../models/assignment_model.dart';
import '../../../../models/submission_model.dart';
import '../../../../services/assignment_service.dart';
import '../../../../services/submission_service.dart';
import 'assignment_detail_screen.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({
    super.key,
  });

  @override
  State<AssignmentsScreen> createState() =>
      _AssignmentsScreenState();
}

class _AssignmentsScreenState
    extends State<AssignmentsScreen> {
  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool _isLoading = true;

  String? _batchId;

  String? _errorMessage;

  List<AssignmentModel> _assignments = [];

  final Map<String, SubmissionModel?>
  _submissions = {};

  @override
  void initState() {
    super.initState();

    _loadAssignments();
  }

  // ============================================================
  // LOAD ASSIGNMENTS
  // ============================================================

  Future<void> _loadAssignments() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final User? user =
          _auth.currentUser;

      if (user == null) {
        throw Exception(
          'Please login first.',
        );
      }

      final DocumentSnapshot<
          Map<String, dynamic>> userDoc =
      await _firestore
          .collection(
        CollectionNames.users,
      )
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception(
          'Student profile not found.',
        );
      }

      final Map<String, dynamic> data =
          userDoc.data() ??
              <String, dynamic>{};

      final String batchId =
          data['batchId']?.toString().trim() ??
              '';

      if (batchId.isEmpty) {
        throw Exception(
          'No batch is assigned to your account.',
        );
      }

      final List<AssignmentModel>
      assignments =
      await AssignmentService.instance
          .getAssignmentsForBatch(
        batchId,
      );

      // --------------------------------------------------------
      // LOAD SUBMISSIONS
      // --------------------------------------------------------

      final Map<String, SubmissionModel?>
      submissions = {};

      for (final AssignmentModel assignment
      in assignments) {
        try {
          submissions[assignment.id] =
          await SubmissionService
              .instance
              .getMySubmission(
            assignment.id,
          );
        } catch (_) {
          submissions[assignment.id] =
          null;
        }
      }

      if (!mounted) return;

      setState(() {
        _batchId = batchId;
        _assignments = assignments;
        _submissions
          ..clear()
          ..addAll(submissions);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        );
      });
    }
  }

  // ============================================================
  // OPEN DETAIL
  // ============================================================

  Future<void> _openAssignment(
      AssignmentModel assignment,
      ) async {
    final String? batchId =
        _batchId;

    if (batchId == null ||
        batchId.isEmpty) {
      _showMessage(
        'Student batch is not available.',
        isError: true,
      );
      return;
    }

    final dynamic result =
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AssignmentDetailScreen(
              assignment: assignment,
              submission:
              _submissions[assignment.id],
              batchId: batchId,
            ),
      ),
    );

    if (result == true) {
      await _loadAssignments();
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AppColors.error
            : AppColors.success,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Assignments',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
            _isLoading
                ? null
                : _loadAssignments,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_assignments.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: _loadAssignments,
      child: ListView.separated(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(
          AppDimensions.paddingMedium,
        ),
        itemCount: _assignments.length,
        separatorBuilder:
            (_, __) =>
        const SizedBox(height: 12),
        itemBuilder:
            (context, index) {
          final AssignmentModel assignment =
          _assignments[index];

          final SubmissionModel? submission =
          _submissions[assignment.id];

          return FadeSlideAnimation(
            delay: Duration(
              milliseconds:
              60 * index,
            ),
            child:
            _buildAssignmentCard(
              assignment,
              submission,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ASSIGNMENT CARD
  // ============================================================

  Widget _buildAssignmentCard(
      AssignmentModel assignment,
      SubmissionModel? submission,
      ) {
    final bool submitted =
        submission != null;

    final bool marked =
        submission?.isMarked ?? false;

    final bool late =
        submission?.isLate ?? false;

    return InkWell(
      borderRadius:
      BorderRadius.circular(
        AppDimensions.radiusLarge,
      ),
      onTap: () =>
          _openAssignment(
            assignment,
          ),
      child: Container(
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
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration:
                  BoxDecoration(
                    color:
                    AppColors.primary
                        .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Icon(
                    assignment.isQuiz
                        ? Icons
                        .quiz_outlined
                        : Icons
                        .assignment_outlined,
                    color:
                    AppColors.primary,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        assignment.title,
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: AppTextStyles
                            .heading3,
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        assignment.isQuiz
                            ? 'Quiz'
                            : 'Assignment',
                        style: AppTextStyles
                            .bodySmall
                            .copyWith(
                          color:
                          AppColors
                              .primary,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  size: 16,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(
                  Icons
                      .stars_outlined,
                  size: 17,
                  color:
                  AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${assignment.totalMarks} marks',
                  style: AppTextStyles
                      .bodySmall,
                ),

                const SizedBox(width: 18),

                const Icon(
                  Icons
                      .schedule_outlined,
                  size: 17,
                  color:
                  AppColors.primary,
                ),
                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    assignment.dueDate ==
                        null
                        ? 'No due date'
                        : DateFormat(
                      'dd MMM yyyy',
                    ).format(
                      assignment.dueDate!,
                    ),
                    overflow:
                    TextOverflow.ellipsis,
                    style: AppTextStyles
                        .bodySmall,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            _buildStatus(
              submitted: submitted,
              marked: marked,
              late: late,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _buildStatus({
    required bool submitted,
    required bool marked,
    required bool late,
  }) {
    String text;
    Color color;
    IconData icon;

    if (marked) {
      text = 'Marked';
      color = AppColors.success;
      icon = Icons.verified_rounded;
    } else if (late) {
      text = 'Submitted Late';
      color = AppColors.error;
      icon = Icons.warning_rounded;
    } else if (submitted) {
      text = 'Submitted';
      color = AppColors.success;
      icon = Icons.check_circle_rounded;
    } else {
      text = 'Not Submitted';
      color = AppColors.primary;
      icon = Icons.pending_actions_rounded;
    }

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style:
            AppTextStyles.bodySmall
                .copyWith(
              color: color,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return RefreshIndicator(
      onRefresh: _loadAssignments,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
            MediaQuery.of(context)
                .size
                .height *
                0.30,
          ),
          const Icon(
            Icons.assignment_outlined,
            size: 70,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'No assignments yet',
              style:
              AppTextStyles.heading2,
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Your instructor has not added any assignments for your batch.',
              textAlign:
              TextAlign.center,
              style:
              AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ??
                  'Something went wrong.',
              textAlign:
              TextAlign.center,
              style:
              AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed:
              _loadAssignments,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}