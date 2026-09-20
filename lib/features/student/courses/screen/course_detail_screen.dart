import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../models/batch_model.dart';
import '../../../../models/campus_model.dart';
import '../../../../models/course_model.dart';
import '../../../../services/batch_service.dart';
import '../../../../services/campus_service.dart';
import '../../applications/screen/application_form_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailScreen> createState() =>
      _CourseDetailScreenState();
}

class _CourseDetailScreenState
    extends State<CourseDetailScreen> {
  late Future<List<_BatchOption>> _batchFuture;

  String? _selectedBatchId;

  @override
  void initState() {
    super.initState();

    _batchFuture = _loadBatchOptions();
  }

  // ============================================================
  // LOAD BATCH OPTIONS
  // ============================================================

  Future<List<_BatchOption>> _loadBatchOptions() async {
    debugPrint('========================================');
    debugPrint('LOADING BATCH OPTIONS');
  debugPrint('COURSE ID FROM SCREEN: ${widget.course.id}');
    debugPrint('COURSE NAME: ${widget.course.name}');

    try {
      final batches =
      await BatchService.instance.getBatchesForCourse(
        widget.course.id,
      );

      debugPrint('BATCHES RECEIVED: ${batches.length}');

      final List<_BatchOption> result = [];

      for (final batch in batches) {
        debugPrint('----------------------------------------');
        debugPrint('CHECKING BATCH');
        debugPrint('Batch ID: ${batch.id}');
        debugPrint('Course ID: ${batch.courseId}');
        debugPrint('Campus ID: ${batch.campusId}');
        debugPrint('Is Open: ${batch.isOpen}');
        debugPrint('Seats: ${batch.seats}');
        debugPrint('Enrolled: ${batch.enrolledStudents}');
        debugPrint('Seats Left: ${batch.seatsLeft}');

        // --------------------------------------------------------
        // CHECK CAMPUS ID
        // --------------------------------------------------------

        if (batch.campusId.trim().isEmpty) {
          debugPrint('❌ CAMPUS ID IS EMPTY');
          continue;
        }

        debugPrint(
          'Getting campus by ID: ${batch.campusId}',
        );

        // --------------------------------------------------------
        // LOAD CAMPUS
        // --------------------------------------------------------

        final campus =
        await CampusService.instance.getCampusById(
          batch.campusId,
        );

        // --------------------------------------------------------
        // CAMPUS NOT FOUND
        // --------------------------------------------------------

        if (campus == null) {
          debugPrint(
            '❌ CAMPUS NOT FOUND: ${batch.campusId}',
          );
          continue;
        }

        // --------------------------------------------------------
        // CAMPUS FOUND
        // --------------------------------------------------------

        debugPrint('✅ CAMPUS FOUND');
        debugPrint('Campus ID: ${campus.id}');
        debugPrint('Campus Name: ${campus.name}');
        debugPrint('Campus City: ${campus.city}');
        debugPrint('Campus Province: ${campus.province}');
        debugPrint('Campus Active: ${campus.isActive}');

        // --------------------------------------------------------
        // ADD BATCH OPTION
        // --------------------------------------------------------

        result.add(
          _BatchOption(
            batch: batch,
            campus: campus,
          ),
        );

        debugPrint('✅ BATCH ADDED TO RESULT');
      }

      debugPrint('----------------------------------------');
      debugPrint(
        'FINAL BATCH OPTIONS: ${result.length}',
      );

      if (result.isEmpty) {
        debugPrint('❌ NO BATCH OPTIONS AVAILABLE');
      } else {
        debugPrint('✅ BATCH OPTIONS AVAILABLE');

        for (final option in result) {
          debugPrint(
            'OPTION: '
                '${option.batch.id} | '
                'Course: ${option.batch.courseId} | '
                'Campus: ${option.campus.name}',
          );
        }
      }

      debugPrint('========================================');

      return result;
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('❌ ERROR LOADING BATCH OPTIONS');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('========================================');

      rethrow;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    setState(() {
      _batchFuture = _loadBatchOptions();
    });

    await _batchFuture;
  }

  // ============================================================
  // APPLY NOW
  // ============================================================

  Future<void> _applyNow() async {
    if (_selectedBatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a campus and batch first.',
          ),
        ),
      );

      return;
    }

    final options = await _batchFuture;

    _BatchOption? selectedOption;

    for (final option in options) {
      if (option.batch.id == _selectedBatchId) {
        selectedOption = option;
        break;
      }
    }

    if (selectedOption == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selected batch is no longer available.',
          ),
        ),
      );

      return;
    }

    if (selectedOption.batch.seatsLeft <= 0) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This batch has no seats available.',
          ),
        ),
      );

      return;
    }

    if (!mounted) return;

    final submitted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ApplicationFormScreen(
          course: widget.course,
          batch: selectedOption!.batch,
          campus: selectedOption.campus,
        ),
      ),
    );

    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your application has been submitted.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'Course Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // BOTTOM APPLY BUTTON
      // ========================================================

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _applyNow,
              child: const Text(
                'Apply Now',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            100,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // ==================================================
              // COURSE HEADER
              // ==================================================

              FadeSlideAnimation(
                child: _CourseHeader(
                  course: widget.course,
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // ABOUT COURSE
              // ==================================================

              const FadeSlideAnimation(
                delay: Duration(milliseconds: 100),
                child: Text(
                  'About this course',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              FadeSlideAnimation(
                delay:
                const Duration(milliseconds: 150),
                child: Text(
                  widget.course.description.isEmpty
                      ? 'Learn practical IT skills through structured training and hands-on assignments.'
                      : widget.course.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // AVAILABLE CAMPUSES
              // ==================================================

              const FadeSlideAnimation(
                delay: Duration(milliseconds: 200),
                child: Text(
                  'Available Campuses',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const FadeSlideAnimation(
                delay: Duration(milliseconds: 220),
                child: Text(
                  'Select a campus and batch to continue.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // BATCH FUTURE BUILDER
              // ==================================================

              FutureBuilder<List<_BatchOption>>(
                future: _batchFuture,
                builder: (context, snapshot) {
                  // ------------------------------------------------
                  // LOADING
                  // ------------------------------------------------

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child:
                        CircularProgressIndicator(),
                      ),
                    );
                  }

                  // ------------------------------------------------
                  // ERROR
                  // ------------------------------------------------

                  if (snapshot.hasError) {
                    debugPrint(
                      '❌ FUTURE BUILDER ERROR: '
                          '${snapshot.error}',
                    );

                    return _ErrorCard(
                      onRetry: _refresh,
                    );
                  }

                  // ------------------------------------------------
                  // DATA
                  // ------------------------------------------------

                  final options =
                      snapshot.data ?? [];

                  // ------------------------------------------------
                  // EMPTY
                  // ------------------------------------------------

                  if (options.isEmpty) {
                    return const _EmptyCampusCard();
                  }

                  // ------------------------------------------------
                  // SHOW BATCHES
                  // ------------------------------------------------

                  return Column(
                    children: List.generate(
                      options.length,
                          (index) {
                        final option =
                        options[index];

                        return Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: FadeSlideAnimation(
                            delay: Duration(
                              milliseconds:
                              250 + (index * 80),
                            ),
                            child: _BatchCard(
                              option: option,
                              selected:
                              _selectedBatchId ==
                                  option.batch.id,
                              onTap: () {
                                setState(() {
                                  _selectedBatchId =
                                      option.batch.id;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// COURSE HEADER
// ==================================================================

class _CourseHeader extends StatelessWidget {
  final CourseModel course;

  const _CourseHeader({
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius:
        BorderRadius.circular(
          AppDimensions.radiusXLarge,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.15,
              ),
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.code_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            course.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderChip(
                icon: Icons.bar_chart_rounded,
                text: course.level,
              ),

              _HeaderChip(
                icon: Icons.schedule_rounded,
                text: course.duration,
              ),

              _HeaderChip(
                icon: Icons.event_seat_outlined,
                text: '${course.seatsLeft} seats',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// HEADER CHIP
// ==================================================================

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.12,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.white,
          ),

          const SizedBox(width: 5),

          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// BATCH CARD
// ==================================================================

class _BatchCard extends StatelessWidget {
  final _BatchOption option;
  final bool selected;
  final VoidCallback onTap;

  const _BatchCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final batch = option.batch;
    final campus = option.campus;

    final startDate = batch.startDate == null
        ? 'Start date not available'
        : DateFormat(
      'dd MMM yyyy',
    ).format(batch.startDate!);

    return InkWell(
      borderRadius:
      BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentLight
              : AppColors.surface,
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.accent
                : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration:
              const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppColors.accent
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.accent
                      : AppColors.textLight,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                Icons.check,
                size: 15,
                color: Colors.white,
              )
                  : null,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    campus.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w700,
                      color:
                      AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${campus.city}, ${campus.province}',
                    style: const TextStyle(
                      fontSize: 12,
                      color:
                      AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _InfoRow(
                    icon:
                    Icons.calendar_today_outlined,
                    text:
                    '${batch.classDay} • ${batch.classTime}',
                  ),

                  const SizedBox(height: 7),

                  _InfoRow(
                    icon:
                    Icons.meeting_room_outlined,
                    text:
                    '${batch.room} • Starts $startDate',
                  ),

                  const SizedBox(height: 7),

                  _InfoRow(
                    icon:
                    Icons.event_seat_outlined,
                    text:
                    '${batch.seatsLeft} seats available',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// INFO ROW
// ==================================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: AppColors.textSecondary,
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Text(
            text,
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

// ==================================================================
// BATCH OPTION
// ==================================================================

class _BatchOption {
  final BatchModel batch;
  final CampusModel campus;

  const _BatchOption({
    required this.batch,
    required this.campus,
  });
}

// ==================================================================
// EMPTY CAMPUS CARD
// ==================================================================

class _EmptyCampusCard extends StatelessWidget {
  const _EmptyCampusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 42,
            color: AppColors.textLight,
          ),

          SizedBox(height: 12),

          Text(
            'No available batches',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'There are currently no open batches for this course.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// ERROR CARD
// ==================================================================

class _ErrorCard extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.error,
            size: 36,
          ),

          const SizedBox(height: 10),

          const Text(
            'Unable to load campuses.',
          ),

          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}