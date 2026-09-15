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

  final _fullNameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _educationController = TextEditingController();
  final _cityController = TextEditingController();
  final _whyJoinController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _cnicController.dispose();
    _educationController.dispose();
    _cityController.dispose();
    _whyJoinController.dispose();

    super.dispose();
  }

  Future<void> _submitApplication() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ApplicationService.instance.submitApplication(
        fullName: _fullNameController.text.trim(),
        cnic: _cnicController.text.trim(),
        education: _educationController.text.trim(),
        city: _cityController.text.trim(),
        courseId: widget.course.id,
        courseName: widget.course.name,
        campusId: widget.campus.id,
        campusName: widget.campus.name,
        batchId: widget.batch.id,
        whyJoin: _whyJoinController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Application submitted successfully!',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      String message = 'Unable to submit application.';

      final error = e.toString();

      if (error.contains(
        'already applied',
      )) {
        message =
        'You have already applied for this batch.';
      } else if (error.contains(
        'permission-denied',
      )) {
        message =
        'You do not have permission to submit this application.';
      } else if (error.contains(
        'not logged in',
      )) {
        message =
        'Please login before submitting an application.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
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

  String? _requiredValidator(
      String? value,
      String fieldName,
      ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  String? _cnicValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CNIC is required.';
    }

    final cnic = value.trim();

    final cnicRegex = RegExp(
      r'^\d{5}-\d{7}-\d$',
    );

    if (!cnicRegex.hasMatch(cnic)) {
      return 'Use format: 12345-1234567-1';
    }

    return null;
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
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            16,
          ),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed:
              _isSubmitting ? null : _submitApplication,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                AppColors.textLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : const Text(
                'Submit Application',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            100,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              FadeSlideAnimation(
                child: _SelectedCourseCard(
                  course: widget.course,
                  campus: widget.campus,
                  batch: widget.batch,
                ),
              ),

              const SizedBox(height: 28),

              const FadeSlideAnimation(
                delay: Duration(milliseconds: 100),
                child: Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              FadeSlideAnimation(
                delay: const Duration(milliseconds: 150),
                child: _AppTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: Icons.person_outline_rounded,
                  textInputAction:
                  TextInputAction.next,
                  validator: (value) =>
                      _requiredValidator(
                        value,
                        'Full name',
                      ),
                ),
              ),

              const SizedBox(height: 14),

              FadeSlideAnimation(
                delay: const Duration(milliseconds: 200),
                child: _AppTextField(
                  controller: _cnicController,
                  label: 'CNIC',
                  hint: '12345-1234567-1',
                  icon: Icons.badge_outlined,
                  keyboardType:
                  TextInputType.number,
                  textInputAction:
                  TextInputAction.next,
                  validator: _cnicValidator,
                ),
              ),

              const SizedBox(height: 14),

              FadeSlideAnimation(
                delay: const Duration(milliseconds: 250),
                child: _AppTextField(
                  controller: _educationController,
                  label: 'Education',
                  hint:
                  'e.g. Intermediate, Bachelor',
                  icon: Icons.school_outlined,
                  textInputAction:
                  TextInputAction.next,
                  validator: (value) =>
                      _requiredValidator(
                        value,
                        'Education',
                      ),
                ),
              ),

              const SizedBox(height: 14),

              FadeSlideAnimation(
                delay: const Duration(milliseconds: 300),
                child: _AppTextField(
                  controller: _cityController,
                  label: 'City',
                  hint: 'Enter your city',
                  icon: Icons.location_city_outlined,
                  textInputAction:
                  TextInputAction.next,
                  validator: (value) =>
                      _requiredValidator(
                        value,
                        'City',
                      ),
                ),
              ),

              const SizedBox(height: 28),

              const FadeSlideAnimation(
                delay: Duration(milliseconds: 350),
                child: Text(
                  'Why do you want to join?',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              FadeSlideAnimation(
                delay: const Duration(milliseconds: 400),
                child: _AppTextField(
                  controller: _whyJoinController,
                  label: 'Your Answer',
                  hint:
                  'Tell us why you want to join this course...',
                  icon: Icons.edit_note_rounded,
                  maxLines: 5,
                  textInputAction:
                  TextInputAction.newline,
                  validator: (value) =>
                      _requiredValidator(
                        value,
                        'Answer',
                      ),
                ),
              ),

              const SizedBox(height: 20),

              const FadeSlideAnimation(
                delay: Duration(milliseconds: 450),
                child: _InformationCard(),
              ),
            ],
          ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'You are applying for',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            course.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          _SummaryRow(
            icon: Icons.location_on_outlined,
            text:
            '${campus.name}, ${campus.city}',
          ),

          const SizedBox(height: 9),

          _SummaryRow(
            icon: Icons.calendar_month_outlined,
            text:
            '${batch.classDay} • ${batch.classTime}',
          ),

          const SizedBox(height: 9),

          _SummaryRow(
            icon: Icons.meeting_room_outlined,
            text: batch.room.isEmpty
                ? 'Room not assigned'
                : batch.room,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SummaryRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: Colors.white70,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  const _AppTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: 12,
            right: 8,
          ),
          child: Icon(icon),
        ),
        prefixIconConstraints:
        const BoxConstraints(
          minWidth: 48,
        ),
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'After submitting your application, '
                  'the campus coordinator will review it. '
                  'You can check your application status '
                  'from the My Application section.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}