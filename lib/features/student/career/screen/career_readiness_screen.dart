import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../models/career_progress_model.dart';
import '../../../../services/career_service.dart';
import '../widgets/career_checklist_tile.dart';
import '../widgets/career_progress_card.dart';

class CareerReadinessScreen
    extends StatefulWidget {
  const CareerReadinessScreen({
    super.key,
  });

  @override
  State<CareerReadinessScreen> createState() =>
      _CareerReadinessScreenState();
}

class _CareerReadinessScreenState
    extends State<CareerReadinessScreen> {
  CareerProgressModel? _progress;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCareerProgress();
  }

  Future<void> _loadCareerProgress() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      var progress =
      await CareerService.instance
          .getMyCareerProgress();

      progress ??= const CareerProgressModel(
        studentId: '',
        cvReady: false,
        githubReady: false,
        projectsCompleted: 0,
        mockInterviewDone: false,
        jobsApplied: 0,
        updatedAt: null,
      );

      if (!mounted) return;

      setState(() {
        _progress = progress;
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

  Future<void> _update({
    required String field,
    required dynamic value,
  }) async {
    try {
      await CareerService.instance
          .updateSingleItem(
        field: field,
        value: value,
      );

      await _loadCareerProgress();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not update progress: $e',
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
          'Career Readiness',
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(),
      );
    }

    if (_error != null) {
      return Center(
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
              onPressed: _loadCareerProgress,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final progress = _progress;

    if (progress == null) {
      return const Center(
        child: Text(
          'Career progress unavailable.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCareerProgress,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          FadeSlideAnimation(
            child: CareerProgressCard(
              progress: progress,
            ),
          ),

          const SizedBox(height: 22),

          const FadeSlideAnimation(
            delay: Duration(milliseconds: 80),
            child: Text(
              'Job Readiness Checklist',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          FadeSlideAnimation(
            delay:
            const Duration(milliseconds: 120),
            child: CareerChecklistTile(
              title: 'Create Your CV',
              description:
              'Prepare a professional and updated CV.',
              icon: Icons.description_outlined,
              completed: progress.cvReady,
              onChanged: () {
                _update(
                  field: 'cvReady',
                  value: !progress.cvReady,
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          FadeSlideAnimation(
            delay:
            const Duration(milliseconds: 160),
            child: CareerChecklistTile(
              title: 'Build GitHub Profile',
              description:
              'Upload your projects and keep your GitHub active.',
              icon: Icons.code_rounded,
              completed:
              progress.githubReady,
              onChanged: () {
                _update(
                  field: 'githubReady',
                  value:
                  !progress.githubReady,
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          FadeSlideAnimation(
            delay:
            const Duration(milliseconds: 200),
            child: _ProjectsTile(
              projects:
              progress.projectsCompleted,
              onChanged: (value) {
                _update(
                  field: 'projectsCompleted',
                  value: value,
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          FadeSlideAnimation(
            delay:
            const Duration(milliseconds: 240),
            child: CareerChecklistTile(
              title: 'Complete Mock Interview',
              description:
              'Practice your communication and interview skills.',
              icon:
              Icons.record_voice_over_outlined,
              completed:
              progress.mockInterviewDone,
              onChanged: () {
                _update(
                  field: 'mockInterviewDone',
                  value:
                  !progress.mockInterviewDone,
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          FadeSlideAnimation(
            delay:
            const Duration(milliseconds: 280),
            child: _JobsAppliedTile(
              jobsApplied:
              progress.jobsApplied,
              onChanged: (value) {
                _update(
                  field: 'jobsApplied',
                  value: value,
                );
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
class _ProjectsTile extends StatelessWidget {
  final int projects;
  final ValueChanged<int> onChanged;

  const _ProjectsTile({
    required this.projects,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.folder_copy_outlined,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Build 3 Projects',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    color:
                    AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Create portfolio projects to demonstrate your skills.',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          DropdownButton<int>(
            value: projects.clamp(0, 3),
            items: List.generate(
              4,
                  (index) {
                return DropdownMenuItem(
                  value: index,
                  child: Text('$index/3'),
                );
              },
            ),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
class _JobsAppliedTile
    extends StatelessWidget {
  final int jobsApplied;
  final ValueChanged<int> onChanged;

  const _JobsAppliedTile({
    required this.jobsApplied,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.work_outline_rounded,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Apply for Jobs',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    color:
                    AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Start applying for relevant opportunities.',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              onChanged(
                jobsApplied + 1,
              );
            },
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.primary,
            ),
          ),

          Text(
            '$jobsApplied',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}