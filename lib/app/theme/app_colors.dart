import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============================================================
  // BANO QABIL BRAND COLORS
  // ============================================================

  /// Main Bano Qabil brand green
  static const Color banoQabilGreen = Color(0xFF006B3C);

  /// Dark brand green
  static const Color banoQabilDarkGreen = Color(0xFF004D2C);

  /// Bright Bano Qabil green / lime accent
  static const Color banoQabilLightGreen = Color(0xFF8BC53F);

  /// Secondary teal accent
  static const Color banoQabilTeal = Color(0xFF009B87);

  // ============================================================
  // PRIMARY COLORS
  // ============================================================

  static const Color primary = banoQabilGreen;

  static const Color primaryDark = banoQabilDarkGreen;

  static const Color primaryLight = Color(0xFF16805A);

  // ============================================================
  // ACCENT COLORS
  // ============================================================

  static const Color accent = banoQabilLightGreen;

  static const Color accentLight = Color(0xFFE8F5E9);

  static const Color accentTealLight = Color(0xFFE2F5F2);

  // ============================================================
  // BACKGROUND
  // ============================================================

  static const Color background = Color(0xFFF6F9F7);

  static const Color surface = Colors.white;

  static const Color surfaceVariant = Color(0xFFF1F5F2);

  // ============================================================
  // TEXT
  // ============================================================

  static const Color textPrimary = Color(0xFF17202A);

  static const Color textSecondary = Color(0xFF68737D);

  static const Color textLight = Color(0xFF9AA4AD);

  static const Color textOnGreen = Colors.white;

  // ============================================================
  // STATUS COLORS
  // ============================================================

  static const Color success = Color(0xFF2E9B61);

  static const Color successLight = Color(0xFFE8F5E9);

  static const Color warning = Color(0xFFE59F22);

  static const Color warningLight = Color(0xFFFFF4DD);

  static const Color error = Color(0xFFD9534F);

  static const Color errorLight = Color(0xFFFDECEC);

  static const Color info = Color(0xFF4285F4);

  static const Color infoLight = Color(0xFFEAF2FF);

  // ============================================================
  // UI
  // ============================================================

  static const Color border = Color(0xFFE0E7E3);

  static const Color divider = Color(0xFFE7ECE9);

  static const Color shadow = Color(0x14000000);

  // ============================================================
  // STATUS / CHIP BACKGROUNDS
  // ============================================================

  static const Color pendingBackground = Color(0xFFFFF4DD);

  static const Color submittedBackground = Color(0xFFE8F5E9);

  static const Color markedBackground = Color(0xFFE8F5E9);

  static const Color lateBackground = Color(0xFFFFF4DD);

  // ============================================================
  // LEGACY / COMPATIBILITY
  // ============================================================

  static const Color errorBackground = errorLight;
}