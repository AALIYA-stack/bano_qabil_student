import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;

  final String label;

  final String? hint;

  final String? Function(String?)? validator;

  final TextInputType? keyboardType;

  final TextInputAction? textInputAction;

  final bool obscureText;

  final bool enabled;

  final int maxLines;

  final int? maxLength;

  final Widget? prefixIcon;

  final Widget? suffixIcon;

  final ValueChanged<String>? onChanged;

  final VoidCallback? onTap;

  final bool readOnly;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onTap: onTap,
      textCapitalization:
      keyboardType == TextInputType.emailAddress
          ? TextCapitalization.none
          : TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMedium,
          ),
        ),
      ),
    );
  }
}