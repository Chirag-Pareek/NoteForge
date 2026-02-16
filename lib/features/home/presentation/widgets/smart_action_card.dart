import 'package:flutter/material.dart';
import '../../../../core/widgets/app_card.dart';
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
    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;

    /// AppCard keeps border + subtle depth + ripple behavior consistent.
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          Text(
            label,
            style: AppTextStyles.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
