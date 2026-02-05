import 'package:flutter/material.dart';
import 'package:noteforge/core/theme/app_colors.dart';
import 'package:noteforge/core/theme/app_radius.dart';
import 'package:noteforge/core/theme/app_spacing.dart';
import 'package:noteforge/core/widgets/app_card.dart';

/// Connection tile with global profile summary and actions.
class ConnectionTile extends StatelessWidget {
  final String name;
  final String field;
  final String username;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final VoidCallback? onMessage;
  final VoidCallback? onRemove;

  const ConnectionTile({
    super.key,
    required this.name,
    required this.field,
    required this.username,
    this.onTap,
    this.onAdd,
    this.onMessage,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final lightBg =
        isDark ? AppColorsDark.lightBackground : AppColorsLight.lightBackground;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
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
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
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
                      field,
                      style: Theme.of(context).textTheme.bodySmall,
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
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _ActionPill(label: 'Add', onTap: onAdd),
              _ActionPill(label: 'Message', onTap: onMessage),
              _ActionPill(label: 'Remove', onTap: onRemove),
            ],
          ),
        ],
      ),
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

class _ActionPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _ActionPill({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      enableInk: true,
      borderRadius: BorderRadius.circular(AppRadius.full),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
