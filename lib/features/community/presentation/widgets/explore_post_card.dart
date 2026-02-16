import 'package:flutter/material.dart';
import 'package:noteforge/core/theme/app_colors.dart';
import 'package:noteforge/core/theme/app_radius.dart';
import 'package:noteforge/core/theme/app_spacing.dart';
import 'package:noteforge/core/widgets/app_card.dart';

/// Post card for the Explore knowledge feed.
class ExplorePostCard extends StatelessWidget {
  final String name;
  final String username;
  final String? profileImageUrl;
  final String? program;
  final String topic;
  final String preview;
  final int likes;
  final int comments;
  final int saves;
  final String? publishedAt;
  final String? readTime;
  final int? resourceCount;

  const ExplorePostCard({
    super.key,
    required this.name,
    required this.username,
    this.profileImageUrl,
    this.program,
    required this.topic,
    required this.preview,
    required this.likes,
    required this.comments,
    required this.saves,
    this.publishedAt,
    this.readTime,
    this.resourceCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;

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
          clipBehavior: Clip.antiAlias,
          child: profileImageUrl != null
              ? Image.network(
                  profileImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _AvatarFallback(name: name);
                  },
                )
              : _AvatarFallback(name: name),
        );

        final programText = (program ?? '').trim();
        final hasProgram = programText.isNotEmpty;
        final hasMeta =
            (publishedAt ?? '').isNotEmpty ||
            (readTime ?? '').isNotEmpty ||
            (resourceCount != null);

        final metaItems = <String>[
          if ((publishedAt ?? '').isNotEmpty) publishedAt!,
          if ((readTime ?? '').isNotEmpty) readTime!,
          if (resourceCount != null)
            '$resourceCount resource${resourceCount == 1 ? '' : 's'}',
        ];

        final titleStyle = Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600);
        final subtitleStyle = Theme.of(context).textTheme.labelSmall;

        final nameBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: titleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '@$username',
              style: subtitleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (hasProgram) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                programText,
                style: subtitleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
              color: lightBg,
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
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    topicTag,
                    if (hasMeta) _MetaChip(label: metaItems.join(' - ')),
                  ],
                ),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    avatar,
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: nameBlock),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          topicTag,
                          if (hasMeta) ...[
                            const SizedBox(height: AppSpacing.xs),
                            _MetaChip(label: metaItems.join(' - ')),
                          ],
                        ],
                      ),
                    ),
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
}

class _AvatarFallback extends StatelessWidget {
  final String name;

  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _initials(name),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) {
      return '';
    }
    if (parts.length == 1 || parts.last.isEmpty) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _MetaChip extends StatelessWidget {
  final String label;

  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: borderColor),
        color: lightBg,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
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
        Text(value.toString(), style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
