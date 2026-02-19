import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../home/domain/profile_model.dart';
import '../../home/presentation/controllers/profile_controller.dart';

/// Completes profile setup using the same backend/update flow as Edit Profile.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _schoolController = TextEditingController();
  final _gradeController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;

  String? _photoUrl;
  XFile? _selectedPhoto;
  Uint8List? _selectedPhotoBytes;

  @override
  void initState() {
    super.initState();
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

  void _applyProfileToFields(ProfileModel profile) {
    _usernameController.text = profile.username;
    _bioController.text = profile.bio;
    _schoolController.text = profile.school;
    _gradeController.text = profile.grade;
    _photoUrl = profile.photoUrl.isEmpty ? null : profile.photoUrl;
  }

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
      _showSnackBar('Could not select photo', isError: true);
    }
  }

  Future<void> _completeSetup() async {
    if (_usernameController.text.trim().isEmpty) {
      _showSnackBar('Username cannot be empty', isError: true);
      return;
    }

    final controller = context.read<ProfileController>();

    setState(() {
      _isSubmitting = true;
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
      _showSnackBar('Profile setup completed');
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
      return;
    }

    _showSnackBar(
      controller.errorMessage ?? 'Failed to complete profile setup',
      isError: true,
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isError
        ? (isDark ? AppColorsDark.error : AppColorsLight.error)
        : (isDark ? AppColorsDark.lightBackground : AppColorsLight.background);
    final textColor = isError
        ? Colors.white
        : (isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: textColor),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;
    final primaryText = isDark
        ? AppColorsDark.primaryText
        : AppColorsLight.primaryText;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = AppBreakpoints.pageHorizontalPadding(width);
        final maxWidth = AppBreakpoints.pageMaxContentWidth(width);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            centerTitle: true,
            forceMaterialTransparency: true,
            title: Text('Setup Profile', style: AppTextStyles.bodyLarge),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tell us more about you',
                            style: AppTextStyles.display,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'We need a few details to customize your experience.',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: secondaryText,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppCard(
                            borderRadius: AppRadius.mdBorder,
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              children: [
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: lightBg,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: borderColor,
                                      width: 2,
                                    ),
                                    boxShadow: AppEffects.subtleDepth(
                                      brightness,
                                    ),
                                  ),
                                  child: _selectedPhotoBytes != null
                                      ? ClipOval(
                                          child: Image.memory(
                                            _selectedPhotoBytes!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : (_photoUrl != null &&
                                            _photoUrl!.isNotEmpty)
                                      ? ClipOval(
                                          child: Image.network(
                                            _photoUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (_, error, stackTrace) {
                                                  return Icon(
                                                    Icons.person,
                                                    size: 48,
                                                    color: primaryText
                                                        .withAlpha(
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
                                AppButton(
                                  label: 'Upload Photo',
                                  onPressed: _handleChangePhoto,
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                _buildLabeledField(
                                  label: 'Username',
                                  hint: 'Enter username',
                                  controller: _usernameController,
                                  primaryText: primaryText,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _buildLabeledField(
                                  label: 'Bio',
                                  hint: 'Tell us about yourself',
                                  controller: _bioController,
                                  maxLines: 3,
                                  primaryText: primaryText,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _buildLabeledField(
                                  label: 'School / College',
                                  hint: 'Enter institution name',
                                  controller: _schoolController,
                                  primaryText: primaryText,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _buildLabeledField(
                                  label: 'Grade / Year',
                                  hint: 'e.g., Class 12 or 2nd Year',
                                  controller: _gradeController,
                                  primaryText: primaryText,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          AppButton(
                            label: 'Complete Setup',
                            isFullWidth: true,
                            isLoading: _isSubmitting,
                            onPressed: _isSubmitting ? null : _completeSetup,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildLabeledField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Color primaryText,
    int maxLines = 1,
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
