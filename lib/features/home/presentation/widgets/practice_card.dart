import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

/// PracticeCard
/// -------------
/// A reusable clickable card used for practice actions
/// (e.g. MCQs, quizzes, exercises, tasks).
///
/// Stateless because:
/// - It only displays data
/// - All interaction is delegated via `onTap`
class PracticeCard extends StatelessWidget {
  /// Icon shown at the top of the card
  final IconData icon;

  /// Title text displayed below the icon
  final String title;

  /// Callback triggered when the card is tapped
  final VoidCallback onTap;

  const PracticeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    /// Detect current theme mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    /// Theme-aware colors from your design system
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    /// Light background used for icon container
    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;

    /// Main card background color
    final backgroundColor = isDark
        ? AppColorsDark.background
        : AppColorsLight.background;

    /// InkWell provides:
    /// - Tap detection
    /// - Ripple effect
    /// - Rounded splash matching card radius
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdBorder,
      child: Container(
        /// Internal spacing of the card
        padding: const EdgeInsets.all(AppSpacing.xl),

        /// Card visual styling
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: AppRadius.mdBorder,
        ),

        /// Vertical layout:
        /// - Icon container
        /// - Title text
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Icon wrapper (small rounded square)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: lightBg,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            /// Card title
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
