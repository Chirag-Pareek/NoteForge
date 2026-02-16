import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
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
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final resolvedBorderColor =
        borderColor ?? (isDark ? AppColorsDark.border : AppColorsLight.border);
    final resolvedBackgroundColor =
        backgroundColor ??
        (isDark ? AppColorsDark.background : AppColorsLight.background);
    final resolvedRadius = borderRadius ?? AppRadius.mdBorder;
    final decoration = BoxDecoration(
      color: resolvedBackgroundColor,
      border: Border.all(color: resolvedBorderColor, width: 1.2),
      borderRadius: resolvedRadius,
      boxShadow: AppEffects.subtleDepth(brightness),
    );

    if (!enableInk) {
      return Container(
        decoration: decoration,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      );
    }

    return Container(
      decoration: decoration,
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
