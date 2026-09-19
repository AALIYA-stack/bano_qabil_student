import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance =
  ThemeController._();

  static const String _darkModeKey = 'isDarkMode';

  bool _isDarkMode = false;

  // ============================================================
  // GETTER
  // ============================================================

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode {
    return _isDarkMode
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  // ============================================================
  // LOAD SAVED THEME
  // ============================================================

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    _isDarkMode =
        prefs.getBool(_darkModeKey) ?? false;

    notifyListeners();
  }

  // ============================================================
  // TOGGLE DARK MODE
  // ============================================================

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;

    notifyListeners();

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      _darkModeKey,
      _isDarkMode,
    );
  }

  // ============================================================
  // SET DARK MODE
  // ============================================================

  Future<void> setDarkMode(bool value) async {
    await toggleDarkMode(value);
  }
}