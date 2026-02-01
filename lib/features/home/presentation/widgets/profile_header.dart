import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final String? photoUrl;
  final String username;
  final String bio;

  const ProfileHeader({
    super.key,
    this.photoUrl,
    required this.username,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
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
          // Profile Photo
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: lightBg,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
            ),
            child: photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      photoUrl!,
                      fit: BoxFit.cover,
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

          // Username
          Text(
            username,
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.sm),

          // Bio
          Text(
            bio,
            style: AppTextStyles.bodyMedium.copyWith(color: secondaryText),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
