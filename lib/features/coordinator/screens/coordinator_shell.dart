import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../services/auth_service.dart';

import 'coordinator_applications_screen.dart';
import 'coordinator_batches_screen.dart';
import 'coordinator_dashboard_screen.dart';
import 'coordinator_notices_screen.dart';
import 'coordinator_report_screen.dart';

class CoordinatorShell extends StatefulWidget {
const CoordinatorShell({
super.key,
});

@override
State<CoordinatorShell> createState() =>
_CoordinatorShellState();
}

class _CoordinatorShellState
extends State<CoordinatorShell> {
// ============================================================
// CURRENT TAB
// ============================================================

int _currentIndex = 0;

bool _isLoadingIndex = true;

// Coordinator ke liye separate saved tab
static const String _selectedTabKey =
'coordinator_selected_tab';

// ============================================================
// COORDINATOR SCREENS
// ============================================================

final List<Widget> _screens = const [
// 0 - Dashboard
CoordinatorDashboardScreen(),

// 1 - Applications
CoordinatorApplicationsScreen(),

// 2 - Batches
CoordinatorBatchesScreen(),

// 3 - Notices
CoordinatorNoticesScreen(),

// 4 - Report
CoordinatorReportScreen(),
];

// ============================================================
// INIT
// ============================================================

@override
void initState() {
super.initState();
_loadSelectedTab();
}

// ============================================================
// LOAD LAST SELECTED TAB
// ============================================================

Future<void> _loadSelectedTab() async {
try {
final prefs =
await SharedPreferences.getInstance();

final savedIndex =
prefs.getInt(_selectedTabKey);

if (!mounted) return;

setState(() {
if (savedIndex != null &&
savedIndex >= 0 &&
savedIndex < _screens.length) {
_currentIndex = savedIndex;
} else {
_currentIndex = 0;
}

_isLoadingIndex = false;
});
} catch (_) {
if (!mounted) return;

setState(() {
_currentIndex = 0;
_isLoadingIndex = false;
});
}
}

// ============================================================
// SAVE SELECTED TAB
// ============================================================

Future<void> _saveSelectedTab(int index) async {
try {
final prefs =
await SharedPreferences.getInstance();

await prefs.setInt(
_selectedTabKey,
index,
);
} catch (_) {
// Storage error ko ignore karenge.
}
}

// ============================================================
// LOGOUT
// ============================================================

Future<void> _logout() async {
final shouldLogout = await showDialog<bool>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text('Logout'),
content: const Text(
'Are you sure you want to logout from the Coordinator Portal?',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext, false);
},
child: const Text('Cancel'),
),
FilledButton(
onPressed: () {
Navigator.pop(dialogContext, true);
},
child: const Text('Logout'),
),
],
);
},
);

if (shouldLogout != true) {
return;
}

try {
await AuthService.instance.logout();

if (!mounted) return;

Navigator.pushNamedAndRemoveUntil(
context,
AppRoutes.login,
(route) => false,
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context)
..hideCurrentSnackBar()
..showSnackBar(
SnackBar(
content: Text(
'Logout failed: ${e.toString().replaceFirst('Exception: ', '')}',
),
backgroundColor: AppColors.error,
),
);
}
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
// Saved tab load hone tak default Dashboard
// ka flash prevent karenge.

if (_isLoadingIndex) {
return const Scaffold(
body: Center(
child: CircularProgressIndicator(),
),
);
}

return Scaffold(
appBar: AppBar(
title: Text(
_getAppBarTitle(),
),
actions: [
IconButton(
tooltip: 'Logout',
onPressed: _logout,
icon: const Icon(
Icons.logout_rounded,
),
),
const SizedBox(width: 4),
],
),

// ========================================================
// BODY
// ========================================================

body: IndexedStack(
index: _currentIndex,
children: _screens,
),

// ========================================================
// BOTTOM NAVIGATION
// ========================================================

bottomNavigationBar: NavigationBar(
selectedIndex: _currentIndex,

onDestinationSelected: (index) {
setState(() {
_currentIndex = index;
});

_saveSelectedTab(index);
},

backgroundColor:
AppColors.surface,

indicatorColor:
AppColors.accentLight,

destinations: const [
// ----------------------------------------------------
// DASHBOARD
// ----------------------------------------------------

NavigationDestination(
icon: Icon(
Icons.dashboard_outlined,
),
selectedIcon: Icon(
Icons.dashboard_rounded,
),
label: 'Home',
),

// ----------------------------------------------------
// APPLICATIONS
// ----------------------------------------------------

NavigationDestination(
icon: Icon(
Icons.inbox_outlined,
),
selectedIcon: Icon(
Icons.inbox_rounded,
),
label: 'Applications',
),

// ----------------------------------------------------
// BATCHES
// ----------------------------------------------------

NavigationDestination(
icon: Icon(
Icons.groups_outlined,
),
selectedIcon: Icon(
Icons.groups_rounded,
),
label: 'Batches',
),

// ----------------------------------------------------
// NOTICES
// ----------------------------------------------------

NavigationDestination(
icon: Icon(
Icons.campaign_outlined,
),
selectedIcon: Icon(
Icons.campaign_rounded,
),
label: 'Notices',
),

// ----------------------------------------------------
// REPORT
// ----------------------------------------------------

NavigationDestination(
icon: Icon(
Icons.bar_chart_outlined,
),
selectedIcon: Icon(
Icons.bar_chart_rounded,
),
label: 'Report',
),
],
),
);
}

// ============================================================
// APP BAR TITLE
// ============================================================

String _getAppBarTitle() {
switch (_currentIndex) {
case 0:
return 'Coordinator Portal';

case 1:
return 'Applications';

case 2:
return 'Batches';

case 3:
return 'Notices';

case 4:
return 'Reports';

default:
return 'Coordinator Portal';
}
}
}

