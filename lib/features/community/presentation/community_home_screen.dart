import 'package:flutter/material.dart';
import 'package:noteforge/core/theme/app_spacing.dart';
import 'package:noteforge/features/community/presentation/challenges_screen.dart';
import 'package:noteforge/features/community/presentation/connections_screen.dart';
import 'package:noteforge/features/community/presentation/explore_screen.dart';
import 'package:noteforge/features/community/presentation/feed_screen.dart';
import 'package:noteforge/features/community/presentation/widgets/floating_community_nav.dart';

/// CommunityHomeScreen hosts the floating nav + swipeable community tabs.
/// UI-only structure designed for future realtime data sources.
class CommunityHomeScreen extends StatefulWidget {
  const CommunityHomeScreen({super.key});

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends State<CommunityHomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNavTap(int index) {
    if (index == _currentIndex) {
      return;
    }
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset =
        FloatingCommunityNav.height + AppSpacing.lg + AppSpacing.md;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Community',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: [
              FeedScreen(topPadding: topInset),
              ChallengesScreen(topPadding: topInset),
              ConnectionsScreen(topPadding: topInset),
              ExploreScreen(topPadding: topInset),
            ],
          ),
          Positioned(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: FloatingCommunityNav(
                  index: _currentIndex,
                  onChanged: _handleNavTap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
