import 'package:flutter/material.dart';
import 'package:noteforge/core/theme/app_radius.dart';
import 'package:noteforge/core/theme/app_spacing.dart';
import 'package:noteforge/core/widgets/app_button.dart';
import 'package:noteforge/core/widgets/app_card.dart';

/// Clean modal preview for a connection profile.
class ProfilePreviewModal extends StatelessWidget {
  final String name;
  final String field;
  final String username;
  final String? profileImageUrl;
  final String headline;
  final List<String> focusTags;

  const ProfilePreviewModal({
    super.key,
    required this.name,
    required this.field,
    required this.username,
    this.profileImageUrl,
    required this.headline,
    required this.focusTags,
  });

  static Future<void> show(
    BuildContext context, {
    required String name,
    required String field,
    required String username,
    String? profileImageUrl,
    required String headline,
    required List<String> focusTags,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfilePreviewModal(
        name: name,
        field: field,
        username: username,
        profileImageUrl: profileImageUrl,
        headline: headline,
        focusTags: focusTags,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppCard(
          enableInk: false,
          borderRadius: AppRadius.lgBorder,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            Theme.of(context).dividerTheme.color ??
                            Theme.of(context).colorScheme.outline,
                      ),
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
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          field,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '@$username',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(headline, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: focusTags
                    .map(
                      (tag) => AppCard(
                        enableInk: false,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        child: Text(
                          tag,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Message',
                      onPressed: () {},
                      isFullWidth: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'Connect',
                      onPressed: () {},
                      isFullWidth: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
        style: Theme.of(context).textTheme.bodyLarge,
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
