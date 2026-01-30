import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    // IconTheme is already configured in AppTheme
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      splashRadius: AppSpacing.xl, // Minimal ripple area
      tooltip: tooltip,
    );
  }
}
