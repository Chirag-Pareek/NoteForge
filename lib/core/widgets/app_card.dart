import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool enableInk;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.enableInk = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedBorderColor =
        borderColor ?? (isDark ? AppColorsDark.border : AppColorsLight.border);
    // Using a subtle background or keeping it transparent with just border as per 'Border-based UI' hint.
    // However, distinct cards often look good with the "Light Background" color from palette.
    final resolvedBackgroundColor = backgroundColor ??
        (isDark ? AppColorsDark.background : AppColorsLight.background);
    final resolvedRadius = borderRadius ?? AppRadius.mdBorder;

    final card = Container(
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        border: Border.all(color: resolvedBorderColor),
        borderRadius: resolvedRadius,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );

    if (!enableInk) {
      return card;
    }

    return Container(
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        border: Border.all(color: resolvedBorderColor),
        borderRadius: resolvedRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: resolvedRadius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}
