import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// A thin linear progress bar widget, used for chapter completion indicators.
class AppProgressIndicator extends StatelessWidget {
  /// Progress value from 0.0 to 1.0.
  final double value;

  /// Height of the progress bar.
  final double height;

  /// Optional active color override.
  final Color? activeColor;

  const AppProgressIndicator({
    super.key,
    required this.value,
    this.height = 4,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final fgColor = activeColor ??
        (isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          backgroundColor: bgColor,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
          minHeight: height,
        ),
      ),
    );
  }
}
