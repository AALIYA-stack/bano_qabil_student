import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../models/course_module_model.dart';
import '../../../../models/module_progress_model.dart';
import '../../../../services/module_service.dart';

class CourseModulesScreen
    extends StatefulWidget {
  final String courseId;

  const CourseModulesScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseModulesScreen> createState() =>
      _CourseModulesScreenState();
}

class _CourseModulesScreenState
    extends State<CourseModulesScreen> {
  bool _isLoading = true;
  String? _error;

  List<CourseModuleModel> _modules = [];
  List<ModuleProgressModel> _progress = [];

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        ModuleService.instance
            .getCourseModules(
          widget.courseId,
        ),
        ModuleService.instance
            .getMyModuleProgress(
          widget.courseId,
        ),
      ]);

      if (!mounted) return;

      setState(() {
        _modules =
        results[0] as List<CourseModuleModel>;

        _progress =
        results[1]
        as List<ModuleProgressModel>;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        );

        _isLoading = false;
      });
    }
  }

  bool _isCompleted(
      String moduleId,
      ) {
    return _progress.any(
          (item) =>
      item.moduleId == moduleId &&
          item.completed,
    );
  }

  Future<void> _toggleModule(
      CourseModuleModel module,
      ) async {
    final completed =
    _isCompleted(module.id);

    try {
      if (completed) {
        await ModuleService.instance
            .markModuleIncomplete(
          moduleId: module.id,
        );
      } else {
        await ModuleService.instance
            .markModuleCompleted(
          moduleId: module.id,
          courseId: widget.courseId,
        );
      }

      await _loadModules();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not update module: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Course Modules',
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadModules,
                child: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_modules.isEmpty) {
      return const Center(
        child: Text(
          'No course modules available.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadModules,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _modules.length,
        itemBuilder: (context, index) {
          final module = _modules[index];
          final completed =
          _isCompleted(module.id);

          return FadeSlideAnimation(
            delay: Duration(
              milliseconds: index * 80,
            ),
            child: _ModuleTile(
              module: module,
              completed: completed,
              onTap: () =>
                  _toggleModule(module),
            ),
          );
        },
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final CourseModuleModel module;
  final bool completed;
  final VoidCallback onTap;

  const _ModuleTile({
    required this.module,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: completed
              ? AppColors.success
              : AppColors.border,
        ),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: completed
              ? AppColors.success
              : AppColors.accentLight,
          child: Icon(
            completed
                ? Icons.check_rounded
                : Icons.play_arrow_rounded,
            color: completed
                ? Colors.white
                : AppColors.accent,
          ),
        ),
        title: Text(
          '${module.order}. ${module.title}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding:
          const EdgeInsets.only(top: 5),
          child: Text(
            module.description,
          ),
        ),
        trailing: Switch(
          value: completed,
          onChanged: (_) => onTap(),
        ),

      ),
    );

  }
}