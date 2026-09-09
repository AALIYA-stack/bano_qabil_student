import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../models/batch_model.dart';
import '../../../../models/campus_model.dart';
import '../../../../models/course_model.dart';
import '../../../../services/application_service.dart';

class ApplicationFormScreen extends StatefulWidget {
  final CourseModel course;
  final BatchModel batch;
  final CampusModel campus;

  const ApplicationFormScreen({
    super.key,
    required this.course,
    required this.batch,
    required this.campus,
  });

  @override
  State<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState
    extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _educationController = TextEditingController();
  final _cityController = TextEditingController();
  final _whyJoinController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cnicController.dispose();
    _educationController.dispose();
    _cityController.dispose();
    _whyJoinController.dispose();
    super.dispose();
  }

  String? _validateRequired(
      String? value,
      String label,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return '$label is required.';
    }

    return null;
  }

  String? _validateCnic(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'CNIC is required.';
    }

    final cnic = value.trim();

    final cnicRegex =
    RegExp(r'^\d{5}-\d{7}-\d$');

    if (!cnicRegex.hasMatch(cnic)) {
      return 'Use format: 12345-1234567-1';
    }

    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final applicationId =
      await ApplicationService.instance
          .submitApplication(
        fullName: _nameController.text,
        cnic: _cnicController.text,
        education: _educationController.text,
        city: _cityController.text,
        courseId: widget.course.id,
        courseName: widget.course.name,
        campusId: widget.campus.id,
        campusName: widget.campus.name,
        batchId: widget.batch.id,
        whyJoin: _whyJoinController.text,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Application Submitted',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentLight,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 34,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Your Bano Qabil application has been submitted successfully.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Application ID',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  applicationId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Course Application',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed:
            _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(
              'Submit Application',
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            100,
          ),
          children: [
            FadeSlideAnimation(
              child: _SelectedCourseCard(
                course: widget.course,
                campus: widget.campus,
                batch: widget.batch,
              ),
            ),

            const SizedBox(height: 24),

            const FadeSlideAnimation(
              delay: Duration(milliseconds: 100),
              child: _SectionTitle(
                title: 'Personal Information',
                subtitle:
                'Enter your information carefully.',
              ),
            ),

            const SizedBox(height: 14),

            FadeSlideAnimation(
              delay: const Duration(milliseconds: 150),
              child: _InputField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person_outline_rounded,
                validator: (value) =>
                    _validateRequired(
                      value,
                      'Full name',
                    ),
              ),
            ),

            const SizedBox(height: 14),

            FadeSlideAnimation(
              delay: const Duration(milliseconds: 200),
              child: _InputField(
                controller: _cnicController,
                label: 'CNIC',
                hint: '12345-1234567-1',
                icon: Icons.badge_outlined,
                keyboardType:
                TextInputType.number,
                validator: _validateCnic,
              ),
            ),

            const SizedBox(height: 14),

            FadeSlideAnimation(
              delay: const Duration(milliseconds: 250),
              child: _InputField(
                controller: _educationController,
                label: 'Education',
                hint:
                'e.g. Intermediate, BS IT',
                icon: Icons.school_outlined,
                validator: (value) =>
                    _validateRequired(
                      value,
                      'Education',
                    ),
              ),
            ),

            const SizedBox(height: 14),

            FadeSlideAnimation(
              delay: const Duration(milliseconds: 300),
              child: _InputField(
                controller: _cityController,
                label: 'City',
                hint: 'Enter your city',
                icon: Icons.location_city_outlined,
                validator: (value) =>
                    _validateRequired(
                      value,
                      'City',
                    ),
              ),
            ),

            const SizedBox(height: 28),

            const FadeSlideAnimation(
              delay: Duration(milliseconds: 350),
              child: _SectionTitle(
                title: 'Why do you want to join?',
                subtitle:
                'Tell us briefly about your motivation.',
              ),
            ),

            const SizedBox(height: 14),

            FadeSlideAnimation(
              delay: const Duration(milliseconds: 400),
              child: TextFormField(
                controller: _whyJoinController,
                minLines: 5,
                maxLines: 7,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText:
                  'Write your reason for joining this course...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please tell us why you want to join.';
                  }

                  if (value.trim().length < 20) {
                    return 'Please write at least 20 characters.';
                  }

                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedCourseCard extends StatelessWidget {
  final CourseModel course;
  final CampusModel campus;
  final BatchModel batch;

  const _SelectedCourseCard({
    required this.course,
    required this.campus,
    required this.batch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
        border: Border.all(
          color: AppColors.accent.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Batch',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            course.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            campus.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${batch.classDay} • ${batch.classTime} • ${batch.room}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }
}