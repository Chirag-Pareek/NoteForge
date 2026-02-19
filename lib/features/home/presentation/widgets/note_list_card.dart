import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';

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
  final VoidCallback? onLongPress;
  final IconData icon;
  final String? trailingText;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const NoteListCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onLongPress,
    this.icon = Icons.description_outlined,
    this.trailingText,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColorsDark.primaryText
        : AppColorsLight.primaryText;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;

    final resolvedIconColor = iconColor ?? primaryText;
    final resolvedIconBackground = iconBackgroundColor ?? lightBg;

    // FIX: aligned notes card with existing NoteForge AppCard defaults.
    return AppCard(
      onTap: onTap,
      onLongPress: onLongPress,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: resolvedIconBackground,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 18, color: resolvedIconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(color: secondaryText),
                ),
              ],
            ),
          ),
          if (trailingText != null) ...[
            Text(
              trailingText!,
              style: AppTextStyles.label.copyWith(
                color: secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Icon(Icons.chevron_right, size: 20, color: secondaryText),
        ],
      ),
    );
  }
}
