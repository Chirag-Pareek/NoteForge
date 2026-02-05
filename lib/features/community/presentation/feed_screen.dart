import 'package:flutter/material.dart';
import 'package:noteforge/core/theme/app_colors.dart';
import 'package:noteforge/core/theme/app_radius.dart';
import 'package:noteforge/core/theme/app_spacing.dart';
import 'package:noteforge/core/widgets/app_card.dart';
import 'package:noteforge/core/widgets/section_header.dart';
import 'package:noteforge/features/community/presentation/widgets/activity_tile.dart';

/// Community feed screen with global learning activity timeline.
class FeedScreen extends StatelessWidget {
  final double topPadding;

  const FeedScreen({
    super.key,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    const highlights = [
      _HighlightItem(
        title: 'Shared Notes',
        value: '18',
        caption: 'Uploads this week',
        icon: Icons.note_outlined,
      ),
      _HighlightItem(
        title: 'Challenge Wins',
        value: '5',
        caption: 'Global leaderboard climbs',
        icon: Icons.emoji_events_outlined,
      ),
      _HighlightItem(
        title: 'Progress Updates',
        value: '92%',
        caption: 'Average completion rate',
        icon: Icons.insights_outlined,
      ),
    ];

    const activities = [
      _ActivityItem(
        icon: Icons.note_add_outlined,
        title: 'Shared notes in Systems Biology',
        subtitle: 'Digestive system summary uploaded.',
        timeLabel: '2h ago',
        tag: 'Shared Notes',
      ),
      _ActivityItem(
        icon: Icons.emoji_events_outlined,
        title: 'Won the Micro-Quiz Sprint',
        subtitle: 'Perfect score in 6 minutes.',
        timeLabel: '5h ago',
        tag: 'Challenge Win',
      ),
      _ActivityItem(
        icon: Icons.timeline_outlined,
        title: 'Progress update: Organic Chemistry',
        subtitle: 'Reached 68% on Chapter 7.',
        timeLabel: 'Yesterday',
        tag: 'Progress Update',
      ),
      _ActivityItem(
        icon: Icons.menu_book_outlined,
        title: 'Published case study template',
        subtitle: 'New format for lab reports.',
        timeLabel: '2 days ago',
        tag: 'Shared Notes',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gridCount = width >= 1000
            ? 3
            : width >= 720
                ? 2
                : 1;
        final childAspect = width >= 1000 ? 2.6 : (width >= 720 ? 2.8 : 3.0);

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
                      'Global Learning Activity',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Updates from the worldwide network of learners.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: const SliverToBoxAdapter(
                child: SectionHeader(title: 'Highlights'),
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
                    final item = highlights[index];
                    return _HighlightCard(item: item);
                  },
                  childCount: highlights.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridCount,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: childAspect,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: const SliverToBoxAdapter(
                child: SectionHeader(title: 'Activity Timeline'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = activities[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: ActivityTile(
                        icon: item.icon,
                        title: item.title,
                        subtitle: item.subtitle,
                        timeLabel: item.timeLabel,
                        tag: item.tag,
                      ),
                    );
                  },
                  childCount: activities.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HighlightItem {
  final String title;
  final String value;
  final String caption;
  final IconData icon;

  const _HighlightItem({
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
  });
}

class _HighlightCard extends StatelessWidget {
  final _HighlightItem item;

  const _HighlightCard({required this.item});

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
                  item.value,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  item.caption,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String timeLabel;
  final String tag;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.tag,
  });
}
