import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

/// ProfileHeader
/// -------------
/// Top section of the Profile screen.
///
/// Responsibilities:
/// - Display user profile photo (or fallback icon)
/// - Show username
/// - Show short bio
///
/// This widget is **pure UI** (no Firebase / no state).
class ProfileHeader extends StatelessWidget {
  /// Optional profile photo URL from Firestore
  /// If null → fallback icon is shown
  final String? photoUrl;

  /// User display name
  final String username;

  /// Short bio / description shown under username
  final String bio;

  const ProfileHeader({
    super.key,
    this.photoUrl,
    required this.username,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    /// Detect current theme mode (dark / light)
    final isDark = Theme.of(context).brightness == Brightness.dark;

    /// Border color adapts to theme
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    /// Light background used behind avatar
    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;

    /// Secondary text color (used for bio)
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;

    /// Primary text color (used for icons)
    final primaryText = isDark
        ? AppColorsDark.primaryText
        : AppColorsLight.primaryText;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        children: [
          // =========================
          // Profile Photo Section
          // =========================
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: lightBg,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
            ),

            // If photoUrl exists → load image
            // Else → show default user icon
            child: photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      photoUrl!,
                      fit: BoxFit.cover,

                      // If image fails to load → fallback icon
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 48,
                          color: primaryText.withAlpha((0.5 * 255).toInt()),
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

          const SizedBox(height: AppSpacing.lg),

          // =========================
          // Username
          // =========================
          Text(
            username,
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.sm),

          // =========================
          // Bio / Description
          // =========================
          Text(
            bio,
            style: AppTextStyles.bodyMedium.copyWith(color: secondaryText),
            textAlign: TextAlign.center,

            // Prevents layout break for long bios
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
