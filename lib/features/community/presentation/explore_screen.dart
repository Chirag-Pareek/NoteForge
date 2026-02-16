import 'package:flutter/material.dart';
import 'package:noteforge/core/theme/app_spacing.dart';
import 'package:noteforge/core/widgets/app_text_field.dart';
import 'package:noteforge/core/widgets/section_header.dart';
import 'package:noteforge/features/community/presentation/widgets/explore_post_card.dart';

/// Explore screen with public knowledge sharing posts.
class ExploreScreen extends StatelessWidget {
  final double topPadding;

  const ExploreScreen({super.key, required this.topPadding});

  @override
  Widget build(BuildContext context) {
    final posts = [
      _ExplorePost(
        name: 'Nora Alvarez',
        username: 'nora.research',
        profileImageUrl: 'https://i.pravatar.cc/160?img=32',
        program: 'MSc Molecular Biology',
        topic: 'Biology',
        preview:
            'Compiled a clean summary of CRISPR workflows with annotated diagrams and quick recall prompts.',
        likes: 142,
        comments: 18,
        saves: 76,
        publishedAt: '2h ago',
        readTime: '6 min read',
        resourceCount: 12,
      ),
      _ExplorePost(
        name: 'Rohan Iqbal',
        username: 'rohan.cs',
        profileImageUrl: 'https://i.pravatar.cc/160?img=15',
        program: 'BTech Computer Science',
        topic: 'Computer Science',
        preview:
            'Shared a modular solution for graph traversal problems with complexity notes and edge cases.',
        likes: 221,
        comments: 32,
        saves: 109,
        publishedAt: '4h ago',
        readTime: '8 min read',
        resourceCount: 9,
      ),
      _ExplorePost(
        name: 'Sofia Mendes',
        username: 'sofia.quant',
        profileImageUrl: 'https://i.pravatar.cc/160?img=5',
        program: 'MBA Finance',
        topic: 'Finance',
        preview:
            'Exam strategy for valuation questions: heuristics, common pitfalls, and a 10-minute checklist.',
        likes: 96,
        comments: 11,
        saves: 54,
        publishedAt: 'Yesterday',
        readTime: '5 min read',
        resourceCount: 7,
      ),
      _ExplorePost(
        name: 'Tariq Malik',
        username: 'tariq.notes',
        profileImageUrl: 'https://i.pravatar.cc/160?img=12',
        program: 'BSc Mathematics',
        topic: 'Mathematics',
        preview:
            'Problem breakdown on Laplace transforms with step-by-step intuition notes.',
        likes: 188,
        comments: 24,
        saves: 91,
        publishedAt: '1d ago',
        readTime: '7 min read',
        resourceCount: 10,
      ),
      _ExplorePost(
        name: 'Elena Park',
        username: 'elena.ucx',
        profileImageUrl: 'https://i.pravatar.cc/160?img=47',
        program: 'BSc Chemistry',
        topic: 'Chemistry',
        preview:
            'Study sheet on reaction mechanisms and how to spot shortcuts quickly.',
        likes: 74,
        comments: 9,
        saves: 33,
        publishedAt: '2d ago',
        readTime: '4 min read',
        resourceCount: 6,
      ),
      _ExplorePost(
        name: 'Kai Johnson',
        username: 'kai.builds',
        profileImageUrl: 'https://i.pravatar.cc/160?img=53',
        program: 'Mechanical Engineering',
        topic: 'Engineering',
        preview:
            'Shared a Notion-style lab report template for mechanical design reviews.',
        likes: 129,
        comments: 16,
        saves: 63,
        publishedAt: '3d ago',
        readTime: '9 min read',
        resourceCount: 11,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 820;
        final gridCount = width >= 1200 ? 3 : 2;
        final aspectRatio = width >= 1200 ? 1.4 : 1.6;

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
                      'Explore Knowledge',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Public notes, solutions, and research summaries from the global network.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const AppTextField(
                      hintText: 'Search topics, tags, or students',
                      suffixIcon: Icon(Icons.search),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: const SliverToBoxAdapter(
                child: SectionHeader(title: 'Featured Posts'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              sliver: isMobile
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final post = posts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: ExplorePostCard(
                            name: post.name,
                            username: post.username,
                            profileImageUrl: post.profileImageUrl,
                            program: post.program,
                            topic: post.topic,
                            preview: post.preview,
                            likes: post.likes,
                            comments: post.comments,
                            saves: post.saves,
                            publishedAt: post.publishedAt,
                            readTime: post.readTime,
                            resourceCount: post.resourceCount,
                          ),
                        );
                      }, childCount: posts.length),
                    )
                  : SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final post = posts[index];
                        return ExplorePostCard(
                          name: post.name,
                          username: post.username,
                          profileImageUrl: post.profileImageUrl,
                          program: post.program,
                          topic: post.topic,
                          preview: post.preview,
                          likes: post.likes,
                          comments: post.comments,
                          saves: post.saves,
                          publishedAt: post.publishedAt,
                          readTime: post.readTime,
                          resourceCount: post.resourceCount,
                        );
                      }, childCount: posts.length),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridCount,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: aspectRatio,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ExplorePost {
  final String name;
  final String username;
  final String profileImageUrl;
  final String program;
  final String topic;
  final String preview;
  final int likes;
  final int comments;
  final int saves;
  final String publishedAt;
  final String readTime;
  final int resourceCount;

  _ExplorePost({
    required this.name,
    required this.username,
    required this.profileImageUrl,
    required this.program,
    required this.topic,
    required this.preview,
    required this.likes,
    required this.comments,
    required this.saves,
    required this.publishedAt,
    required this.readTime,
    required this.resourceCount,
  });
}
