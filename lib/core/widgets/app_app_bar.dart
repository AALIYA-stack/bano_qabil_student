import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';

class AppAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  final String? subtitle;

  final List<Widget>? actions;

  final bool showBack;

  final VoidCallback? onBack;

  final Widget? leading;

  const AppAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBack = true,
    this.onBack,
    this.leading,
  });

  @override
  Size get preferredSize =>
      const Size.fromHeight(
        AppDimensions.appBarHeight,
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,

      leading: leading ??
          (showBack
              ? IconButton(
            onPressed: onBack ??
                    () {
                  Navigator.of(context)
                      .maybePop();
                },
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
          )
              : null),

      title: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),

      actions: actions,
    );
  }
}