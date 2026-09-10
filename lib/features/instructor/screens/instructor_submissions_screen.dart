import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../models/assignment_model.dart';
import '../../../../models/submission_model.dart';

class InstructorSubmissionsScreen extends StatefulWidget {
  const InstructorSubmissionsScreen({
    super.key,
  });

  @override
  State<InstructorSubmissionsScreen> createState() =>
      _InstructorSubmissionsScreenState();
}

class _InstructorSubmissionsScreenState
    extends State<InstructorSubmissionsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  bool _isLoading = true;
  String? _errorMessage;

  List<_InstructorSubmissionItem> _submissions = [];

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    final user = _auth.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Instructor is not logged in.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get assignments created by the current instructor.
      final assignmentSnapshot = await _firestore
          .collection('assignments')
          .where(
            'createdBy',
            isEqualTo: user.uid,
          )
          .get();

      final assignments = assignmentSnapshot.docs
          .map(
            (doc) => AssignmentModel.fromFirestore(doc),
          )
          .toList();

      final List<_InstructorSubmissionItem> results = [];

      // Get submissions for each instructor assignment.
      for (final assignment in assignments) {
        final submissionSnapshot = await _firestore
            .collection('submissions')
            .where(
              'assignmentId',
              isEqualTo: assignment.id,
            )
            .get();

        for (final doc in submissionSnapshot.docs) {
          final submission =
              SubmissionModel.fromFirestore(doc);

          results.add(
            _InstructorSubmissionItem(
              assignment: assignment,
              submission: submission,
            ),
          );
        }
      }

      results.sort((a, b) {
        final aDate = a.submission.submittedAt;
        final bDate = b.submission.submittedAt;

        if (aDate == null && bDate == null) {
          return 0;
        }

        if (aDate == null) {
          return 1;
        }

        if (bDate == null) {
          return -1;
        }

        return bDate.compareTo(aDate);
      });

      if (!mounted) return;

      setState(() {
        _submissions = results;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Submissions'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSubmissions,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(
          AppDimensions.paddingMedium,
        ),
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.error_outline_rounded,
            size: 55,
            color: AppColors.error,
          ),
          const SizedBox(height: 15),
          Text(
            'Unable to load submissions',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadSubmissions,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text('Try Again'),
          ),
        ],
      );
    }

    if (_submissions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(
          AppDimensions.paddingMedium,
        ),
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.assignment_outlined,
            size: 65,
            color: AppColors.primary,
          ),
          const SizedBox(height: 18),
          Text(
            'No submissions yet',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          const Text(
            'Student submissions for your assignments will appear here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(
        AppDimensions.paddingMedium,
      ),
      itemCount: _submissions.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        return _buildSubmissionCard(
          _submissions[index],
        );
      },
    );
  }

  Widget _buildSubmissionCard(
      _InstructorSubmissionItem item,
      ) {
    final submission = item.submission;
    final assignment = item.assignment;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                  style: AppTextStyles.heading3,
                ),
              ),
              const SizedBox(width: 10),
              _buildStatusChip(
                submission.status,
              ),
            ],
          ),

          const SizedBox(height: 14),

          _buildInfoRow(
            Icons.person_outline_rounded,
            'Student ID',
            submission.studentId,
          ),

          const SizedBox(height: 8),

          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Submitted',
            submission.submittedAt == null
                ? 'Unknown'
                : DateFormat(
                    'dd MMM yyyy, hh:mm a',
                  ).format(
                    submission.submittedAt!,
                  ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Answer',
            style: AppTextStyles.heading3,
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Text(
              submission.answerText.isEmpty
                  ? 'No written answer.'
                  : submission.answerText,
              style: AppTextStyles.bodyMedium,
            ),
          ),

          if (submission.fileName != null) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.border,
                ),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.attach_file_rounded,
                    color: AppColors.primary,
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
            ),
          ],

          if (submission.marks != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.stars_outlined,
              'Marks',
              '${submission.marks} / ${assignment.totalMarks}',
            ),
          ],

          if (submission.feedback != null &&
              submission.feedback!
                  .trim()
                  .isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Feedback',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 6),
            Text(
              submission.feedback!,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium,
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final displayStatus =
        status.isEmpty ? 'submitted' : status;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        displayStatus.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InstructorSubmissionItem {
  final AssignmentModel assignment;
  final SubmissionModel submission;

  const _InstructorSubmissionItem({
    required this.assignment,
    required this.submission,
  });
}

