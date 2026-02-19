import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_outlined_button.dart';
import 'controllers/profile_controller.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stat_card.dart';
import 'widgets/profile_option_tile.dart';

/// ProfileScreen
/// -------------
/// Displays the user's profile information:
/// - Avatar
/// - Username & bio
/// - Stats (posts, followers, following)
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
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final secondaryText = isDark
            ? AppColorsDark.secondaryText
            : AppColorsLight.secondaryText;
        final primaryText = isDark
            ? AppColorsDark.primaryText
            : AppColorsLight.primaryText;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: AppCard(
            enableInk: false,
            borderRadius: AppRadius.lgBorder,
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: primaryText),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Log Out', style: AppTextStyles.titleMedium),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Are you sure you want to log out?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: secondaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: AppOutlinedButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.pop(dialogContext, false),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        label: 'Log Out',
                        onPressed: () => Navigator.pop(dialogContext, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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

    // Placeholder stats until social metrics are wired from backend.
    const posts = 24;
    const followers = 120;
    const following = 86;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = AppBreakpoints.pageHorizontalPadding(width);
        final maxWidth = AppBreakpoints.pageMaxContentWidth(width);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            forceMaterialTransparency: true,
            centerTitle: true,
            title: Text('Profile', style: AppTextStyles.bodyLarge),
            actions: [
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ProfileHeader(
                      photoUrl: photoUrl,
                      username: username,
                      bio: bio,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ProfileStatCard(value: '$posts', label: 'Posts'),
                          ProfileStatCard(
                            value: '$followers',
                            label: 'Followers',
                          ),
                          ProfileStatCard(
                            value: '$following',
                            label: 'Following',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        children: [
                          ProfileOptionTile(
                            icon: Icons.person_outline,
                            title: 'Edit Profile',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.profilEdit,
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ProfileOptionTile(
                            icon: Icons.lock_outline,
                            title: 'Privacy & Security',
                            onTap: () {},
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ProfileOptionTile(
                            icon: Icons.download_outlined,
                            title: 'Export Data',
                            onTap: () {},
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ProfileOptionTile(
                            icon: Icons.logout,
                            title: 'Log Out',
                            onTap: _handleLogout,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
