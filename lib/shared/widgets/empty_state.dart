import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;

  const EmptyState({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDark ? AppColorsDark.secondaryText : AppColorsLight.secondaryText;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 48,
              color: contentColor,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(color: contentColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
