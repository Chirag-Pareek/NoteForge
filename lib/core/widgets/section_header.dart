import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium,
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
