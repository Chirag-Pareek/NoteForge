import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final int? maxLines;

  const AppTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final fillColor = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;
    final hintColor = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final textColor = isDark
        ? AppColorsDark.primaryText
        : AppColorsLight.primaryText;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdBorder,
        boxShadow: AppEffects.subtleDepth(brightness),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: AppTextStyles.bodyMedium.copyWith(color: textColor),
        cursorColor: textColor,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: hintColor),
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.all(AppSpacing.lg),
          suffixIcon: suffixIcon,
          suffixIconColor: hintColor,
          border: OutlineInputBorder(
            borderRadius: AppRadius.mdBorder,
            borderSide: BorderSide(color: borderColor, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdBorder,
            borderSide: BorderSide(color: borderColor, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdBorder,
            borderSide: BorderSide(color: textColor, width: 1.2),
          ),
        ),
      ),
    );
  }
}
