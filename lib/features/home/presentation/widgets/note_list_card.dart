import 'package:flutter/material.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

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

    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;

    /// AppCard applies consistent border + 3D depth and tap handling.
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTextStyles.label.copyWith(color: secondaryText),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: secondaryText),
        ],
      ),
    );
  }
}
