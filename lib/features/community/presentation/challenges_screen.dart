import 'package:flutter/material.dart';
import 'package:noteforge/core/theme/app_colors.dart';
import 'package:noteforge/core/theme/app_radius.dart';
import 'package:noteforge/core/theme/app_spacing.dart';
import 'package:noteforge/core/widgets/app_card.dart';
import 'package:noteforge/core/widgets/section_header.dart';
import 'package:noteforge/features/community/presentation/widgets/challenge_card.dart';

/// Challenges screen with daily tasks, global battles, and timers.
class ChallengesScreen extends StatelessWidget {
  final double topPadding;

  const ChallengesScreen({
    super.key,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    const dailyChallenges = [
      _ChallengeItem(
        category: 'Daily',
        title: '30-minute Focus Sprint',
        subtitle: 'Complete flashcards without interruptions.',
        duration: '30 min',
        points: '+120 pts',
        icon: Icons.timer_outlined,
      ),
      _ChallengeItem(
        category: 'Daily',
        title: 'Summary Recall',
        subtitle: 'Write a 6-line summary from memory.',
        duration: '15 min',
        points: '+80 pts',
        icon: Icons.edit_note_outlined,
      ),
      _ChallengeItem(
        category: 'Daily',
        title: 'Quiz Accuracy',
        subtitle: 'Score 90%+ on a quick quiz set.',
        duration: '20 min',
        points: '+100 pts',
        icon: Icons.fact_check_outlined,
      ),
    ];

    const studyBattles = [
      _ChallengeItem(
        category: 'Battle',
        title: 'Speed Review Duel',
        subtitle: 'Compete with global peers on chapter highlights.',
        duration: '25 min',
        points: '+150 pts',
        icon: Icons.flash_on_outlined,
      ),
      _ChallengeItem(
        category: 'Battle',
        title: 'Focus Room Clash',
        subtitle: 'Stay active in a timed co-study room.',
        duration: '45 min',
        points: '+200 pts',
        icon: Icons.groups_outlined,
      ),
    ];

    const timers = [
      _TimerItem(
        title: 'Deep Work',
        subtitle: '50/10 cycle',
        icon: Icons.center_focus_strong_outlined,
      ),
      _TimerItem(
        title: 'Quick Review',
        subtitle: '25/5 cycle',
        icon: Icons.bolt_outlined,
      ),
      _TimerItem(
        title: 'Exam Prep',
        subtitle: '90/15 cycle',
        icon: Icons.school_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gridCount = width >= 1100
            ? 3
            : width >= 820
                ? 2
                : 1;
        final timerCount = width >= 900
            ? 3
            : width >= 680
                ? 2
                : 1;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                topPadding,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Challenges Hub',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Daily goals, global battles, and focus timers.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: const SliverToBoxAdapter(
                child: SectionHeader(title: 'Daily Challenges'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = dailyChallenges[index];
                    return ChallengeCard(
                      category: item.category,
                      title: item.title,
                      subtitle: item.subtitle,
                      duration: item.duration,
                      points: item.points,
                      icon: item.icon,
                    );
                  },
                  childCount: dailyChallenges.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridCount,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: width >= 1000 ? 1.35 : 1.45,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: const SliverToBoxAdapter(
                child: SectionHeader(title: 'Study Battles'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = studyBattles[index];
                    return ChallengeCard(
                      category: item.category,
                      title: item.title,
                      subtitle: item.subtitle,
                      duration: item.duration,
                      points: item.points,
                      icon: item.icon,
                    );
                  },
                  childCount: studyBattles.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridCount,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: width >= 1000 ? 1.35 : 1.45,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: const SliverToBoxAdapter(
                child: SectionHeader(title: 'Focus Timers'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _TimerCard(item: timers[index]),
                  childCount: timers.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: timerCount,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: width >= 900 ? 2.2 : 2.4,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: const SliverToBoxAdapter(
                child: SectionHeader(title: 'Score Preview'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              sliver: const SliverToBoxAdapter(
                child: _ScorePreviewCard(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChallengeItem {
  final String category;
  final String title;
  final String subtitle;
  final String duration;
  final String points;
  final IconData icon;

  const _ChallengeItem({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.points,
    required this.icon,
  });
}

class _TimerItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const _TimerItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _TimerCard extends StatelessWidget {
  final _TimerItem item;

  const _TimerCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final lightBg =
        isDark ? AppColorsDark.lightBackground : AppColorsLight.lightBackground;

    return AppCard(
      enableInk: false,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: lightBg,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: borderColor),
            ),
            child: Icon(item.icon, size: 20, color: Theme.of(context).iconTheme.color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              'Start',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScorePreviewCard extends StatelessWidget {
  const _ScorePreviewCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final fillColor =
        isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText;

    return AppCard(
      enableInk: false,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Score',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _ScoreMetric(
                label: 'Points',
                value: '1,280',
              ),
              const SizedBox(width: AppSpacing.lg),
              _ScoreMetric(
                label: 'Rank',
                value: '#12',
              ),
              const SizedBox(width: AppSpacing.lg),
              _ScoreMetric(
                label: 'Streak',
                value: '6d',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: borderColor),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.72,
                child: Container(
                  decoration: BoxDecoration(
                    color: fillColor.withAlpha((0.15 * 255).toInt()),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '72% of weekly goal achieved',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _ScoreMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ScoreMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
