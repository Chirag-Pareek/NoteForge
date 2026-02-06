import 'package:flutter/material.dart';
import 'package:noteforge/core/theme/app_colors.dart';
import 'package:noteforge/core/theme/app_spacing.dart';
import 'package:noteforge/core/theme/app_text_styles.dart';

/// Analytics tab with quick progress breakdown metrics.
class AnalyticsScreen extends StatelessWidget {
  final double topPadding;

  const AnalyticsScreen({super.key, required this.topPadding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final mutedText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        topPadding,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Analytics Snapshot', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Track how your study time converts to outcomes.',
            style: AppTextStyles.bodySmall.copyWith(color: mutedText),
          ),
          const SizedBox(height: AppSpacing.lg),
          _MetricCard(
            icon: Icons.timer_outlined,
            label: 'Weekly Study Time',
            value: '14h 32m',
            trend: '+12% vs last week',
            borderColor: borderColor,
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricCard(
            icon: Icons.check_circle_outline,
            label: 'Task Completion',
            value: '86%',
            trend: '+9% consistency',
            borderColor: borderColor,
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricCard(
            icon: Icons.insights_outlined,
            label: 'Avg Test Score',
            value: '88.4',
            trend: '+3.1 points',
            borderColor: borderColor,
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String trend;
  final Color borderColor;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColorsDark.background
        : AppColorsLight.background;
    final mutedText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(color: mutedText),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(value, style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  trend,
                  style: AppTextStyles.label.copyWith(color: mutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
