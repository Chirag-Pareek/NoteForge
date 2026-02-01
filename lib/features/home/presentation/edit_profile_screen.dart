import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/widgets/app_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _schoolController = TextEditingController();
  final _gradeController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _schoolController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final uid = _auth.currentUser!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (!mounted) return;
      
      final data = doc.data();
      if (data != null) {
        _usernameController.text = data['username'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _schoolController.text = data['school'] ?? '';
        _gradeController.text = data['grade'] ?? '';
        _photoUrl = data['photoUrl'];
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_usernameController.text.trim().isEmpty) {
      _showSnackBar('Username cannot be empty');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update({
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'school': _schoolController.text.trim(),
        'grade': _gradeController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      
      _showSnackBar('Profile updated successfully');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      _showSnackBar('Failed to update profile');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleChangePhoto() {
    _showSnackBar('Photo upload feature coming soon');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final lightBg = isDark ? AppColorsDark.lightBackground : AppColorsLight.lightBackground;
    final primaryText = isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Profile', style: AppTextStyles.bodyLarge),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // Profile Photo
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
                                  color: primaryText.withAlpha((0.5 *255).toInt()),
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 48,
                            color: primaryText.withAlpha((0.5 *255).toInt()),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: primaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        hintText: 'Enter username',
                        controller: _usernameController,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Bio Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bio',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: primaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        hintText: 'Tell us about yourself',
                        controller: _bioController,
                        maxLines: 3,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // School/College Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'School / College',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: primaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        hintText: 'Enter institution name',
                        controller: _schoolController,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Grade/Year Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grade / Year',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: primaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        hintText: 'e.g., Class 12 or 2nd Year',
                        controller: _gradeController,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
    );
  }
}
