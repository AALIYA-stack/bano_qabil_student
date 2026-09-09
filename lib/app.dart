import 'package:flutter/material.dart';

import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';

class BanoQabilApp extends StatelessWidget {
  const BanoQabilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bano Qabil',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      initialRoute: AppRoutes.splash,

      routes: AppRoutes.routes,
    );
  }
}
