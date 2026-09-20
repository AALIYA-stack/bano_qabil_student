import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../models/batch_model.dart';
import '../../../../models/campus_model.dart';
import '../../../../models/coordinator_report_model.dart';
import '../../../../models/course_model.dart';
import '../../../../services/campus_service.dart';
import '../../../../services/coordinator_service.dart';
import '../../../../services/course_service.dart';

/// Coordinator's batch screen: create a batch (course, campus, seats,
/// start date), close/reopen a batch, and assign an instructor.
class BatchManagementScreen extends StatefulWidget {
  const BatchManagementScreen({super.key});

  @override
  State<BatchManagementScreen> createState() =>
      _BatchManagementScreenState();
}

class _BatchManagementScreenState
    extends State<BatchManagementScreen> {
  Future<void> _openCreateBatchSheet() async {
    final courses =
        await CourseService.instance.getActiveCourses();
    final campuses =
        await CampusService.instance.getActiveCampuses();

    if (!mounted) return;

    if (courses.isEmpty || campuses.isEmpty) {
      AppSnackbar.warning(
        context,
        'Seed demo data first so courses and campuses exist.',
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => _CreateBatchSheet(
        courses: courses,
        campuses: campuses,
      ),
    );
  }

  Future<void> _assignInstructor(BatchModel batch) async {
    final instructors =
        await CoordinatorService.instance.getInstructors();

    if (!mounted) return;

    if (instructors.isEmpty) {
      AppSnackbar.warning(
        context,
        'No instructor accounts found yet.',
      );
      return;
    }

    final selected = await showDialog<InstructorOption>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Assign instructor'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: instructors.length,
              itemBuilder: (context, index) {
                final instructor = instructors[index];

                return ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: Text(instructor.name),
                  subtitle: Text(instructor.email),
                  onTap: () =>
                      Navigator.pop(dialogContext, instructor),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (selected == null) return;

    try {
      await CoordinatorService.instance.assignInstructor(
        batchId: batch.id,
        instructorId: selected.uid,
      );

      if (!mounted) return;

      AppSnackbar.success(
        context,
        '${selected.name} assigned to ${batch.id}.',
      );
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _toggleBatchOpen(BatchModel batch) async {
    try {
      if (batch.isOpen) {
        await CoordinatorService.instance.closeBatch(batch.id);
      } else {
        await CoordinatorService.instance.reopenBatch(batch.id);
      }

      if (!mounted) return;

      AppSnackbar.success(
        context,
        batch.isOpen
            ? '${batch.id} closed.'
            : '${batch.id} reopened.',
      );
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Batches')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateBatchSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Batch'),
      ),
      body: StreamBuilder<List<BatchModel>>(
        stream: CoordinatorService.instance.batchesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(fullScreen: true);
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to load batches.\n${snapshot.error}'),
            );
          }

          final batches = snapshot.data ?? [];

          if (batches.isEmpty) {
            return const EmptyState(
              title: 'No batches yet',
              message: 'Create your first batch with the button below.',
              icon: Icons.groups_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingMedium,
              AppDimensions.paddingMedium,
              AppDimensions.paddingMedium,
              90,
            ),
            itemCount: batches.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final batch = batches[index];

              return FadeSlideAnimation(
                delay: Duration(milliseconds: 40 * index),
                child: _BatchCard(
                  batch: batch,
                  onAssignInstructor: () => _assignInstructor(batch),
                  onToggleOpen: () => _toggleBatchOpen(batch),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final BatchModel batch;
  final VoidCallback onAssignInstructor;
  final VoidCallback onToggleOpen;

  const _BatchCard({
    required this.batch,
    required this.onAssignInstructor,
    required this.onToggleOpen,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = batch.startDate == null
        ? 'Not set'
        : DateFormat('dd MMM yyyy').format(batch.startDate!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(batch.id, style: AppTextStyles.heading3),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: (batch.isOpen
                          ? AppColors.success
                          : AppColors.textSecondary)
                      .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  batch.isOpen ? 'Open' : 'Closed',
                  style: TextStyle(
                    color: batch.isOpen
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FutureBuilder<CourseModel?>(
            future: CourseService.instance.getCourseById(batch.courseId),
            builder: (context, snapshot) => _InfoRow(
              icon: Icons.menu_book_outlined,
              text: 'Course: ${snapshot.data?.name ?? batch.courseId}',
            ),
          ),
          const SizedBox(height: 6),
          FutureBuilder<CampusModel?>(
            future: CampusService.instance.getCampusById(batch.campusId),
            builder: (context, snapshot) => _InfoRow(
              icon: Icons.location_on_outlined,
              text: 'Campus: ${snapshot.data?.name ?? batch.campusId}',
            ),
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.person_outline_rounded,
            text: batch.instructorId.trim().isEmpty
                ? 'No instructor assigned'
                : 'Instructor: ${batch.instructorId}',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.event_seat_outlined,
            text:
                '${batch.enrolledStudents}/${batch.seats} enrolled • ${batch.seatsLeft} left',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text: '${batch.classDay} • ${batch.classTime} • Starts $startDate',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onAssignInstructor,
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                label: const Text('Assign Instructor'),
              ),
              OutlinedButton.icon(
                onPressed: onToggleOpen,
                icon: Icon(
                  batch.isOpen
                      ? Icons.lock_outline_rounded
                      : Icons.lock_open_rounded,
                  size: 18,
                ),
                label: Text(batch.isOpen ? 'Close Batch' : 'Reopen Batch'),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      batch.isOpen ? AppColors.error : AppColors.success,
                  side: BorderSide(
                    color: batch.isOpen
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 7),
        Expanded(
          child: Text(text, style: AppTextStyles.bodySmall),
        ),
      ],
    );
  }
}

class _CreateBatchSheet extends StatefulWidget {
  final List<CourseModel> courses;
  final List<CampusModel> campuses;

  const _CreateBatchSheet({
    required this.courses,
    required this.campuses,
  });

  @override
  State<_CreateBatchSheet> createState() => _CreateBatchSheetState();
}

class _CreateBatchSheetState extends State<_CreateBatchSheet> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _classDayController = TextEditingController();
  final _classTimeController = TextEditingController();
  final _roomController = TextEditingController();
  final _seatsController = TextEditingController(text: '30');

  CourseModel? _selectedCourse;
  CampusModel? _selectedCampus;
  DateTime? _startDate;
  bool _isSaving = false;

  Future<void> _pickStartDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCourse == null || _selectedCampus == null) {
      AppSnackbar.error(context, 'Select a course and a campus.');
      return;
    }

    final seats = int.tryParse(_seatsController.text.trim());

    if (seats == null || seats <= 0) {
      AppSnackbar.error(context, 'Enter a valid number of seats.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final batchId = _idController.text.trim();

      await CoordinatorService.instance.createBatch(
        id: batchId,
        batch: BatchModel(
          id: batchId,
          courseId: _selectedCourse!.id,
          campusId: _selectedCampus!.id,
          instructorId: '',
          classDay: _classDayController.text.trim(),
          classTime: _classTimeController.text.trim(),
          room: _roomController.text.trim(),
          startDate: _startDate,
          seats: seats,
          enrolledStudents: 0,
          isOpen: true,
        ),
      );

      if (!mounted) return;

      Navigator.pop(context);
      AppSnackbar.success(context, 'Batch "$batchId" created.');
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _classDayController.dispose();
    _classTimeController.dispose();
    _roomController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Batch',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Batch ID',
                  hintText: 'e.g. flutter-lahore-02',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Batch ID is required.'
                        : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<CourseModel>(
                initialValue: _selectedCourse,
                decoration: const InputDecoration(labelText: 'Course'),
                items: widget.courses
                    .map(
                      (course) => DropdownMenuItem(
                        value: course,
                        child: Text(course.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCourse = value),
                validator: (value) =>
                    value == null ? 'Select a course.' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<CampusModel>(
                initialValue: _selectedCampus,
                decoration: const InputDecoration(labelText: 'Campus'),
                items: widget.campuses
                    .map(
                      (campus) => DropdownMenuItem(
                        value: campus,
                        child: Text('${campus.name} (${campus.city})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCampus = value),
                validator: (value) =>
                    value == null ? 'Select a campus.' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _seatsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Seats'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _classDayController,
                decoration: const InputDecoration(
                  labelText: 'Class Day(s)',
                  hintText: 'e.g. Mon, Wed, Fri',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _classTimeController,
                decoration: const InputDecoration(
                  labelText: 'Class Time',
                  hintText: 'e.g. 6:00 PM - 8:00 PM',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(labelText: 'Room / Lab'),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickStartDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                  ),
                  child: Text(
                    _startDate == null
                        ? 'Select start date'
                        : DateFormat('dd MMM yyyy').format(_startDate!),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isSaving ? null : _create,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Batch'),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}