
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../models/batch_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/batch_service.dart';
import '../../../services/notice_service.dart';

class InstructorNoticeScreen extends StatefulWidget {
  const InstructorNoticeScreen({super.key});

  @override
  State<InstructorNoticeScreen> createState() =>
      _InstructorNoticeScreenState();
}

class _InstructorNoticeScreenState
    extends State<InstructorNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _type = 'general';
  String _priority = 'normal';

  List<BatchModel> _batches = [];
  BatchModel? _selectedBatch;

  bool _isLoadingBatches = true;
  bool _isPosting = false;

  final List<String> _types = const [
    'general',
    'class',
    'assignment',
    'holiday',
    'important',
  ];

  final List<String> _priorities = const [
    'low',
    'normal',
    'high',
  ];

  @override
  void initState() {
    super.initState();
    _loadInstructorBatches();
  }

  Future<void> _loadInstructorBatches() async {
    try {
      final user = AuthService.instance.currentUser;

      if (user == null) {
        throw Exception('Instructor is not logged in.');
      }

      final batches =
          await BatchService.instance.getBatchesForInstructor(
        user.uid,
      );

      if (!mounted) return;

      setState(() {
        _batches = batches;
        _isLoadingBatches = false;

        if (batches.length == 1) {
          _selectedBatch = batches.first;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingBatches = false;
      });

      AppSnackbar.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _postNotice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedBatch = _selectedBatch;

    if (selectedBatch == null) {
      AppSnackbar.error(
        context,
        'Please select a batch.',
      );
      return;
    }

    final user = AuthService.instance.currentUser;

    if (user == null) {
      AppSnackbar.error(
        context,
        'Instructor is not logged in.',
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      await NoticeService.instance.postInstructorNotice(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _type,
        priority: _priority,
        courseId: selectedBatch.courseId,
        batchId: selectedBatch.id,
        campusId: selectedBatch.campusId,
        instructorId: user.uid,
      );

      if (!mounted) return;

      AppSnackbar.success(
        context,
        'Notice posted successfully.',
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Post Notice'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(
            AppDimensions.paddingMedium,
          ),
          children: [
            const Text(
              'Create a Notice',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Post an announcement for one of your assigned batches.',
            ),
            const SizedBox(height: 24),

            // ---------------------------------------------------
            // TITLE
            // ---------------------------------------------------

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Class timing changed',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // ---------------------------------------------------
            // DESCRIPTION
            // ---------------------------------------------------

            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Write your notice here...',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // ---------------------------------------------------
            // TYPE
            // ---------------------------------------------------

            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Type',
              ),
              items: _types.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type[0].toUpperCase() +
                        type.substring(1),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _type = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // ---------------------------------------------------
            // PRIORITY
            // ---------------------------------------------------

            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
              ),
              items: _priorities.map((priority) {
                return DropdownMenuItem<String>(
                  value: priority,
                  child: Text(
                    priority[0].toUpperCase() +
                        priority.substring(1),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _priority = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // ---------------------------------------------------
            // BATCH
            // ---------------------------------------------------

            if (_isLoadingBatches)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_batches.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: const Text(
                  'No batches are assigned to you.',
                ),
              )
            else
              DropdownButtonFormField<BatchModel>(
                initialValue: _selectedBatch,
                decoration: const InputDecoration(
                  labelText: 'Batch',
                  hintText: 'Select a batch',
                ),
                items: _batches.map((batch) {
                  return DropdownMenuItem<BatchModel>(
                    value: batch,
                    child: Text(
                      '${batch.id} • ${batch.classDay}',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBatch = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a batch.';
                  }

                  return null;
                },
              ),

            const SizedBox(height: 24),

            // ---------------------------------------------------
            // POST BUTTON
            // ---------------------------------------------------

            SizedBox(
              height: AppDimensions.buttonHeight,
              child: ElevatedButton(
                onPressed:
                    _isPosting || _batches.isEmpty
                        ? null
                        : _postNotice,
                child: _isPosting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Post Notice'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

