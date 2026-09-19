import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../services/auth_service.dart';

class CoordinatorSettingsScreen extends StatefulWidget {
  const CoordinatorSettingsScreen({
    super.key,
  });

  @override
  State<CoordinatorSettingsScreen> createState() =>
      _CoordinatorSettingsScreenState();
}

class _CoordinatorSettingsScreenState
    extends State<CoordinatorSettingsScreen> {
  bool _isLoggingOut = false;

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

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

      setState(() {
        _isLoggingOut = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Logout failed: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // CONFIRM LOGOUT
  // ============================================================

  Future<void> _showLogoutDialog() async {
    if (_isLoggingOut) return;

    final shouldLogout =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout',
          ),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _logout();
    }
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context)
            .colorScheme
            .onSurface,
      ),
    );
  }

  // ============================================================
  // DARK MODE
  // ============================================================

  Future<void> _toggleDarkMode(
      bool value,
      ) async {
    await ThemeController.instance
        .setDarkMode(value);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final themeController =
        ThemeController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
        ),
        centerTitle: false,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            AppDimensions.paddingLarge,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // ==================================================
              // ACCOUNT
              // ==================================================

              _sectionTitle(
                'Account',
              ),

              const SizedBox(
                height:
                AppDimensions.spacingSmall,
              ),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                        AppColors.primary
                            .withOpacity(0.1),
                        child: const Icon(
                          Icons.person_outline,
                          color:
                          AppColors.primary,
                        ),
                      ),
                      title: const Text(
                        'Coordinator Account',
                      ),
                      subtitle: const Text(
                        'Manage your coordinator account',
                      ),
                    ),

                    const Divider(
                      height: 1,
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.lock_outline,
                      ),
                      title: const Text(
                        'Password & Security',
                      ),
                      subtitle: const Text(
                        'Manage your account security',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Password & security settings coming soon.',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height:
                AppDimensions.spacingLarge,
              ),

              // ==================================================
              // APP
              // ==================================================

              _sectionTitle(
                'App',
              ),

              const SizedBox(
                height:
                AppDimensions.spacingSmall,
              ),

              Card(
                child: Column(
                  children: [
                    // ==================================================
                    // DARK MODE
                    // ==================================================

                    SwitchListTile(
                      secondary: Icon(
                        themeController.isDarkMode
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        color:
                        AppColors.banoQabilGreen,
                      ),

                      title: const Text(
                        'Dark Mode',
                      ),

                      subtitle: Text(
                        themeController.isDarkMode
                            ? 'Dark theme is enabled'
                            : 'Use the light theme',
                      ),

                      value:
                      themeController.isDarkMode,

                      activeColor:
                      AppColors.banoQabilGreen,

                      onChanged:
                      _toggleDarkMode,
                    ),

                    const Divider(
                      height: 1,
                    ),

                    // ==================================================
                    // NOTIFICATIONS
                    // ==================================================

                    ListTile(
                      leading: const Icon(
                        Icons.notifications_outlined,
                      ),
                      title: const Text(
                        'Notifications',
                      ),
                      subtitle: const Text(
                        'Manage notification preferences',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Notification settings coming soon.',
                            ),
                          ),
                        );
                      },
                    ),

                    const Divider(
                      height: 1,
                    ),

                    // ==================================================
                    // ABOUT
                    // ==================================================

                    ListTile(
                      leading: const Icon(
                        Icons.info_outline,
                      ),
                      title: const Text(
                        'About',
                      ),
                      subtitle: const Text(
                        'Bano Qabil Student App',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName:
                          'Bano Qabil Student App',
                          applicationVersion:
                          '1.0.0',
                          applicationLegalese:
                          'Bano Qabil',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height:
                AppDimensions.spacingLarge,
              ),

              // ==================================================
              // LOGOUT
              // ==================================================

              Card(
                child: ListTile(
                  leading: _isLoggingOut
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : Icon(
                    Icons.logout,
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .error,
                  ),

                  title: Text(
                    _isLoggingOut
                        ? 'Logging out...'
                        : 'Logout',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .error,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  subtitle: const Text(
                    'Sign out of your coordinator account',
                  ),

                  onTap: _isLoggingOut
                      ? null
                      : _showLogoutDialog,
                ),
              ),

              const SizedBox(
                height:
                AppDimensions.spacingLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}