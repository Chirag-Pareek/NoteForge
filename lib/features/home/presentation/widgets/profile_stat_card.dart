import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

/// ProfileStatCard
/// ----------------
/// A small reusable UI component used on the Profile screen
/// to display a single statistic such as:
/// - Streak
/// - Tests
/// - Wins
///
/// Example:
///   ProfileStatCard(value: "7 🔥", label: "Streak")
class ProfileStatCard extends StatelessWidget {
  /// Main value shown (e.g. "7 🔥", "24", "12")
  final String value;

  /// Text label below the value (e.g. "Streak", "Tests", "Wins")
  final String label;

  const ProfileStatCard({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    /// Check current theme brightness
    /// Used to apply correct colors for light/dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    /// Secondary text color adapts based on theme
    /// (lighter in dark mode, muted in light mode)
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;

    /// Expanded makes each stat card take equal width
    /// when placed inside a Row
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // -----------------------
          // Stat Value (Big Text)
          // -----------------------
          Text(
            value,
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xs),

          // -----------------------
          // Stat Label (Muted Text)
          // -----------------------
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
