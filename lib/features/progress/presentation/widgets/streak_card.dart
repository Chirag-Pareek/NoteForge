
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Displays current study streak with fire emoji
/// Shows number of consecutive days studied
class StreakCard extends StatelessWidget {
  final int currentStreak;

  const StreakCard({
    super.key,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.background : AppColorsLight.background,
        border: Border.all(
          color: isDark ? AppColorsDark.border : AppColorsLight.border,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Streak',
            style: AppTextStyles.label.copyWith(
              color: isDark ? AppColorsDark.secondaryText : AppColorsLight.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$currentStreak',
                style: AppTextStyles.display.copyWith(fontSize: 28),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Text(
                '🔥',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'days in a row',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColorsDark.secondaryText : AppColorsLight.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}