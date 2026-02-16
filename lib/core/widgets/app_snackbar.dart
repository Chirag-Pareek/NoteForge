import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme Colors
    final bgColor = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;
    final textColor = isDark
        ? AppColorsDark.primaryText
        : AppColorsLight.primaryText;
    final borderColor = isError
        ? (isDark ? Colors.red.shade900 : Colors.red.shade100)
        : (isDark ? AppColorsDark.border : AppColorsLight.border);

    final iconColor = isError
        ? Colors.red.shade400
        : (isDark ? Colors.green.shade400 : Colors.green.shade600);

    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        content: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(color: borderColor),
            boxShadow: AppEffects.subtleDepth(Theme.of(context).brightness),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
