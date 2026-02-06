import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Displays progress bar for a specific subject with trend indicator
/// Shows completion percentage and visual progress bar
class SubjectProgressBar extends StatelessWidget {
  final String subject;
  final double progress; // 0.0 to 1.0
  final String trend; // 'up', 'down', 'stable'
  final VoidCallback? onTap;

  const SubjectProgressBar({
    super.key,
    required this.subject,
    required this.progress,
    required this.trend,
    this.onTap,
  });

  /// Gets trend icon based on trend value
  IconData _getTrendIcon() {
    switch (trend) {
      case 'up':
        return Icons.trending_up;
      case 'down':
        return Icons.trending_down;
      case 'stable':
      default:
        return Icons.trending_flat;
    }
  }

  /// Gets trend color
  Color _getTrendColor(bool isDark) {
    switch (trend) {
      case 'up':
        return isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText;
      case 'down':
        return isDark
            ? AppColorsDark.secondaryText
            : AppColorsLight.secondaryText;
      case 'stable':
      default:
        return isDark
            ? AppColorsDark.secondaryText
            : AppColorsLight.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = (progress * 100).toInt();
    const radius = BorderRadius.all(Radius.circular(10));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        // Subject rows can open chart sheets from parent when onTap is provided.
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppColorsDark.background
                : AppColorsLight.background,
            border: Border.all(
              color: isDark ? AppColorsDark.border : AppColorsLight.border,
            ),
            borderRadius: radius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    subject,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      if (onTap != null) ...[
                        Icon(
                          Icons.show_chart_rounded,
                          size: 14,
                          color: isDark
                              ? AppColorsDark.secondaryText
                              : AppColorsLight.secondaryText,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Icon(
                        _getTrendIcon(),
                        size: 16,
                        color: _getTrendColor(isDark),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '$percentage%',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? AppColorsDark.border
                      : AppColorsLight.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark
                        ? AppColorsDark.primaryText
                        : AppColorsLight.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
