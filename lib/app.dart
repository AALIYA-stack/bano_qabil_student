import 'package:flutter/material.dart';

import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_controller.dart';

class BanoQabilApp extends StatefulWidget {
  const BanoQabilApp({super.key});

  @override
  State<BanoQabilApp> createState() =>
      _BanoQabilAppState();
}

class _BanoQabilAppState extends State<BanoQabilApp> {
  @override
  void initState() {
    super.initState();

    ThemeController.instance.addListener(
      _onThemeChanged,
    );
  }

  @override
  void dispose() {
    ThemeController.instance.removeListener(
      _onThemeChanged,
    );

    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final themeController =
        ThemeController.instance;

    return MaterialApp(
      title: 'Bano Qabil',

      debugShowCheckedModeBanner: false,

      // ========================================================
      // THEMES
      // ========================================================

      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.darkTheme,

      themeMode: themeController.themeMode,

      // ========================================================
      // ROUTING
      // ========================================================

      initialRoute: AppRoutes.splash,

      routes: AppRoutes.routes,
    );
  }
}