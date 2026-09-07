import 'package:flutter/material.dart';
import '../../features/auth/screens/splash_screen.dart';

class AppRoutes {
AppRoutes._();

// Route names
static const String splash = '/';
static const String login = '/login';

// Routes
static Map<String, WidgetBuilder> get routes {
return {
splash: (context) => const SplashScreen(),

};
}
}

