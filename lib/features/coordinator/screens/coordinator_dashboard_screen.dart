import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../services/auth_service.dart';
import '../../../services/seed_service.dart';
import '../../coordinator/services/coordinator_service.dart';
import 'coordinator_settings_screen.dart';

class CoordinatorDashboardScreen extends StatefulWidget {
  const CoordinatorDashboardScreen({super.key});

  @override
  State<CoordinatorDashboardScreen> createState() =>
      _CoordinatorDashboardScreenState();
}

class _CoordinatorDashboardScreenState
    extends State<CoordinatorDashboardScreen> {
  final CoordinatorService _service = CoordinatorService.instance;

  late Future<Map<String, dynamic>> _reportFuture;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    _reportFuture = _service.getReport();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadReport();
    });

    await _reportFuture;
  }

  Future<void> _seedDemoData() async {
    try {
      await SeedService.instance.seedOnlyStudents();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demo student data seeded successfully.'),
        ),
      );

      setState(() {
        _loadReport();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to seed demo data: $e'),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    await AuthService.instance.logout();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinator Dashboard'),
        actions: [
          // Notifications
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.notifications,
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),

          // Settings
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const CoordinatorSettingsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.settings_outlined,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _reportFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 100),
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Unable to load dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _loadReport();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              );
            }

            final report = snapshot.data ?? {};

            final int students =
            _toInt(report['students']);

            final int instructors =
            _toInt(report['instructors']);

            final int courses =
            _toInt(report['courses']);

            final int campuses =
            _toInt(report['campuses']);

            final int batches =
            _toInt(report['batches']);

            final int applications =
            _toInt(report['applications']);

            return ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(
                AppDimensions.paddingMedium,
              ),
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 20),

                _buildSectionTitle('Overview'),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.45,
                  children: [
                    _buildStatCard(
                      title: 'Students',
                      value: students.toString(),
                      icon: Icons.people_outline,
                    ),
                    _buildStatCard(
                      title: 'Instructors',
                      value: instructors.toString(),
                      icon: Icons.school_outlined,
                    ),
                    _buildStatCard(
                      title: 'Courses',
                      value: courses.toString(),
                      icon: Icons.menu_book_outlined,
                    ),
                    _buildStatCard(
                      title: 'Campuses',
                      value: campuses.toString(),
                      icon: Icons.location_city_outlined,
                    ),
                    _buildStatCard(
                      title: 'Batches',
                      value: batches.toString(),
                      icon: Icons.groups_outlined,
                    ),
                    _buildStatCard(
                      title: 'Applications',
                      value: applications.toString(),
                      icon: Icons.assignment_outlined,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildSectionTitle('Quick Actions'),
                const SizedBox(height: 12),

                _buildActionCard(
                  icon: Icons.assignment_outlined,
                  title: 'Review Applications',
                  subtitle:
                  'Review and manage student applications',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.coordinatorApplications,
                    );
                  },
                ),

                const SizedBox(height: 10),

                _buildActionCard(
                  icon: Icons.groups_outlined,
                  title: 'Manage Batches',
                  subtitle:
                  'Create batches and assign instructors',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.coordinatorBatches,
                    );
                  },
                ),

                const SizedBox(height: 10),

                _buildActionCard(
                  icon: Icons.campaign_outlined,
                  title: 'Post Campus Notice',
                  subtitle:
                  'Send notices to students and instructors',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.coordinatorNotices,
                    );
                  },
                ),

                const SizedBox(height: 10),

                _buildActionCard(
                  icon: Icons.storage_outlined,
                  title: 'Seed Demo Data',
                  subtitle:
                  'Load demo students for testing',
                  onTap: _seedDemoData,
                ),

                const SizedBox(height: 24),

                _buildSectionTitle('Dashboard'),
                const SizedBox(height: 12),

                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.settings_outlined,
                    ),
                    title: const Text(
                      'Settings',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Dark mode, privacy and account settings',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const CoordinatorSettingsScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                _buildSectionTitle('Account'),
                const SizedBox(height: 12),

                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Sign out from coordinator account',
                    ),
                    onTap: _logout,
                  ),
                ),

                const SizedBox(height: 30),

                Center(
                  child: Text(
                    'Firebase Connected',
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.admin_panel_settings_outlined,
                size: 30,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Coordinator',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Manage students, instructors, courses, batches and campus operations.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.heading3,
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
            Text(
              value,
              style: AppTextStyles.heading2,
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: onTap,
      ),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}