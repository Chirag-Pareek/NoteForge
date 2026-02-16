import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;

  const AppOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textColor = isDark
        ? AppColorsDark.primaryText
        : AppColorsLight.primaryText;
    final backgroundColor = isDark
        ? AppColorsDark.background
        : AppColorsLight.background;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.mdBorder,
          boxShadow: AppEffects.subtleDepth(brightness),
        ),
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            elevation: 0,
            side: BorderSide(color: borderColor, width: 1.2),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(
                      label,
                      style: AppTextStyles.button.copyWith(color: textColor),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
