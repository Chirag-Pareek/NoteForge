import 'package:flutter/material.dart';
import 'package:noteforge/core/responsive/app_breakpoints.dart';
import 'package:noteforge/core/theme/app_colors.dart';
import 'package:noteforge/core/theme/app_effects.dart';
import 'package:noteforge/core/theme/app_spacing.dart';
import 'package:noteforge/core/theme/app_text_styles.dart';

/// AI insights tab with actionable recommendations.
class AiInsightsScreen extends StatelessWidget {
  final double topPadding;

  const AiInsightsScreen({super.key, required this.topPadding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = AppBreakpoints.pageHorizontalPadding(width);
    final maxWidth = AppBreakpoints.pageMaxContentWidth(width);

    const insights = [
      _InsightData(
        icon: Icons.bolt_outlined,
        title: 'Boost retention with spaced recall',
        description:
            'Review Chemistry notes tomorrow and then again after 3 days to lock concepts in memory.',
      ),
      _InsightData(
        icon: Icons.schedule_outlined,
        title: 'Best focus window detected',
        description:
            'Your strongest performance appears between 6 PM and 8 PM. Schedule tougher tasks there.',
      ),
      _InsightData(
        icon: Icons.adjust_outlined,
        title: 'Balance subject allocation',
        description:
            'Math received 42% of this week’s time. Shift 30 minutes to Biology for better balance.',
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Insights', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Personalized guidance based on your study patterns.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColorsDark.secondaryText
                      : AppColorsLight.secondaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...insights.map(
                (insight) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _InsightCard(
                    insight: insight,
                    borderColor: borderColor,
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

class _InsightCard extends StatelessWidget {
  final _InsightData insight;
  final Color borderColor;

  const _InsightCard({required this.insight, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColorsDark.background
        : AppColorsLight.background;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: AppEffects.subtleDepth(Theme.of(context).brightness),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(insight.icon, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.title, style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(insight.description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightData {
  final IconData icon;
  final String title;
  final String description;

  const _InsightData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
