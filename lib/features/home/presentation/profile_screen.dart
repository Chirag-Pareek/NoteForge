import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import 'controllers/profile_controller.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stat_card.dart';
import 'widgets/profile_option_tile.dart';

/// ProfileScreen
/// -------------
/// Displays the user's profile information:
/// - Avatar
/// - Username & bio
/// - Stats (streak, tests, wins)
/// - Profile-related actions (edit, logout, etc.)
///
/// Data source:
/// - ProfileController (Firebase-backed realtime profile state)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Firebase Authentication instance (used for logout).
  final _auth = FirebaseAuth.instance;

  ProfileController? _profileController;

  @override
  void initState() {
    super.initState();

    // Connect this screen to backend profile state when the widget is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = context.read<ProfileController>();
      _profileController = controller;

      // Load once, then continue listening for realtime Firestore changes.
      controller.loadProfile();
      controller.startProfileListener();
    });
  }

  @override
  void dispose() {
    _profileController?.stopProfileListener();
    super.dispose();
  }

  /// Handle user logout with confirmation dialog.
  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Out', style: AppTextStyles.titleMedium),
        content: Text(
          'Are you sure you want to log out?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Log Out',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColorsLight.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _auth.signOut();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();

    /// Theme-aware border color
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    /// Loading UI while profile data is being fetched.
    if (controller.isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Text('Profile', style: AppTextStyles.bodyLarge),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Replace hardcoded profile header values with controller-backed data.
    final profile = controller.profile;
    final username = (profile?.username.isNotEmpty ?? false)
        ? profile!.username
        : 'User';

    final rawBio = profile?.bio ?? '';
    final rawSchool = profile?.school ?? '';
    final rawGrade = profile?.grade ?? '';

    String bio = rawBio.trim();
    if (bio.isEmpty) {
      final schoolGrade = <String>[
        if (rawGrade.trim().isNotEmpty) rawGrade.trim(),
        if (rawSchool.trim().isNotEmpty) rawSchool.trim(),
      ];
      bio = schoolGrade.isEmpty ? 'No bio added yet' : schoolGrade.join(' - ');
    }

    final photoUrl = (profile?.photoUrl.isNotEmpty ?? false)
        ? profile!.photoUrl
        : null;

    // Existing stat cards remain unchanged since they are not part of ProfileModel.
    const streak = 7;
    const tests = 24;
    const wins = 12;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Profile', style: AppTextStyles.bodyLarge),

        // More options icon (currently unused)
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // =====================
            // Profile Header Section
            // =====================
            ProfileHeader(photoUrl: photoUrl, username: username, bio: bio),

            const SizedBox(height: AppSpacing.xl),

            // =====================
            // Stats Row (Streak, Tests, Wins)
            // =====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ProfileStatCard(value: '$streak', label: 'Streak'),
                  ProfileStatCard(value: '$tests', label: 'Tests'),
                  ProfileStatCard(value: '$wins', label: 'Wins'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // =====================
            // Profile Options Menu
            // =====================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Column(
                children: [
                  // Edit Profile
                  ProfileOptionTile(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.profilEdit);
                    },
                  ),

                  // Privacy & Security
                  ProfileOptionTile(
                    icon: Icons.lock_outline,
                    title: 'Privacy & Security',
                    onTap: () {},
                  ),

                  // Export Data
                  ProfileOptionTile(
                    icon: Icons.download_outlined,
                    title: 'Export Data',
                    onTap: () {},
                  ),

                  // Logout (destructive action)
                  ProfileOptionTile(
                    icon: Icons.logout,
                    title: 'Log Out',
                    isDestructive: true,
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
