import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

class AppTheme {
  AppTheme._();

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.banoQabilGreen,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.banoQabilGreen,
      onPrimary: Colors.white,

      secondary: AppColors.banoQabilLightGreen,
      onSecondary: AppColors.textPrimary,

      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,

      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      // ========================================================
      // MATERIAL
      // ========================================================

      useMaterial3: true,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: AppColors.background,

      fontFamily: 'Roboto',

      visualDensity: VisualDensity.adaptivePlatformDensity,

      // ========================================================
      // APP BAR
      // ========================================================

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,

        foregroundColor: AppColors.textPrimary,

        elevation: 0,

        scrolledUnderElevation: 0,

        centerTitle: false,

        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),

        iconTheme: IconThemeData(
          color: AppColors.banoQabilGreen,
          size: AppDimensions.iconMedium,
        ),
      ),

      // ========================================================
      // CARD
      // ========================================================

      cardTheme: CardThemeData(
        color: AppColors.surface,

        elevation: 0,

        margin: EdgeInsets.zero,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLarge,
          ),
          side: const BorderSide(
            color: AppColors.border,
          ),
        ),
      ),

      // ========================================================
      // INPUT FIELDS
      // ========================================================

      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: AppColors.surface,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: 15,
        ),

        hintStyle: const TextStyle(
          color: AppColors.textLight,
          fontSize: 14,
        ),

        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),

        floatingLabelStyle: const TextStyle(
          color: AppColors.banoQabilGreen,
          fontWeight: FontWeight.w600,
        ),

        prefixIconColor: AppColors.banoQabilGreen,

        suffixIconColor: AppColors.textSecondary,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMedium,
          ),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMedium,
          ),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMedium,
          ),
          borderSide: const BorderSide(
            color: AppColors.banoQabilGreen,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMedium,
          ),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMedium,
          ),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
      ),

      // ========================================================
      // ELEVATED BUTTON
      // ========================================================

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(
            AppDimensions.buttonHeight,
          ),

          backgroundColor: AppColors.banoQabilGreen,

          foregroundColor: Colors.white,

          elevation: 0,

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMedium,
            ),
          ),

          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // OUTLINED BUTTON
      // ========================================================

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(
            AppDimensions.buttonHeight,
          ),

          foregroundColor: AppColors.banoQabilGreen,

          side: const BorderSide(
            color: AppColors.banoQabilGreen,
            width: 1.2,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMedium,
            ),
          ),

          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ========================================================
      // TEXT BUTTON
      // ========================================================

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.banoQabilGreen,

          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusSmall,
            ),
          ),
        ),
      ),

      // ========================================================
      // FLOATING ACTION BUTTON
      // ========================================================

      floatingActionButtonTheme:
      const FloatingActionButtonThemeData(
        backgroundColor: AppColors.banoQabilGreen,

        foregroundColor: Colors.white,

        elevation: 3,
      ),

      // ========================================================
      // CHECKBOX
      // ========================================================

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),

        side: const BorderSide(
          color: AppColors.border,
          width: 1.5,
        ),

        fillColor: WidgetStateProperty.resolveWith(
              (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.banoQabilGreen;
            }

            return Colors.transparent;
          },
        ),

        checkColor: WidgetStateProperty.all(
          Colors.white,
        ),
      ),

      // ========================================================
      // RADIO
      // ========================================================

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
              (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.banoQabilGreen;
            }

            return AppColors.textSecondary;
          },
        ),
      ),

      // ========================================================
      // SWITCH
      // ========================================================

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
              (states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }

            return AppColors.textSecondary;
          },
        ),

        trackColor: WidgetStateProperty.resolveWith(
              (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.banoQabilGreen;
            }

            return AppColors.surfaceVariant;
          },
        ),
      ),

      // ========================================================
      // PROGRESS INDICATOR
      // ========================================================

      progressIndicatorTheme:
      const ProgressIndicatorThemeData(
        color: AppColors.banoQabilGreen,

        linearTrackColor: AppColors.surfaceVariant,

        circularTrackColor: AppColors.surfaceVariant,
      ),

      // ========================================================
      // DIVIDER
      // ========================================================

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,

        thickness: 1,

        space: 1,
      ),

      // ========================================================
      // CHIP
      // ========================================================

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,

        selectedColor: AppColors.accentLight,

        disabledColor: AppColors.surfaceVariant,

        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),

        secondaryLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.banoQabilGreen,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        side: BorderSide.none,
      ),

      // ========================================================
      // SNACKBAR
      // ========================================================

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,

        backgroundColor: AppColors.banoQabilDarkGreen,

        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMedium,
          ),
        ),

        insetPadding: const EdgeInsets.all(
          AppDimensions.paddingMedium,
        ),
      ),

      // ========================================================
      // DIALOG
      // ========================================================

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,

        elevation: 8,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusXLarge,
          ),
        ),

        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),

        contentTextStyle: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppColors.textSecondary,
        ),
      ),

      // ========================================================
      // BOTTOM SHEET
      // ========================================================

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,

        elevation: 8,

        showDragHandle: true,

        dragHandleColor: AppColors.banoQabilGreen,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              AppDimensions.radiusXLarge,
            ),
          ),
        ),
      ),

      // ========================================================
      // NAVIGATION BAR
      // ========================================================

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,

        elevation: 4,

        height: 70,

        indicatorColor: AppColors.accentLight,

        labelBehavior:
        NavigationDestinationLabelBehavior.alwaysShow,

        iconTheme: WidgetStateProperty.resolveWith(
              (states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: AppColors.banoQabilGreen,
                size: 24,
              );
            }

            return const IconThemeData(
              color: AppColors.textSecondary,
              size: 22,
            );
          },
        ),

        labelTextStyle: WidgetStateProperty.resolveWith(
              (states) {
            final bool selected =
            states.contains(WidgetState.selected);

            return TextStyle(
              fontSize: 12,
              fontWeight:
              selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? AppColors.banoQabilGreen
                  : AppColors.textSecondary,
            );
          },
        ),
      ),

      // ========================================================
      // LIST TILE
      // ========================================================

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.banoQabilGreen,

        textColor: AppColors.textPrimary,

        subtitleTextStyle: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),

        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
        ),
      ),

      // ========================================================
      // TOOLTIP
      // ========================================================

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.banoQabilDarkGreen,

          borderRadius: BorderRadius.circular(
            AppDimensions.radiusSmall,
          ),
        ),

        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}