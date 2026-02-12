import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../domain/profile_model.dart';
import 'controllers/profile_controller.dart';

/// EditProfileScreen
/// ------------------
/// Screen that allows the user to:
/// - View existing profile data from backend via ProfileController
/// - Edit username, bio, school, and grade
/// - Save updated data through profile controller/service
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  /// Controllers for editable text fields.
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _schoolController = TextEditingController();
  final _gradeController = TextEditingController();

  /// UI state flags.
  bool _isLoading = true; // while fetching profile data
  bool _isSaving = false; // while saving profile changes

  /// Existing remote photo URL from profile data.
  String? _photoUrl;

  /// Newly selected photo to upload (optional).
  XFile? _selectedPhoto;
  Uint8List? _selectedPhotoBytes;

  @override
  void initState() {
    super.initState();
    // Load and prefill form with current profile values.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _schoolController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  /// Fetches profile from controller and pre-fills form fields.
  Future<void> _loadUserData() async {
    final controller = context.read<ProfileController>();

    try {
      if (controller.profile == null) {
        await controller.loadProfile();
      }

      if (!mounted) return;

      final profile = controller.profile;
      if (profile != null) {
        _applyProfileToFields(profile);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Maps [ProfileModel] data into text field controllers.
  void _applyProfileToFields(ProfileModel profile) {
    _usernameController.text = profile.username;
    _bioController.text = profile.bio;
    _schoolController.text = profile.school;
    _gradeController.text = profile.grade;
    _photoUrl = profile.photoUrl.isEmpty ? null : profile.photoUrl;
  }

  /// Save updated profile data through the profile controller.
  Future<void> _saveProfile() async {
    if (_usernameController.text.trim().isEmpty) {
      _showSnackBar('Username cannot be empty');
      return;
    }

    final controller = context.read<ProfileController>();

    setState(() {
      _isSaving = true;
    });

    final success = await controller.updateProfile(
      displayName: controller.profile?.displayName,
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
      school: _schoolController.text.trim(),
      grade: _gradeController.text.trim(),
      photoFile: _selectedPhoto,
    );

    if (!mounted) return;

    if (success) {
      _showSnackBar('Profile updated successfully');
      Navigator.pop(context);
      return;
    } else {
      _showSnackBar(controller.errorMessage ?? 'Failed to update profile');
    }

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });
  }

  /// Simple SnackBar helper.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  /// Picks a new profile image from gallery for upload on save.
  Future<void> _handleChangePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1440,
      );

      if (pickedFile == null || !mounted) return;

      final bytes = await pickedFile.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedPhoto = pickedFile;
        _selectedPhotoBytes = bytes;
      });
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Could not select photo');
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Theme-aware colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;
    final primaryText = isDark
        ? AppColorsDark.primaryText
        : AppColorsLight.primaryText;

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
                    child: _selectedPhotoBytes != null
                        ? ClipOval(
                            child: Image.memory(
                              _selectedPhotoBytes!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (_photoUrl != null && _photoUrl!.isNotEmpty)
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
                            color: primaryText.withAlpha((0.5 * 255).toInt()),
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

  /// Small helper widget to avoid repeated label + field code.
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
