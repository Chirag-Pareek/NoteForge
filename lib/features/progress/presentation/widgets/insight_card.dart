import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_effects.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Displays a single insight card with icon, title, and description
/// Used for quick actionable insights on the overview screen
class InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const InsightCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.background : AppColorsLight.background,
        border: Border.all(
          color: isDark ? AppColorsDark.border : AppColorsLight.border,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppEffects.subtleDepth(Theme.of(context).brightness),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColorsDark.lightBackground
                  : AppColorsLight.lightBackground,
              borderRadius: BorderRadius.circular(8),
              boxShadow: AppEffects.subtleDepth(Theme.of(context).brightness),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark
                  ? AppColorsDark.primaryText
                  : AppColorsLight.primaryText,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColorsDark.secondaryText
                        : AppColorsLight.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
