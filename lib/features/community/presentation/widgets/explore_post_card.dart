import 'package:flutter/material.dart';
import 'package:noteforge/core/theme/app_colors.dart';
import 'package:noteforge/core/theme/app_radius.dart';
import 'package:noteforge/core/theme/app_spacing.dart';
import 'package:noteforge/core/widgets/app_card.dart';

/// Post card for the Explore knowledge feed.
class ExplorePostCard extends StatelessWidget {
  final String name;
  final String username;
  final String topic;
  final String preview;
  final int likes;
  final int comments;
  final int saves;

  const ExplorePostCard({
    super.key,
    required this.name,
    required this.username,
    required this.topic,
    required this.preview,
    required this.likes,
    required this.comments,
    required this.saves,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final lightBg =
        isDark ? AppColorsDark.lightBackground : AppColorsLight.lightBackground;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final hasBoundedHeight =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite;
        final previewLines = hasBoundedHeight
            ? (constraints.maxHeight < 200
                ? 2
                : constraints.maxHeight < 240
                    ? 3
                    : 4)
            : 4;
        final tagMaxWidth = constraints.maxWidth * 0.38;

        final avatar = Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: lightBg,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: Text(
            _initials(name),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );

        final nameBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '@$username',
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );

        final topicTag = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tagMaxWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              topic,
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );

        return AppCard(
          enableInk: false,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact) ...[
                Row(
                  children: [
                    avatar,
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: nameBlock),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                topicTag,
              ] else
                Row(
                  children: [
                    avatar,
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: nameBlock),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(child: topicTag),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              Text(
                preview,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: previewLines,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  _ActionStat(icon: Icons.favorite_border, value: likes),
                  _ActionStat(
                    icon: Icons.mode_comment_outlined,
                    value: comments,
                  ),
                  _ActionStat(icon: Icons.bookmark_border, value: saves),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(' ');
    if (parts.isEmpty) {
      return '';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _ActionStat extends StatelessWidget {
  final IconData icon;
  final int value;

  const _ActionStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).iconTheme.color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
