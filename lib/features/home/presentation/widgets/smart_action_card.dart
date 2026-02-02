import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

/// SmartActionCard
/// ----------------
/// A small reusable card used in grids (like Study Hub → Smart Actions)
///
/// Purpose:
/// - Show an icon + label
/// - Trigger an action when tapped
///
/// Design goals:
/// - Theme-aware (light / dark)
/// - Compact size
/// - Reusable across multiple screens
class SmartActionCard extends StatelessWidget {
  /// Icon shown at the top of the card
  final IconData icon;

  /// Text label shown below the icon
  final String label;

  /// Callback triggered when the card is tapped
  final VoidCallback onTap;

  const SmartActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    /// Check if current theme is dark or light
    final isDark = Theme.of(context).brightness == Brightness.dark;

    /// Theme-aware colors from your centralized design system
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;

    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;

    final backgroundColor = isDark
        ? AppColorsDark.background
        : AppColorsLight.background;

    /// InkWell provides ripple effect + tap handling
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdBorder, // keeps ripple inside rounded edges
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: AppRadius.mdBorder,
        ),
        child: Column(
          /// Center icon + label vertically
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container (small square background)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: lightBg,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                size: 16,
                color: Theme.of(context).iconTheme.color,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Label text
            Text(
              label,
              style: AppTextStyles.label,
              textAlign: TextAlign.center,
              maxLines: 2, // prevents overflow in grid
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
