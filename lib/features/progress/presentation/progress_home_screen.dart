import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/floating_progress_nav.dart';
import 'widgets/calendar_screen.dart';
import 'widgets/analytics_screen.dart';
import 'widgets/ai_insights_screen.dart';
import 'widgets/streak_card.dart';
import 'widgets/heatmap_tracker.dart';
import 'widgets/performance_score_card.dart';
import 'widgets/insight_card.dart';
import 'widgets/subject_progress_bar.dart';
import 'widgets/subject_learning_chart_sheet.dart';

/// Main Progress screen with floating navigation
/// Shows overview dashboard by default
/// Switches between 4 views: Overview, Calendar, Analytics, AI Insights
class ProgressHomeScreen extends StatefulWidget {
  const ProgressHomeScreen({super.key});

  @override
  State<ProgressHomeScreen> createState() => _ProgressHomeScreenState();
}

class _ProgressHomeScreenState extends State<ProgressHomeScreen> {
  // Current selected tab index: 0=Overview, 1=Calendar, 2=Analytics, 3=AI.
  int _selectedIndex = 0;

  // Demo data for progress tracking
  final int _currentStreak = 7;
  final int _todayMinutes = 124;
  final int _todayTests = 3;
  final double _performanceScore = 87.5;
  // Demo intraday learning data for each subject (hour -> minutes learned).
  final Map<String, List<LearningDataPoint>> _subjectLearningSeries = {
    'Physics': const [
      LearningDataPoint(hour: 6, minutesLearned: 12),
      LearningDataPoint(hour: 8, minutesLearned: 20),
      LearningDataPoint(hour: 10, minutesLearned: 16),
      LearningDataPoint(hour: 13, minutesLearned: 42),
      LearningDataPoint(hour: 16, minutesLearned: 55),
      LearningDataPoint(hour: 19, minutesLearned: 61),
      LearningDataPoint(hour: 22, minutesLearned: 48),
    ],
    'Mathematics': const [
      LearningDataPoint(hour: 6, minutesLearned: 10),
      LearningDataPoint(hour: 9, minutesLearned: 28),
      LearningDataPoint(hour: 12, minutesLearned: 38),
      LearningDataPoint(hour: 15, minutesLearned: 32),
      LearningDataPoint(hour: 18, minutesLearned: 64),
      LearningDataPoint(hour: 20, minutesLearned: 70),
      LearningDataPoint(hour: 22, minutesLearned: 57),
    ],
    'Chemistry': const [
      LearningDataPoint(hour: 7, minutesLearned: 18),
      LearningDataPoint(hour: 10, minutesLearned: 26),
      LearningDataPoint(hour: 12, minutesLearned: 24),
      LearningDataPoint(hour: 14, minutesLearned: 41),
      LearningDataPoint(hour: 17, minutesLearned: 30),
      LearningDataPoint(hour: 20, minutesLearned: 45),
      LearningDataPoint(hour: 22, minutesLearned: 36),
    ],
    'Biology': const [
      LearningDataPoint(hour: 6, minutesLearned: 14),
      LearningDataPoint(hour: 8, minutesLearned: 22),
      LearningDataPoint(hour: 11, minutesLearned: 31),
      LearningDataPoint(hour: 14, minutesLearned: 48),
      LearningDataPoint(hour: 17, minutesLearned: 52),
      LearningDataPoint(hour: 19, minutesLearned: 47),
      LearningDataPoint(hour: 21, minutesLearned: 54),
    ],
  };

  /// Handles navigation tab change
  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  /// Opens a modern market-style chart for a subject's learning timeline.
  void _openSubjectChart(String subject) {
    final series = _subjectLearningSeries[subject];
    if (series == null || series.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          SubjectLearningChartSheet(subject: subject, points: series),
    );
  }

  /// Builds the active screen and offsets it below the floating nav.
  Widget _buildActiveScreen(double topPadding) {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewScreen(topPadding);
      case 1:
        return CalendarScreen(topPadding: topPadding);
      case 2:
        return AnalyticsScreen(topPadding: topPadding);
      case 3:
        return AiInsightsScreen(topPadding: topPadding);
      default:
        return _buildOverviewScreen(topPadding);
    }
  }

  /// Overview Dashboard - Main screen showing all key metrics
  Widget _buildOverviewScreen(double topPadding) {
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
          // Top metrics row
          Row(
            children: [
              Expanded(child: StreakCard(currentStreak: _currentStreak)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildTodaySummaryCard()),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Performance score
          PerformanceScoreCard(score: _performanceScore),

          const SizedBox(height: AppSpacing.lg),

          // Section title
          Text('Activity Overview', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.md),

          // GitHub-style heatmap
          const HeatmapTracker(),

          const SizedBox(height: AppSpacing.lg),

          // Subject mastery section
          Text('Subject Mastery', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.md),

          // Subject progress bars
          SubjectProgressBar(
            subject: 'Physics',
            progress: 0.92,
            trend: 'up',
            onTap: () => _openSubjectChart('Physics'),
          ),
          const SizedBox(height: AppSpacing.sm),
          SubjectProgressBar(
            subject: 'Mathematics',
            progress: 0.88,
            trend: 'up',
            onTap: () => _openSubjectChart('Mathematics'),
          ),
          const SizedBox(height: AppSpacing.sm),
          SubjectProgressBar(
            subject: 'Chemistry',
            progress: 0.76,
            trend: 'down',
            onTap: () => _openSubjectChart('Chemistry'),
          ),
          const SizedBox(height: AppSpacing.sm),
          SubjectProgressBar(
            subject: 'Biology',
            progress: 0.85,
            trend: 'stable',
            onTap: () => _openSubjectChart('Biology'),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Insights section
          Text('Quick Insights', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.md),

          const InsightCard(
            icon: Icons.trending_up,
            title: 'Strong Momentum',
            description: 'You\'ve studied 7 days in a row. Keep it up!',
          ),
          const SizedBox(height: AppSpacing.sm),
          const InsightCard(
            icon: Icons.lightbulb_outline,
            title: 'Peak Performance Time',
            description: 'Your focus is highest between 6-8 PM.',
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  /// Today's study summary card
  Widget _buildTodaySummaryCard() {
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
            'Today',
            style: AppTextStyles.label.copyWith(
              color: isDark
                  ? AppColorsDark.secondaryText
                  : AppColorsLight.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$_todayMinutes min',
            style: AppTextStyles.display.copyWith(fontSize: 28),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$_todayTests tests completed',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColorsDark.secondaryText
                  : AppColorsLight.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Matches the same navbar spacing used in Community.
    final topInset = FloatingProgressNav.height + AppSpacing.lg + AppSpacing.md;

    return Scaffold(
      backgroundColor: isDark
          ? AppColorsDark.background
          : AppColorsLight.background,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColorsDark.background
            : AppColorsLight.background,
        centerTitle: true,
        elevation: 0,
        forceMaterialTransparency: true,
        title: Text('Progress', style: AppTextStyles.bodyLarge),
      ),
      body: Stack(
        children: [
          _buildActiveScreen(topInset),

          // Floating navigation bar aligned exactly like Community.
          Positioned(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: FloatingProgressNav(
                  index: _selectedIndex,
                  onChanged: _onNavItemTapped,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
