import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../models/campus_model.dart';
import '../../../../services/campus_service.dart';
import '../../../../services/coordinator_service.dart';

/// Coordinator's "post a campus-wide notice" form. Audience is either
/// a single campus or every campus (leave unselected). Writes through
/// the same `notices` collection students and instructors already
/// read from (NoticeService / NoticesScreen).
class PostNoticeScreen extends StatefulWidget {
  const PostNoticeScreen({super.key});

  @override
  State<PostNoticeScreen> createState() => _PostNoticeScreenState();
}

class _PostNoticeScreenState extends State<PostNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _type = 'general';
  String _priority = 'normal';
  CampusModel? _selectedCampus;

  List<CampusModel> _campuses = [];
  bool _isLoadingCampuses = true;
  bool _isPosting = false;

  final List<String> _types = const [
    'general',
    'class',
    'assignment',
    'holiday',
    'important',
  ];

  final List<String> _priorities = const ['low', 'normal', 'high'];

  @override
  void initState() {
    super.initState();
    _loadCampuses();
  }

  Future<void> _loadCampuses() async {
    try {
      final campuses = await CampusService.instance.getActiveCampuses();

      if (!mounted) return;

      setState(() {
        _campuses = campuses;
        _isLoadingCampuses = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingCampuses = false;
      });
    }
  }

  Future<void> _post() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPosting = true;
    });

    try {
      await CoordinatorService.instance.postNotice(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _type,
        priority: _priority,
        campusId: _selectedCampus?.id,
      );

      if (!mounted) return;

      AppSnackbar.success(context, 'Notice posted.');
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
      appBar: AppBar(title: const Text('Post Notice')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Lab shifted to Room 2',
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty)
                      ? 'Title is required.'
                      : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty)
                      ? 'Description is required.'
                      : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: _types
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type[0].toUpperCase() + type.substring(1)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: _priorities
                  .map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(
                        priority[0].toUpperCase() + priority.substring(1),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _priority = value);
              },
            ),
            const SizedBox(height: 16),
            if (_isLoadingCampuses)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              DropdownButtonFormField<CampusModel?>(
                initialValue: _selectedCampus,
                decoration: const InputDecoration(
                  labelText: 'Audience',
                  hintText: 'All campuses',
                ),
                items: [
                  const DropdownMenuItem<CampusModel?>(
                    value: null,
                    child: Text('All campuses'),
                  ),
                  ..._campuses.map(
                    (campus) => DropdownMenuItem<CampusModel?>(
                      value: campus,
                      child: Text('${campus.name} (${campus.city})'),
                    ),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _selectedCampus = value),
              ),
            const SizedBox(height: 24),
            SizedBox(
              height: AppDimensions.buttonHeight,
              child: ElevatedButton(
                onPressed: _isPosting ? null : _post,
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