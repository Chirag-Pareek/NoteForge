import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColorsDark.primaryButton
        : AppColorsLight.primaryButton;
    final textColor = isDark
        ? Colors.black
        : Colors.white; // Inverted based on bg

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.mdBorder,
          boxShadow: AppEffects.subtleDepth(brightness),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            disabledBackgroundColor: backgroundColor.withAlpha(
              (0.5 * 255).toInt(),
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
              : Text(
                  label,
                  style: AppTextStyles.button.copyWith(color: textColor),
                ),
        ),
      ),
    );
  }
}
