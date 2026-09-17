import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../shared/profile/screen/profile_screen.dart';
import 'applications/screen/applications_inbox_screen.dart';
import 'batches/screen/batch_management_screen.dart';
import 'home/coordinator_home_screen.dart';

/// Coordinator's bottom-nav shell, mirroring StudentShell's structure:
/// an IndexedStack of tab screens plus a NavigationBar. Notices and
/// the report live one tap deeper from Home's quick actions, matching
/// the "13. Notifications + profile + coordinator report" single
/// screen budget in the brief while keeping each piece easy to find.
class CoordinatorShell extends StatefulWidget {
  const CoordinatorShell({super.key});

  @override
  State<CoordinatorShell> createState() => _CoordinatorShellState();
}

class _CoordinatorShellState extends State<CoordinatorShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CoordinatorHomeScreen(),
    ApplicationsInboxScreen(),
    BatchManagementScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accentLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox_rounded),
            label: 'Applications',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded),
            label: 'Batches',
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
}