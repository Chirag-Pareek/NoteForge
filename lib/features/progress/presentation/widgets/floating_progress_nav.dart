import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:noteforge/core/theme/app_colors.dart';
import 'package:noteforge/core/theme/app_radius.dart';
import 'package:noteforge/core/theme/app_spacing.dart';
import 'package:noteforge/core/widgets/app_card.dart';

/// Community-style floating nav for the Progress section.
class FloatingProgressNav extends StatelessWidget {
  static const double height = 56.0;

  final int index;
  final ValueChanged<int> onChanged;

  const FloatingProgressNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textColor = isDark
        ? AppColorsDark.primaryText
        : AppColorsLight.primaryText;
    final idleColor = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final baseColor = isDark
        ? AppColorsDark.background
        : AppColorsLight.background;

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppCard(
            enableInk: false,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            borderRadius: BorderRadius.circular(AppRadius.full),
            borderColor: borderColor.withAlpha((0.7 * 255).toInt()),
            backgroundColor: baseColor.withAlpha((0.82 * 255).toInt()),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavIcon(
                  isSelected: index == 0,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Overview',
                  borderColor: borderColor,
                  activeColor: textColor,
                  inactiveColor: idleColor,
                  onTap: () => onChanged(0),
                ),
                const SizedBox(width: AppSpacing.xs),
                _NavIcon(
                  isSelected: index == 1,
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today_rounded,
                  label: 'Calendar',
                  borderColor: borderColor,
                  activeColor: textColor,
                  inactiveColor: idleColor,
                  onTap: () => onChanged(1),
                ),
                const SizedBox(width: AppSpacing.xs),
                _NavIcon(
                  isSelected: index == 2,
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart_rounded,
                  label: 'Analytics',
                  borderColor: borderColor,
                  activeColor: textColor,
                  inactiveColor: idleColor,
                  onTap: () => onChanged(2),
                ),
                const SizedBox(width: AppSpacing.xs),
                _NavIcon(
                  isSelected: index == 3,
                  icon: Icons.psychology_outlined,
                  activeIcon: Icons.psychology_rounded,
                  label: 'AI Insights',
                  borderColor: borderColor,
                  activeColor: textColor,
                  inactiveColor: idleColor,
                  onTap: () => onChanged(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color borderColor;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavIcon({
    required this.isSelected,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.borderColor,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = activeColor.withAlpha((0.10 * 255).toInt());
    final color = isSelected ? activeColor : inactiveColor;

    return Semantics(
      label: label,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? fillColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: isSelected ? borderColor : Colors.transparent,
            ),
          ),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: isSelected ? 1.05 : 1.0,
            child: Icon(isSelected ? activeIcon : icon, size: 22, color: color),
          ),
        ),
      ),
    );
  }
}
