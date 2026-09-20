import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/animations/fade_slide_animation.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../models/application_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/coordinator_service.dart';
import '../applications/screen/applications_inbox_screen.dart';
import '../batches/screen/batch_management_screen.dart';
import '../../report/screen/coordinator_report_screen.dart';
import '../notices/screen/post_notice_screen.dart';

/// Coordinator's home tab: a welcome header, live pending-applications
/// count, and quick actions into the other coordinator screens.
/// Mirrors the layout convention used by InstructorHomeScreen /
/// StudentHomeScreen (gradient welcome card + quick action grid).
class CoordinatorHomeScreen extends StatefulWidget {
  const CoordinatorHomeScreen({super.key});

  @override
  State<CoordinatorHomeScreen> createState() =>
      _CoordinatorHomeScreenState();
}

class _CoordinatorHomeScreenState
    extends State<CoordinatorHomeScreen> {
  String _coordinatorName = 'Coordinator';
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final UserModel? profile =
          await AuthService.instance.getCurrentUserProfile();

      if (!mounted || profile == null) return;

      setState(() {
        _coordinatorName =
            profile.name.trim().isEmpty ? 'Coordinator' : profile.name;
      });
    } catch (_) {
      // Keep the default name if the profile cannot be loaded.
    }
  }

  Future<void> _seedDemoData() async {
    if (_isSeeding) return;

    setState(() {
      _isSeeding = true;
    });

    try {
      await CoordinatorService.instance.seedDemoData();

      if (!mounted) return;

      AppSnackbar.success(
        context,
        'Demo courses, campuses, batches and applications seeded.',
      );
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSeeding = false;
        });
      }
    }
  }

  void _open(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Coordinator Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(
          AppDimensions.paddingMedium,
        ),
        children: [
          FadeSlideAnimation(
            child: _buildWelcomeCard(),
          ),

          const SizedBox(height: AppDimensions.spacingLarge),

          const Text(
            'New Applications',
            style: AppTextStyles.heading3,
          ),

          const SizedBox(height: AppDimensions.spacingMedium),

          FadeSlideAnimation(
            delay: const Duration(milliseconds: 80),
            child: _buildPendingApplicationsCard(),
          ),

          const SizedBox(height: AppDimensions.spacingLarge),

          const Text(
            'Quick Actions',
            style: AppTextStyles.heading3,
          ),

          const SizedBox(height: AppDimensions.spacingMedium),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimensions.spacingSmall,
            crossAxisSpacing: AppDimensions.spacingSmall,
            childAspectRatio: 1.3,
            children: [
              _ActionCard(
                icon: Icons.inbox_outlined,
                title: 'Applications',
                subtitle: 'Review & decide',
                onTap: () =>
                    _open(const ApplicationsInboxScreen()),
              ),
              _ActionCard(
                icon: Icons.groups_outlined,
                title: 'Batches',
                subtitle: 'Create, close, assign',
                onTap: () =>
                    _open(const BatchManagementScreen()),
              ),
              _ActionCard(
                icon: Icons.campaign_outlined,
                title: 'Post Notice',
                subtitle: 'Campus-wide announcement',
                onTap: () => _open(const PostNoticeScreen()),
              ),
              _ActionCard(
                icon: Icons.insights_outlined,
                title: 'Report',
                subtitle: 'Monthly numbers',
                onTap: () =>
                    _open(const CoordinatorReportScreen()),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingLarge),

          FadeSlideAnimation(
            delay: const Duration(milliseconds: 160),
            child: OutlinedButton.icon(
              onPressed: _isSeeding ? null : _seedDemoData,
              icon: _isSeeding
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(
                _isSeeding
                    ? 'Seeding demo data...'
                    : 'Seed Demo Data',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.banoQabilGreen,
            AppColors.banoQabilTeal,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXLarge,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.avatarLarge,
            height: AppDimensions.avatarLarge,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: AppDimensions.iconLarge,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _coordinatorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Run applications, batches and notices',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApplicationsCard() {
    return StreamBuilder<List<ApplicationModel>>(
      stream: CoordinatorService.instance
          .applicationsStream(statusFilter: 'submitted'),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting;

        return InkWell(
          onTap: () => _open(const ApplicationsInboxScreen()),
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLarge,
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusLarge,
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoading
                            ? 'Loading...'
                            : '$count awaiting review',
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Newly submitted applications',
                        style: AppTextStyles.cardSubtitle,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusLarge,
      ),
      child: Container(
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
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accent),
            ),
            const Spacer(),
            Text(title, style: AppTextStyles.cardTitle),
            const SizedBox(height: 3),
            Text(subtitle, style: AppTextStyles.cardSubtitle),
          ],
        ),
      ),
    );
  }
}