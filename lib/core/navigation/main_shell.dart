import 'package:flutter/material.dart';
import 'package:noteforge/features/home/presentation/profile_screen.dart';
import 'package:noteforge/features/home/presentation/study_hub_screen.dart';
import 'package:noteforge/features/community/presentation/community_home_screen.dart';
import 'package:noteforge/features/progress/presentation/progress_home_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
// import '../theme/app_text_styles.dart';
import '../../features/home/presentation/home_screen.dart';

// App shell that hosts the main tabs and bottom navigation.

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Currently selected tab index.
  int _selectedIndex = 0;

  // Screens rendered by the bottom navigation tabs.
  late final List<Widget> _screens;

  @override
  Widget build(BuildContext context) {
    // Resolve theme-aware colors for active/inactive states.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColorsDark.primaryText
        : AppColorsLight.primaryText;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    return Scaffold(
      // Keep tab state alive by stacking screens.
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        // Custom bottom bar with a top border.
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home tab
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              // label: 'Home',
              isActive: _selectedIndex == 0,
              onTap: () => setState(() => _selectedIndex = 0),
              activeColor: primaryText,
              inactiveColor: secondaryText,
            ),
            // Study tab
            _NavItem(
              icon: Icons.menu_book_outlined,
              activeIcon: Icons.menu_book,
              // label: 'Study',
              isActive: _selectedIndex == 1,
              onTap: () => setState(() => _selectedIndex = 1),
              activeColor: primaryText,
              inactiveColor: secondaryText,
            ),
            // Community tab
            _NavItem(
              icon: Icons.groups_2_outlined,
              activeIcon: Icons.groups_2_rounded,
              // label: 'Community',
              isActive: _selectedIndex == 2,
              onTap: () => setState(() => _selectedIndex = 2),
              activeColor: primaryText,
              inactiveColor: secondaryText,
            ),
            // Progress tab
            _NavItem(
              icon: Icons.show_chart_outlined,
              activeIcon: Icons.show_chart,
              // label: 'Progress',
              isActive: _selectedIndex == 3,
              onTap: () => setState(() => _selectedIndex = 3),
              activeColor: primaryText,
              inactiveColor: secondaryText,
            ),
            // Profile tab
            _NavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              // label: 'Profile',
              isActive: _selectedIndex == 4,
              onTap: () => setState(() => _selectedIndex = 4),
              activeColor: primaryText,
              inactiveColor: secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const StudyHubScreen(),
      const CommunityHomeScreen(),
      const ProgressHomeScreen(),
      const ProfileScreen(),
    ];
  }
}

// Single nav item widget for the bottom bar.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  // final String? label;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  // Pass in icons, label, state, and colors for rendering.
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    // this.label,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    // Choose color based on active state.
    final color = isActive ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon toggles between active/inactive variants.
            Icon(isActive ? activeIcon : icon, size: 26, color: color),
            const SizedBox(height: AppSpacing.xs),
            // Text(
            //   label!,
            //   style: AppTextStyles.label.copyWith(color: color, fontSize: 11),
            // ),
          ],
        ),
      ),
    );
  }
}
