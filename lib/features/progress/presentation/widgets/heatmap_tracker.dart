import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// GitHub-style activity heatmap showing daily learning intensity.
/// Displays last 12 weeks of activity.
/// Color gradient based on study minutes per day.
class HeatmapTracker extends StatelessWidget {
  const HeatmapTracker({super.key});

  static const double _cellSize = 12;
  static const double _cellGap = 2;
  static const double _columnWidth = 24;
  static const double _weekLabelHeight = 14;

  /// Generates demo heatmap data (in production, fetch from backend/local storage).
  List<List<int>> _generateHeatmapData() {
    // 12 weeks x 7 days = 84 days.
    // Values represent study minutes: 0 = none, 1-30 = low, 31-60 = medium, 61+ = high.
    final data = <List<int>>[];
    for (int week = 0; week < 12; week++) {
      final weekData = <int>[];
      for (int day = 0; day < 7; day++) {
        // Demo pattern.
        final value = (week * 7 + day) % 13 == 0
            ? 0
            : ((week * 7 + day) % 5 + 1) * 15;
        weekData.add(value);
      }
      data.add(weekData);
    }
    return data;
  }

  /// Gets color intensity based on study minutes.
  Color _getIntensityColor(int minutes, bool isDark) {
    if (minutes == 0) {
      return isDark ? AppColorsDark.border : AppColorsLight.border;
    }
    if (minutes <= 30) {
      return isDark
          ? AppColorsDark.primaryText.withValues(alpha: 0.3)
          : AppColorsLight.primaryText.withValues(alpha: 0.3);
    }
    if (minutes <= 60) {
      return isDark
          ? AppColorsDark.primaryText.withValues(alpha: 0.6)
          : AppColorsLight.primaryText.withValues(alpha: 0.6);
    }
    return isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText;
  }

  /// Compact formatter for minutes to keep the summary line readable.
  String _formatMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours == 0) {
      return '$mins min';
    }
    if (mins == 0) {
      return '${hours}h';
    }
    return '${hours}h ${mins}m';
  }

  Widget _buildDayLabels(bool isDark) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SizedBox(
      width: 30,
      child: Column(
        children: [
          const SizedBox(height: _weekLabelHeight + _cellGap),
          ...List.generate(7, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: _cellGap),
              child: SizedBox(
                height: _cellSize,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    labels[index],
                    style: AppTextStyles.label.copyWith(
                      fontSize: 8,
                      color: isDark
                          ? AppColorsDark.secondaryText
                          : AppColorsLight.secondaryText,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeekColumn({
    required List<int?> weekData,
    required bool isDark,
    required String label,
  }) {
    final borderBaseColor = isDark
        ? AppColorsDark.border
        : AppColorsLight.border;

    return Padding(
      padding: const EdgeInsets.only(right: _cellGap),
      child: Column(
        children: [
          SizedBox(
            width: _columnWidth,
            height: _weekLabelHeight,
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.label.copyWith(
                  fontSize: 8,
                  color: isDark
                      ? AppColorsDark.secondaryText
                      : AppColorsLight.secondaryText,
                ),
              ),
            ),
          ),
          const SizedBox(height: _cellGap),
          ...weekData.map((minutes) {
            final isEmptyPlaceholder = minutes == null;
            final fillColor = isEmptyPlaceholder
                ? Colors.transparent
                : _getIntensityColor(minutes, isDark);

            return Padding(
              padding: const EdgeInsets.only(bottom: _cellGap),
              child: SizedBox(
                width: _columnWidth,
                child: Center(
                  child: Container(
                    width: _cellSize,
                    height: _cellSize,
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        // Empty placeholders render as outlined boxes like GitHub.
                        color: isEmptyPlaceholder
                            ? borderBaseColor.withValues(alpha: 0.65)
                            : Colors.transparent,
                        width: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heatmapData = _generateHeatmapData();
    final flattenedData = heatmapData.expand((week) => week).toList();
    final totalMinutes = flattenedData.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    final activeDays = flattenedData.where((value) => value > 0).length;
    final consistency = ((activeDays / flattenedData.length) * 100).round();
    final bestDay = flattenedData.reduce((a, b) => a > b ? a : b);

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
            'Last 12 weeks',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${_formatMinutes(totalMinutes)} total | $activeDays active days | '
            '$consistency% consistency | best day $bestDay min',
            style: AppTextStyles.label.copyWith(
              color: isDark
                  ? AppColorsDark.secondaryText
                  : AppColorsLight.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Week labels: W1 (oldest) to W12 (current)',
            style: AppTextStyles.label.copyWith(
              color: isDark
                  ? AppColorsDark.secondaryText
                  : AppColorsLight.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Heatmap grid.
          LayoutBuilder(
            builder: (context, constraints) {
              final baseColumns = heatmapData.length;
              final weekLabels = List<String>.generate(
                baseColumns,
                (index) => 'W${index + 1}',
              );
              // Fill available width with extra empty columns so remaining space
              // still looks like a complete GitHub-style grid.
              final maxColumnsInView =
                  ((constraints.maxWidth + _cellGap) /
                          (_columnWidth + _cellGap))
                      .floor();
              final totalColumns = maxColumnsInView > baseColumns
                  ? maxColumnsInView
                  : baseColumns;
              final emptyColumns = totalColumns - baseColumns;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDayLabels(isDark),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...heatmapData.asMap().entries.map(
                            (entry) => _buildWeekColumn(
                              weekData: entry.value.cast<int?>(),
                              isDark: isDark,
                              label: weekLabels[entry.key],
                            ),
                          ),
                          ...List.generate(
                            emptyColumns,
                            (_) => _buildWeekColumn(
                              weekData: const [
                                null,
                                null,
                                null,
                                null,
                                null,
                                null,
                                null,
                              ],
                              isDark: isDark,
                              label: '',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Legend.
          Row(
            children: [
              Text(
                'Less',
                style: AppTextStyles.label.copyWith(
                  fontSize: 10,
                  color: isDark
                      ? AppColorsDark.secondaryText
                      : AppColorsLight.secondaryText,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              ...List.generate(4, (index) {
                final minutes = index * 30;
                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getIntensityColor(minutes, isDark),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'More',
                style: AppTextStyles.label.copyWith(
                  fontSize: 10,
                  color: isDark
                      ? AppColorsDark.secondaryText
                      : AppColorsLight.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
