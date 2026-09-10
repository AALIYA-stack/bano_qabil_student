import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../models/assignment_model.dart';
import '../../../models/batch_model.dart';
import '../../../services/assignment_service.dart';
import '../../../services/batch_service.dart';

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  State<CreateAssignmentScreen> createState() =>
      _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState
    extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _marksController = TextEditingController();

  BatchModel? _selectedBatch;
  DateTime? _dueDate;

  List<BatchModel> _batches = [];

  bool _isLoadingBatches = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInstructorBatches();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  Future<void> _loadInstructorBatches() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _isLoadingBatches = false;
        });

        _showMessage(
          'Please log in again.',
          isError: true,
        );

        return;
      }

      final batches =
          await BatchService.instance.getBatchesForInstructor(
        user.uid,
      );

      if (!mounted) return;

      setState(() {
        _batches = batches;
        _isLoadingBatches = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingBatches = false;
      });

      _showMessage(
        'Unable to load your batches.',
        isError: true,
      );
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _dueDate != null
          ? TimeOfDay.fromDateTime(_dueDate!)
          : TimeOfDay.now(),
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      _dueDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  Future<void> _createAssignment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBatch == null) {
      _showMessage(
        'Please select a batch.',
        isError: true,
      );
      return;
    }

    if (_dueDate == null) {
      _showMessage(
        'Please select a due date and time.',
        isError: true,
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please log in again.',
        isError: true,
      );
      return;
    }

    final totalMarks =
        int.tryParse(_marksController.text.trim());

    if (totalMarks == null || totalMarks <= 0) {
      _showMessage(
        'Please enter valid total marks.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final assignment = AssignmentModel(
        id: '',
        batchId: _selectedBatch!.id,
        courseId: _selectedBatch!.courseId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        instructions: _instructionsController.text.trim(),
        dueDate: _dueDate,
        totalMarks: totalMarks,
        createdBy: user.uid,
        createdAt: null,
        isQuiz: false,
      );

      await AssignmentService.instance.createAssignment(
        assignment,
      );

      if (!mounted) return;

      await _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 55,
          ),
          title: const Text(
            'Assignment Created',
          ),
          content: const Text(
            'The assignment has been successfully created and saved.',
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Assignment'),
      ),
      body: _isLoadingBatches
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _batches.isEmpty
              ? _buildNoBatchesState()
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(
                      AppDimensions.paddingMedium,
                    ),
                    children: [
                      _buildBatchField(),

                      const SizedBox(
                        height: AppDimensions.spacingMedium,
                      ),

                      _buildTextField(
                        controller: _titleController,
                        label: 'Assignment Title',
                        hint: 'Enter assignment title',
                        icon: Icons.title_rounded,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter an assignment title.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: AppDimensions.spacingMedium,
                      ),

                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Enter assignment description',
                        icon: Icons.description_outlined,
                        maxLines: 5,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter a description.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: AppDimensions.spacingMedium,
                      ),

                      _buildTextField(
                        controller: _instructionsController,
                        label: 'Instructions',
                        hint: 'Enter instructions for students',
                        icon: Icons.rule_folder_outlined,
                        maxLines: 5,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter instructions.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: AppDimensions.spacingMedium,
                      ),

                      _buildTextField(
                        controller: _marksController,
                        label: 'Total Marks',
                        hint: 'e.g. 100',
                        icon: Icons.stars_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final marks =
                              int.tryParse(
                            value?.trim() ?? '',
                          );

                          if (marks == null ||
                              marks <= 0) {
                            return 'Enter valid total marks.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: AppDimensions.spacingMedium,
                      ),

                      _buildDueDateField(),

                      const SizedBox(
                        height: AppDimensions.spacingLarge,
                      ),

                      SizedBox(
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isSaving
                                  ? null
                                  : _createAssignment,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 19,
                                  height: 19,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_task_rounded,
                                ),
                          label: Text(
                            _isSaving
                                ? 'Creating...'
                                : 'Create Assignment',
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'The assignment will be saved for the selected batch.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildBatchField() {
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
      ),
      child: DropdownButtonFormField<BatchModel>(
        initialValue: _selectedBatch,
        decoration: const InputDecoration(
          labelText: 'Select Batch',
          prefixIcon: Icon(
            Icons.groups_outlined,
          ),
        ),
        items: _batches.map((batch) {
          return DropdownMenuItem<BatchModel>(
            value: batch,
            child: Text(
              batch.id,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: _isSaving
            ? null
            : (batch) {
                setState(() {
                  _selectedBatch = batch;
                });
              },
        validator: (value) {
          if (value == null) {
            return 'Please select a batch.';
          }

          return null;
        },
      ),
    );
  }

  Widget _buildDueDateField() {
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
      ),
      child: InkWell(
        onTap: _isSaving ? null : _pickDueDate,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMedium,
        ),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Due Date & Time',
            prefixIcon: Icon(
              Icons.schedule_outlined,
            ),
          ),
          child: Text(
            _dueDate == null
                ? 'Select due date and time'
                : DateFormat(
                    'dd MMM yyyy, hh:mm a',
                  ).format(_dueDate!),
            style: _dueDate == null
                ? AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textLight,
                  )
                : AppTextStyles.bodyMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
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
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }

  Widget _buildNoBatchesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.paddingLarge,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.groups_outlined,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'No batches found',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'You do not have any batches available for creating an assignment.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _loadInstructorBatches,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

