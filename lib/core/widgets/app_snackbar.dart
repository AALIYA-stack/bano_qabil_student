import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(
      BuildContext context,
      String message,
      ) {
    _show(
      context,
      message,
      AppColors.success,
      Icons.check_circle_outline_rounded,
    );
  }

  static void error(
      BuildContext context,
      String message,
      ) {
    _show(
      context,
      message,
      AppColors.error,
      Icons.error_outline_rounded,
    );
  }

  static void info(
      BuildContext context,
      String message,
      ) {
    _show(
      context,
      message,
      AppColors.info,
      Icons.info_outline_rounded,
    );
  }

  static void warning(
      BuildContext context,
      String message,
      ) {
    _show(
      context,
      message,
      AppColors.warning,
      Icons.warning_amber_rounded,
    );
  }

  static void _show(
      BuildContext context,
      String message,
      Color color,
      IconData icon,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          behavior:
          SnackBarBehavior.floating,
          duration: const Duration(
            seconds: 3,
          ),
          content: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 21,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}