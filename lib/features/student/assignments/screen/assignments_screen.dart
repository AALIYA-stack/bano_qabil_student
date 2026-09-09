import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../models/assignment_model.dart';
import '../../../../services/assignment_service.dart';
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

  Future<List<AssignmentModel>>?
  _assignmentsFuture;

  String _batchId = '';

  @override
  void initState() {
    super.initState();

    _loadAssignments();
  }

  // ============================================================
  // LOAD STUDENT BATCH
  // ============================================================

  Future<void> _loadAssignments() async {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _assignmentsFuture =
              Future.value([]);
        });
      }

      return;
    }

    try {
      final DocumentSnapshot<
          Map<String, dynamic>> userDoc =
      await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        if (mounted) {
          setState(() {
            _assignmentsFuture =
                Future.value([]);
          });
        }

        return;
      }

      final Map<String, dynamic> data =
          userDoc.data() ?? {};

      final String batchId =
          data['batchId']?.toString() ?? '';

      if (mounted) {
        setState(() {
          _batchId = batchId;

          _assignmentsFuture =
              AssignmentService.instance
                  .getAssignmentsForBatch(
                batchId,
              );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _assignmentsFuture =
              Future.error(e);
        });
      }
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    await _loadAssignments();
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
          'Assignments',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: FutureBuilder<
          List<AssignmentModel>>(
        future: _assignmentsFuture,

        builder: (
            context,
            snapshot,
            ) {
          // ------------------------------------------------------
          // LOADING
          // ------------------------------------------------------

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          // ------------------------------------------------------
          // ERROR
          // ------------------------------------------------------

          if (snapshot.hasError) {
            return _buildErrorState(
              snapshot.error,
            );
          }

          final List<AssignmentModel>
          assignments =
              snapshot.data ?? [];

          // ------------------------------------------------------
          // EMPTY
          // ------------------------------------------------------

          if (assignments.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height:
                    MediaQuery.of(context)
                        .size
                        .height *
                        0.25,
                  ),
                  _buildEmptyState(),
                ],
              ),
            );
          }

          // ------------------------------------------------------
          // LIST
          // ------------------------------------------------------

          return RefreshIndicator(
            onRefresh: _refresh,

            child: ListView.builder(
              physics:
              const AlwaysScrollableScrollPhysics(),

              padding:
              const EdgeInsets.all(
                AppDimensions.paddingMedium,
              ),

              itemCount:
              assignments.length,

              itemBuilder:
                  (context, index) {
                final AssignmentModel
                assignment =
                assignments[index];

                return FadeSlideAnimation(
                  delay: Duration(
                    milliseconds:
                    index * 60,
                  ),
                  child:
                  _buildAssignmentCard(
                    context,
                    assignment,
                  ),
                );
              },
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
      BuildContext context,
      AssignmentModel assignment,
      ) {
    final bool pastDue =
        assignment.isPastDue;

    return Card(
      elevation: 0,

      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: InkWell(
        borderRadius:
        BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),

        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AssignmentDetailScreen(
                    assignment: assignment,
                    submission: null,
                    batchId: _batchId,
                  ),
            ),
          );

          if (mounted) {
            _loadAssignments();
          }
        },

        child: Padding(
          padding:
          const EdgeInsets.all(
            AppDimensions.paddingMedium,
          ),

          child: Row(
            children: [
              // ------------------------------------------------
              // ICON
              // ------------------------------------------------

              Container(
                width: 48,
                height: 48,

                decoration:
                BoxDecoration(
                  color:
                  AppColors.accentLight,
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),

                child: Icon(
                  assignment.isQuiz
                      ? Icons.quiz_outlined
                      : Icons
                      .assignment_outlined,

                  color:
                  AppColors.primary,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              // ------------------------------------------------
              // DETAILS
              // ------------------------------------------------

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      assignment.title
                          .isEmpty
                          ? 'Untitled Assignment'
                          : assignment.title,

                      maxLines: 2,

                      overflow:
                      TextOverflow.ellipsis,

                      style:
                      const TextStyle(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      assignment.dueDate ==
                          null
                          ? 'No due date'
                          : 'Due ${DateFormat('dd MMM yyyy').format(assignment.dueDate!)}',

                      style:
                      TextStyle(
                        fontSize: 11,
                        color: pastDue
                            ? AppColors.error
                            : AppColors
                            .textSecondary,
                        fontWeight:
                        pastDue
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      '${assignment.totalMarks} marks',

                      style:
                      const TextStyle(
                        fontSize: 11,
                        color:
                        AppColors
                            .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              // ------------------------------------------------
              // ARROW
              // ------------------------------------------------

              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 15,
                color:
                AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Padding(
      padding:
      const EdgeInsets.all(30),

      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 64,
            color:
            AppColors.textSecondary,
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            'No assignments yet',
            style:
            AppTextStyles.heading2,
            textAlign:
            TextAlign.center,
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            'Assignments for your batch will appear here.',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              color:
              AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
      Object? error,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color:
              AppColors.error,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              'Unable to load assignments',
              style:
              AppTextStyles.heading2,
              textAlign:
              TextAlign.center,
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Please check your internet connection and try again.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                AppColors.textSecondary,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            if (error != null)
              Text(
                error.toString(),
                textAlign:
                TextAlign.center,
                maxLines: 3,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  fontSize: 10,
                  color:
                  AppColors
                      .textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}