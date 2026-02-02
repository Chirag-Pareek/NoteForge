import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
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
/// - Firebase Auth → current user UID
/// - Firestore → users/{uid}
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Firebase Authentication instance
  final _auth = FirebaseAuth.instance;

  /// Firestore instance
  final _firestore = FirebaseFirestore.instance;

  /// Cached user document data from Firestore
  Map<String, dynamic>? _userData;

  /// Loading flag while fetching Firestore data
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load user data as soon as the screen is created
    _loadUserData();
  }

  /// Fetch user profile data from Firestore
  Future<void> _loadUserData() async {
    try {
      // Get currently logged-in user's UID
      final uid = _auth.currentUser!.uid;

      // Fetch Firestore document for this user
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!mounted) return;

      // Store user data and stop loading state
      setState(() {
        _userData = doc.data();
        _isLoading = false;
      });
    } catch (e) {
      // In case of error, stop loading to avoid infinite spinner
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handle user logout with confirmation dialog
  Future<void> _handleLogout() async {
    // Ask user for confirmation before logging out
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Out', style: AppTextStyles.titleMedium),
        content: Text(
          'Are you sure you want to log out?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          // Cancel logout
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),

          // Confirm logout
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

    // If user confirmed logout
    if (shouldLogout == true) {
      await _auth.signOut();

      if (!mounted) return;

      // Navigate to login screen and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Theme-aware border color
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? AppColorsDark.border : AppColorsLight.border;

    /// Loading UI while Firestore data is being fetched
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Text('Profile', style: AppTextStyles.bodyLarge),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    /// Extract user fields with fallbacks
    final username = _userData?['username'] ?? 'User';
    final bio =
        _userData?['bio'] ??
        'Class 12 • Science Stream\nAspiring Engineer';
    final streak = _userData?['streak'] ?? 7;
    final tests = _userData?['tests'] ?? 24;
    final wins = _userData?['wins'] ?? 12;
    final photoUrl = _userData?['photoUrl'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Profile', style: AppTextStyles.bodyLarge),

        // More options icon (currently unused)
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // =====================
            // Profile Header Section
            // =====================
            ProfileHeader(
              photoUrl: photoUrl,
              username: username,
              bio: bio,
            ),

            const SizedBox(height: AppSpacing.xl),

            // =====================
            // Stats Row (Streak, Tests, Wins)
            // =====================
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ProfileStatCard(
                    value: '$streak 🔥',
                    label: 'Streak',
                  ),
                  ProfileStatCard(
                    value: '$tests',
                    label: 'Tests',
                  ),
                  ProfileStatCard(
                    value: '$wins',
                    label: 'Wins',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // =====================
            // Profile Options Menu
            // =====================
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderColor),
                ),
              ),
              child: Column(
                children: [
                  // Edit Profile
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
