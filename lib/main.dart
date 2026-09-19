import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'app/theme/theme_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options:
    DefaultFirebaseOptions.currentPlatform,
  );

  // Load saved theme before app starts.
  await ThemeController.instance.loadTheme();

  runApp(
    const BanoQabilApp(),
  );
}