
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Displays overall performance score with level indicator
/// Score is composite of activity, consistency, and mastery
/// Levels: Beginner (0-30), Intermediate (31-60), Advanced (61-85), Expert (86-100)
class PerformanceScoreCard extends StatelessWidget {
  final double score; // 0-100

  const PerformanceScoreCard({
    super.key,
    required this.score,
  });

  /// Determines level label based on score
  String _getLevelLabel() {
    if (score >= 86) return 'Expert';
    if (score >= 61) return 'Advanced';
    if (score >= 31) return 'Intermediate';
    return 'Beginner';
  }

  /// Gets progress color based on score
  Color _getScoreColor(bool isDark) {
    if (score >= 86) {
      return isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText;
    }
    return isDark ? AppColorsDark.secondaryText : AppColorsLight.secondaryText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final level = _getLevelLabel();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance Score',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColorsDark.lightBackground : AppColorsLight.lightBackground,
                  border: Border.all(
                    color: isDark ? AppColorsDark.border : AppColorsLight.border,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  level,
                  style: AppTextStyles.label.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Score display
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                score.toStringAsFixed(1),
                style: AppTextStyles.display.copyWith(
                  fontSize: 40,
                  color: _getScoreColor(isDark),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '/ 100',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColorsDark.secondaryText : AppColorsLight.secondaryText,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 6,
              backgroundColor: isDark ? AppColorsDark.border : AppColorsLight.border,
              valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(isDark)),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Score breakdown
          Row(
            children: [
              _buildScoreComponent(
                context,
                'Activity',
                0.90,
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildScoreComponent(
                context,
                'Consistency',
                0.87,
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildScoreComponent(
                context,
                'Mastery',
                0.85,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a single score component indicator
  Widget _buildScoreComponent(BuildContext context, String label, double value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontSize: 11,
            color: isDark ? AppColorsDark.secondaryText : AppColorsLight.secondaryText,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: value >= 0.85
                    ? (isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText)
                    : (isDark ? AppColorsDark.secondaryText : AppColorsLight.secondaryText),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${(value * 100).toInt()}%',
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}