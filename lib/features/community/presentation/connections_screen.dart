import 'package:flutter/material.dart';
import 'package:noteforge/core/theme/app_spacing.dart';
import 'package:noteforge/core/widgets/app_text_field.dart';
import 'package:noteforge/core/widgets/section_header.dart';
import 'package:noteforge/features/community/presentation/widgets/connection_tile.dart';
import 'package:noteforge/features/community/presentation/widgets/profile_preview_modal.dart';

/// Connections screen for the global student network.
class ConnectionsScreen extends StatelessWidget {
  final double topPadding;

  const ConnectionsScreen({super.key, required this.topPadding});

  @override
  Widget build(BuildContext context) {
    final requests = [
      _ConnectionProfile(
        name: 'Avery Collins',
        field: 'Computational Biology',
        username: 'avery.codes',
        profileImageUrl: 'https://i.pravatar.cc/160?img=23',
        headline: 'Researching genome-scale modeling and analytics.',
        focusTags: const ['Biology', 'Data', 'Modeling'],
        mutualConnections: 18,
        lastActive: 'Active 12m ago',
      ),
      _ConnectionProfile(
        name: 'Lucas Patel',
        field: 'Mechanical Engineering',
        username: 'lucas.p',
        profileImageUrl: 'https://i.pravatar.cc/160?img=13',
        headline: 'Focused on materials science and CAD workflows.',
        focusTags: const ['Engineering', 'CAD', 'Materials'],
        mutualConnections: 12,
        lastActive: 'Active 1h ago',
      ),
    ];

    final connections = [
      _ConnectionProfile(
        name: 'Maya Chen',
        field: 'AI & Machine Learning',
        username: 'maya.learns',
        profileImageUrl: 'https://i.pravatar.cc/160?img=28',
        headline: 'Building ML study groups and notebook libraries.',
        focusTags: const ['AI', 'ML', 'Python'],
        mutualConnections: 27,
        lastActive: 'Active now',
      ),
      _ConnectionProfile(
        name: 'Ethan Brooks',
        field: 'Finance & Analytics',
        username: 'ethan.quant',
        profileImageUrl: 'https://i.pravatar.cc/160?img=57',
        headline: 'Exploring financial modeling and valuation.',
        focusTags: const ['Finance', 'Excel', 'Valuation'],
        mutualConnections: 9,
        lastActive: 'Active 3h ago',
      ),
      _ConnectionProfile(
        name: 'Zara Nunez',
        field: 'Clinical Psychology',
        username: 'zara.psych',
        profileImageUrl: 'https://i.pravatar.cc/160?img=35',
        headline: 'Synthesizing research summaries for labs.',
        focusTags: const ['Psychology', 'Research', 'Labs'],
        mutualConnections: 14,
        lastActive: 'Active 5h ago',
      ),
      _ConnectionProfile(
        name: 'Noah Singh',
        field: 'Product Design',
        username: 'noah.designs',
        profileImageUrl: 'https://i.pravatar.cc/160?img=64',
        headline: 'Designing knowledge systems and study flows.',
        focusTags: const ['Design', 'UX', 'Systems'],
        mutualConnections: 21,
        lastActive: 'Active yesterday',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gridCount = width >= 1100
            ? 3
            : width >= 760
            ? 2
            : 1;
        final isSingleColumn = gridCount == 1;
        final gridChildAspectRatio = width >= 1200
            ? 1.42
            : width >= 900
            ? 1.28
            : 1.16;

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
                      'Global Connections',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Build your professional learning network worldwide.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const AppTextField(
                      hintText: 'Search by username, subject, or program',
                      suffixIcon: Icon(Icons.search),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: const SliverToBoxAdapter(
                child: SectionHeader(title: 'Incoming Requests'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final profile = requests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ConnectionTile(
                      name: profile.name,
                      field: profile.field,
                      username: profile.username,
                      profileImageUrl: profile.profileImageUrl,
                      headline: profile.headline,
                      focusTags: profile.focusTags,
                      mutualConnections: profile.mutualConnections,
                      lastActive: profile.lastActive,
                      onTap: () => _openPreview(context, profile),
                      onAdd: () {},
                      onMessage: () {},
                      onRemove: () {},
                    ),
                  );
                }, childCount: requests.length),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: const SliverToBoxAdapter(
                child: SectionHeader(title: 'Your Connections'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              sliver: isSingleColumn
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final profile = connections[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: ConnectionTile(
                            name: profile.name,
                            field: profile.field,
                            username: profile.username,
                            profileImageUrl: profile.profileImageUrl,
                            headline: profile.headline,
                            focusTags: profile.focusTags,
                            mutualConnections: profile.mutualConnections,
                            lastActive: profile.lastActive,
                            onTap: () => _openPreview(context, profile),
                            onAdd: () {},
                            onMessage: () {},
                            onRemove: () {},
                          ),
                        );
                      }, childCount: connections.length),
                    )
                  : SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final profile = connections[index];
                        return ConnectionTile(
                          name: profile.name,
                          field: profile.field,
                          username: profile.username,
                          profileImageUrl: profile.profileImageUrl,
                          headline: profile.headline,
                          focusTags: profile.focusTags,
                          mutualConnections: profile.mutualConnections,
                          lastActive: profile.lastActive,
                          onTap: () => _openPreview(context, profile),
                          onAdd: () {},
                          onMessage: () {},
                          onRemove: () {},
                        );
                      }, childCount: connections.length),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridCount,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: gridChildAspectRatio,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _openPreview(BuildContext context, _ConnectionProfile profile) {
    ProfilePreviewModal.show(
      context,
      name: profile.name,
      field: profile.field,
      username: profile.username,
      profileImageUrl: profile.profileImageUrl,
      headline: profile.headline,
      focusTags: profile.focusTags,
    );
  }
}

class _ConnectionProfile {
  final String name;
  final String field;
  final String username;
  final String profileImageUrl;
  final String headline;
  final List<String> focusTags;
  final int mutualConnections;
  final String lastActive;

  _ConnectionProfile({
    required this.name,
    required this.field,
    required this.username,
    required this.profileImageUrl,
    required this.headline,
    required this.focusTags,
    required this.mutualConnections,
    required this.lastActive,
  });
}
