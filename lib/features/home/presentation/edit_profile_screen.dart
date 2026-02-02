import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

/// EditProfileScreen
/// ------------------
/// Screen that allows the user to:
/// - View existing profile data from Firestore
/// - Edit username, bio, school, and grade
/// - Save updated data back to Firestore
///
/// Data source:
/// - Firebase Authentication → current user UID
/// - Cloud Firestore → users/{uid}
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  /// Firebase Auth instance (used to get current user UID)
  final _auth = FirebaseAuth.instance;

  /// Firestore instance (used to read/write user profile)
  final _firestore = FirebaseFirestore.instance;

  /// Controllers for editable text fields
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _schoolController = TextEditingController();
  final _gradeController = TextEditingController();

  /// UI state flags
  bool _isLoading = true; // while fetching user data
  bool _isSaving = false; // while saving profile changes

  /// Optional profile photo URL from Firestore
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    // Load existing user data when screen opens
    _loadUserData();
  }

  @override
  void dispose() {
    // Dispose all controllers to avoid memory leaks
    _usernameController.dispose();
    _bioController.dispose();
    _schoolController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  /// Fetch user profile data from Firestore
  Future<void> _loadUserData() async {
    try {
      // Get current logged-in user's UID
      final uid = _auth.currentUser!.uid;

      // Fetch user document from Firestore
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!mounted) return;

      final data = doc.data();

      // Populate text fields with Firestore values
      if (data != null) {
        _usernameController.text = data['username'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _schoolController.text = data['school'] ?? '';
        _gradeController.text = data['grade'] ?? '';
        _photoUrl = data['photoUrl'];
      }

      // Stop loading spinner
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Even if error occurs, stop loading UI
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Save updated profile data to Firestore
  Future<void> _saveProfile() async {
    // Basic validation
    if (_usernameController.text.trim().isEmpty) {
      _showSnackBar('Username cannot be empty');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final uid = _auth.currentUser!.uid;

      // Update Firestore document
      await _firestore.collection('users').doc(uid).update({
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'school': _schoolController.text.trim(),
        'grade': _gradeController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Show success feedback
      _showSnackBar('Profile updated successfully');

      // Close Edit Profile screen
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      // Show failure feedback
      _showSnackBar('Failed to update profile');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Simple SnackBar helper
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Placeholder for future photo upload feature
  void _handleChangePhoto() {
    _showSnackBar('Photo upload feature coming soon');
  }

  @override
  Widget build(BuildContext context) {
    /// Theme-aware colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? AppColorsDark.border : AppColorsLight.border;
    final lightBg =
        isDark ? AppColorsDark.lightBackground : AppColorsLight.lightBackground;
    final primaryText =
        isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,

        // Back navigation
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text('Edit Profile', style: AppTextStyles.bodyLarge),

        // Save button in AppBar
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: Text(
                'Save',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _isSaving ? null : primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),

      /// Show loader until user data is fetched
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // Profile Photo Circle
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: lightBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: _photoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              _photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 48,
                                  color: primaryText.withAlpha(
                                    (0.5 * 255).toInt(),
                                  ),
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 48,
                            color: primaryText.withAlpha(
                              (0.5 * 255).toInt(),
                            ),
                          ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Change Photo Button
                  AppButton(
                    label: 'Change Photo',
                    onPressed: _handleChangePhoto,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Username Field
                  _buildLabeledField(
                    label: 'Username',
                    controller: _usernameController,
                    hint: 'Enter username',
                    primaryText: primaryText,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Bio Field
                  _buildLabeledField(
                    label: 'Bio',
                    controller: _bioController,
                    hint: 'Tell us about yourself',
                    maxLines: 3,
                    primaryText: primaryText,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // School Field
                  _buildLabeledField(
                    label: 'School / College',
                    controller: _schoolController,
                    hint: 'Enter institution name',
                    primaryText: primaryText,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Grade Field
                  _buildLabeledField(
                    label: 'Grade / Year',
                    controller: _gradeController,
                    hint: 'e.g., Class 12 or 2nd Year',
                    primaryText: primaryText,
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
    );
  }

  /// Small helper widget to avoid repeated label + field code
  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    required Color primaryText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          hintText: hint,
          controller: controller,
          maxLines: maxLines,
        ),
      ],
    );
  }
}
