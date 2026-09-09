import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../models/assignment_model.dart';
import '../../../../services/submission_service.dart';

class SubmitAssignmentScreen extends StatefulWidget {
  final AssignmentModel assignment;
  final String batchId;

  const SubmitAssignmentScreen({
    super.key,
    required this.assignment,
    required this.batchId,
  });

  @override
  State<SubmitAssignmentScreen> createState() =>
      _SubmitAssignmentScreenState();
}

class _SubmitAssignmentScreenState
    extends State<SubmitAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _answerController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Uint8List? _fileBytes;
  String? _fileName;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _fileBytes = bytes;
        _fileName = image.name;
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to select photo.',
        isError: true,
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_answerController.text.trim().isEmpty &&
        _fileBytes == null) {
      _showMessage(
        'Please write an answer or attach a photo.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final submissionId =
      await SubmissionService.instance
          .submitAssignment(
        assignment: widget.assignment,
        batchId: widget.batchId,
        answerText: _answerController.text,
        fileBytes: _fileBytes,
        fileName: _fileName,
      );

      if (!mounted) return;

      await _showSuccessDialog(
        submissionId,
      );
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
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _showSuccessDialog(
      String submissionId,
      ) async {
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
            'Assignment Submitted',
          ),
          content: Text(
            'Your assignment has been submitted successfully.\n\nSubmission ID:\n$submissionId',
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
        backgroundColor: isError
            ? AppColors.error
            : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dueDate = widget.assignment.dueDate;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Submit Assignment'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(
            AppDimensions.paddingMedium,
          ),
          children: [
            FadeSlideAnimation(
              child: _buildAssignmentHeader(
                dueDate,
              ),
            ),

            const SizedBox(height: 18),

            FadeSlideAnimation(
              delay: const Duration(milliseconds: 100),
              child: _buildAnswerField(),
            ),

            const SizedBox(height: 18),

            FadeSlideAnimation(
              delay: const Duration(milliseconds: 160),
              child: _buildPhotoPicker(),
            ),

            const SizedBox(height: 25),

            FadeSlideAnimation(
              delay: const Duration(milliseconds: 220),
              child: SizedBox(
                height: AppDimensions.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed:
                  _isSubmitting ? null : _submit,
                  icon: _isSubmitting
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
                    Icons.send_rounded,
                  ),
                  label: Text(
                    _isSubmitting
                        ? 'Submitting...'
                        : 'Submit Assignment',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Please review your answer before submitting. Submissions cannot be edited after submission.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentHeader(
      DateTime? dueDate,
      ) {
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
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            widget.assignment.title,
            style: AppTextStyles.heading2,
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.stars_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 7),
              Text(
                '${widget.assignment.totalMarks} marks',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),

          const SizedBox(height: 7),

          Row(
            children: [
              const Icon(
                Icons.schedule_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  dueDate == null
                      ? 'No due date'
                      : 'Due ${DateFormat('dd MMM yyyy, hh:mm a').format(dueDate)}',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerField() {
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
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Your Answer',
                style: AppTextStyles.heading3,
              ),
            ],
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: _answerController,
            maxLines: 8,
            maxLength: 3000,
            textInputAction:
            TextInputAction.newline,
            decoration: const InputDecoration(
              hintText:
              'Write your assignment answer here...',
              alignLabelWithHint: true,
            ),
            validator: (value) {
              final text =
                  value?.trim() ?? '';

              if (_fileBytes == null &&
                  text.isEmpty) {
                return 'Write an answer or attach a photo.';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPicker() {
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
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.attach_file_rounded,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Attachment',
                style: AppTextStyles.heading3,
              ),
            ],
          ),

          const SizedBox(height: 6),

          const Text(
            'Optional: attach a photo of your work.',
            style: AppTextStyles.bodySmall,
          ),

          const SizedBox(height: 14),

          if (_fileBytes != null)
            ClipRRect(
              borderRadius:
              BorderRadius.circular(14),
              child: Image.memory(
                _fileBytes!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          if (_fileBytes != null)
            const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSubmitting
                      ? null
                      : _pickPhoto,
                  icon: const Icon(
                    Icons.photo_library_outlined,
                  ),
                  label: Text(
                    _fileBytes == null
                        ? 'Choose Photo'
                        : 'Change Photo',
                  ),
                ),
              ),

              if (_fileBytes != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                    setState(() {
                      _fileBytes = null;
                      _fileName = null;
                    });
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),

          if (_fileName != null) ...[
            const SizedBox(height: 8),
            Text(
              _fileName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}