import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

/// NoteListCard
/// -------------
/// A reusable list-style card used to display a note item.
/// This widget is stateless because:
/// - It only shows data
/// - It does not manage or change state internally
class NoteListCard extends StatelessWidget {
  /// Main title of the note
  final String title;

  /// Subtitle or short description (e.g. date, subject)
  final String subtitle;

  /// Callback triggered when the card is tapped
  final VoidCallback onTap;

  const NoteListCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    /// Detect whether the current theme is dark or light
    final isDark = Theme.of(context).brightness == Brightness.dark;

    /// Theme-aware colors (kept consistent with your design system)
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    final backgroundColor = isDark
        ? AppColorsDark.background
        : AppColorsLight.background;

    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;

    /// InkWell provides:
    /// - Tap ripple effect
    /// - Gesture handling
    /// - Rounded splash matching card radius
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdBorder,
      child: Container(
        /// Internal spacing of the card
        padding: const EdgeInsets.all(AppSpacing.lg),

        /// Card styling
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: AppRadius.mdBorder,
        ),

        /// Horizontal layout:
        /// - Left: text content
        /// - Right: chevron icon
        child: Row(
          children: [
            /// Expanded ensures text takes all remaining space
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Note title
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  /// Note subtitle (lighter emphasis)
                  Text(
                    subtitle,
                    style: AppTextStyles.label.copyWith(color: secondaryText),
                  ),
                ],
              ),
            ),

            /// Right arrow icon to indicate navigation
            Icon(Icons.chevron_right, size: 20, color: secondaryText),
          ],
        ),
      ),
    );
  }
}
