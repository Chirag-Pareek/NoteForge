import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

/// ProfileOptionTile
/// ------------------
/// Reusable row-style option used on the Profile screen.
///
/// Examples:
/// - Edit Profile
/// - Privacy & Security
/// - Export Data
/// - Log Out
///
/// Supports a destructive mode (red color) for dangerous actions like logout.
class ProfileOptionTile extends StatelessWidget {
  /// Leading icon shown on the left
  final IconData icon;

  /// Main text label of the option
  final String title;

  /// Callback executed when the tile is tapped
  final VoidCallback onTap;

  /// Marks the option as destructive (e.g. Log Out)
  /// When true, icon & text turn red
  final bool isDestructive;

  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    /// Detect current theme mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    /// Divider/border color adapts to theme
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    /// Default primary text color based on theme
    final primaryText = isDark
        ? AppColorsDark.primaryText
        : AppColorsLight.primaryText;

    /// Error color (used for destructive actions)
    /// Note: Error color is usually same in both themes
    final errorColor = AppColorsLight.error;

    /// Decide text color based on destructive state
    final textColor = isDestructive ? errorColor : primaryText;

    /// Decide icon color based on destructive state
    final iconColor = isDestructive ? errorColor : primaryText;

    /// InkWell provides ripple effect on tap
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          // Bottom border to separate each option visually
          border: Border(bottom: BorderSide(color: borderColor)),
        ),
        child: Row(
          children: [
            // -----------------------
            // Leading Icon
            // -----------------------
            Icon(icon, size: 20, color: iconColor),

            const SizedBox(width: AppSpacing.md),

            // -----------------------
            // Option Title
            // -----------------------
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // -----------------------
            // Trailing Chevron
            // -----------------------
            Icon(Icons.chevron_right, size: 20, color: iconColor),
          ],
        ),
      ),
    );
  }
}
