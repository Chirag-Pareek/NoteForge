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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final uid = _auth.currentUser!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (!mounted) return;
      
      setState(() {
        _userData = doc.data();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
    }
  }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

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

    final username = _userData?['username'] ?? 'User';
    final bio = _userData?['bio'] ?? 'Class 12 • Science Stream\nAspiring Engineer';
    final streak = _userData?['streak'] ?? 7;
    final tests = _userData?['tests'] ?? 24;
    final wins = _userData?['wins'] ?? 12;
    final photoUrl = _userData?['photoUrl'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Profile', style: AppTextStyles.bodyLarge),
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
            // Profile Header
            ProfileHeader(
              photoUrl: photoUrl,
              username: username,
              bio: bio,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
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

            // Options Menu
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderColor),
                ),
              ),
              child: Column(
                children: [
                  ProfileOptionTile(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.profilEdit);
                    },
                  ),
                  ProfileOptionTile(
                    icon: Icons.lock_outline,
                    title: 'Privacy & Security',
                    onTap: () {},
                  ),
                  ProfileOptionTile(
                    icon: Icons.download_outlined,
                    title: 'Export Data',
                    onTap: () {},
                  ),
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
