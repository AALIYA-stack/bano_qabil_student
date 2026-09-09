import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/auth_service.dart';
import '../../../models/user_model.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';

class InstructorHomeScreen extends StatefulWidget {
  const InstructorHomeScreen({super.key});

  @override
  State<InstructorHomeScreen> createState() => _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends State<InstructorHomeScreen> {
  int _selectedIndex = 0;

  String _instructorName = 'Instructor';

  @override
  void initState() {
    super.initState();
    _loadInstructorProfile();
  }

Future<void> _loadInstructorProfile() async {
  try {
    final UserModel? profile =
        await AuthService.instance.getCurrentUserProfile();

    if (!mounted || profile == null) {
      return;
    }

    setState(() {
      _instructorName = profile.name.trim();
    });
  } catch (e) {
    // Keep the default name if the profile cannot be loaded.
  }
}

  Stream<QuerySnapshot<Map<String, dynamic>>> _getTodayClasses() {
    final user = AuthService.instance.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('batches')
        .where('instructorId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active')
        .snapshots();
  }

  final List<Map<String, dynamic>> _pendingSubmissions = [
    {
      'student': 'Ali Raza',
      'assignment': 'Flutter UI Assignment',
      'batch': 'Flutter Batch 01',
    },
    {
      'student': 'Sara Ahmed',
      'assignment': 'Firebase Quiz',
      'batch': 'Flutter Batch 01',
    },
  ];

  final List<Map<String, dynamic>> _behindStudents = [
    {
      'student': 'Ahmed Khan',
      'batch': 'Flutter Batch 01',
      'progress': '45%',
    },
    {
      'student': 'Fatima Noor',
      'batch': 'Flutter Batch 01',
      'progress': '52%',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Dashboard'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          _buildPlaceholder('Classes'),
          _buildPlaceholder('Assignments'),
          _buildPlaceholder('Profile'),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded),
            label: 'Classes',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'Work',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          _buildWelcomeCard(),

          const SizedBox(height: AppDimensions.spacingLarge),

          _buildSectionHeader(
            title: "Today's Classes",
            actionText: 'View All',
            onActionPressed: () {},
          ),

          const SizedBox(height: AppDimensions.spacingMedium),

          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _getTodayClasses(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingLarge,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      AppDimensions.paddingMedium,
                    ),
                    child: Text(
                      'Unable to load classes.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                );
              }

              final batches = snapshot.data?.docs ?? [];

              if (batches.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      AppDimensions.paddingLarge,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.class_outlined,
                          size: AppDimensions.iconXLarge,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(
                          height: AppDimensions.spacingSmall,
                        ),
                        Text(
                          'No classes found for today.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: batches.map((doc) {
                  final data = doc.data();

                  final studentIds =
                      (data['studentIds'] as List<dynamic>?) ?? [];

                  final courseId =
                      (data['courseId'] ?? '').toString();

                  return FutureBuilder<
                      DocumentSnapshot<Map<String, dynamic>>>(
                    future: courseId.isEmpty
                        ? null
                        : FirebaseFirestore.instance
                            .collection('courses')
                            .doc(courseId)
                            .get(),
                    builder: (context, courseSnapshot) {
                      String courseName = 'Course';

                      if (courseSnapshot.hasData &&
                          courseSnapshot.data!.exists) {
                        final courseData =
                            courseSnapshot.data!.data();

                        courseName =
                            (courseData?['name'] ?? 'Course')
                                .toString();
                      }

                      return _buildClassCard({
                        'batch': (data['name'] ??
                                'Unnamed Batch')
                            .toString(),
                        'course': courseName,
                        'time': 'Schedule not available',
                        'students': studentIds.length,
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: AppDimensions.spacingLarge),

          _buildSectionHeader(
            title: 'Quick Actions',
            actionText: '',
            onActionPressed: () {},
          ),

          const SizedBox(height: AppDimensions.spacingMedium),

          _buildQuickActions(),

          const SizedBox(height: AppDimensions.spacingLarge),

          _buildSectionHeader(
            title: 'Pending Submissions',
            actionText: 'View All',
            onActionPressed: () {},
          ),

          const SizedBox(height: AppDimensions.spacingMedium),

          ..._pendingSubmissions.map(_buildSubmissionCard),

          const SizedBox(height: AppDimensions.spacingLarge),

          _buildSectionHeader(
            title: 'Students Behind on Work',
            actionText: 'View Progress',
            onActionPressed: () {},
          ),

          const SizedBox(height: AppDimensions.spacingMedium),

          ..._behindStudents.map(_buildProgressCard),

          const SizedBox(height: AppDimensions.spacingLarge),
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
              Icons.school_rounded,
              color: Colors.white,
              size: AppDimensions.iconLarge,
            ),
          ),
          const SizedBox(
            width: AppDimensions.spacingMedium,
          ),
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
                  _instructorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage your classes and students',
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

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onActionPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.heading3,
        ),
        if (actionText.isNotEmpty)
          TextButton(
            onPressed: onActionPressed,
            child: Text(actionText),
          ),
      ],
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classData) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.paddingMedium,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMedium,
                ),
              ),
              child: const Icon(
                Icons.class_rounded,
                color: AppColors.banoQabilGreen,
              ),
            ),
            const SizedBox(
              width: AppDimensions.spacingMedium,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    classData['batch'],
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    classData['course'],
                    style: AppTextStyles.cardSubtitle,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: AppDimensions.iconSmall,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        classData['time'],
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.people_outline_rounded,
                        size: AppDimensions.iconSmall,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${classData['students']} students',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
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
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: AppDimensions.spacingSmall,
      mainAxisSpacing: AppDimensions.spacingSmall,
      childAspectRatio: 0.95,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildActionCard(
          icon: Icons.fact_check_outlined,
          title: 'Attendance',
          onTap: () {},
        ),
        _buildActionCard(
          icon: Icons.add_task_rounded,
          title: 'Assignment',
          onTap: () {},
        ),
        _buildActionCard(
          icon: Icons.campaign_outlined,
          title: 'Notice',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusLarge,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(
            AppDimensions.paddingSmall,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.banoQabilGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(
    Map<String, dynamic> submission,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingSmall,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.accentLight,
          child: const Icon(
            Icons.assignment_outlined,
            color: AppColors.banoQabilGreen,
          ),
        ),
        title: Text(
          submission['student'],
          style: AppTextStyles.cardTitle,
        ),
        subtitle: Text(
          '${submission['assignment']} • ${submission['batch']}',
          style: AppTextStyles.cardSubtitle,
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    Map<String, dynamic> student,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.paddingMedium,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.errorBackground,
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.error,
              ),
            ),
            const SizedBox(
              width: AppDimensions.spacingMedium,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    student['student'],
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    student['batch'],
                    style: AppTextStyles.cardSubtitle,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: double.parse(
                          student['progress']
                              .replaceAll('%', ''),
                        ) /
                        100,
                    minHeight: 6,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: AppDimensions.spacingMedium,
            ),
            Text(
              student['progress'],
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Text(
        title,
        style: AppTextStyles.heading2,
      ),
    );
  }
}