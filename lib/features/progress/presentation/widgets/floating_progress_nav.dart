import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noteforge/core/theme/app_colors.dart';
import 'package:noteforge/core/theme/app_radius.dart';
import 'package:noteforge/core/theme/app_spacing.dart';

/// Community-style floating nav for the Progress section.
class FloatingProgressNav extends StatelessWidget {
  static const double height = 52.0;

  final int index;
  final ValueChanged<int> onChanged;

  const FloatingProgressNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final idleColor = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;
    final glassBase = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.background;
    final backgroundColor = glassBase.withAlpha((0.68 * 255).toInt());
    final borderColor = idleColor.withAlpha((0.24 * 255).toInt());
    final indicatorColor = primaryColor.withAlpha(
      ((isDark ? 0.24 : 0.14) * 255).toInt(),
    );
    final rippleColor = primaryColor.withAlpha((0.16 * 255).toInt());

    const items = <_NavItem>[
      _NavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        label: 'Overview',
      ),
      _NavItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today_rounded,
        label: 'Calendar',
      ),
      _NavItem(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
        label: 'Analytics',
      ),
      _NavItem(
        icon: Icons.psychology_outlined,
        activeIcon: Icons.psychology_rounded,
        label: 'AI Insights',
      ),
    ];

    final clampedIndex = index.clamp(0, items.length - 1);
    final navWidth = (items.length * 58.0) + (AppSpacing.sm * 2);

    return SizedBox(
      height: height,
      width: navWidth,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: borderColor, width: 0.85),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final slotWidth = constraints.maxWidth / items.length;

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      left: slotWidth * clampedIndex,
                      top: 0,
                      width: slotWidth,
                      height: constraints.maxHeight,
                      child: Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.82,
                          heightFactor: 0.88,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: indicatorColor,
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(items.length, (itemIndex) {
                        final item = items[itemIndex];
                        return Expanded(
                          child: _NavIconButton(
                            isSelected: itemIndex == clampedIndex,
                            icon: item.icon,
                            activeIcon: item.activeIcon,
                            label: item.label,
                            activeColor: primaryColor,
                            inactiveColor: idleColor,
                            rippleColor: rippleColor,
                            onTap: () => onChanged(itemIndex),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavIconButton extends StatefulWidget {
  final bool isSelected;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color activeColor;
  final Color inactiveColor;
  final Color rippleColor;
  final VoidCallback onTap;

  const _NavIconButton({
    required this.isSelected,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.activeColor,
    required this.inactiveColor,
    required this.rippleColor,
    required this.onTap,
  });

  @override
  State<_NavIconButton> createState() => _NavIconButtonState();
}

class _NavIconButtonState extends State<_NavIconButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected ? widget.activeColor : widget.inactiveColor;
    final scale = _isPressed ? 0.92 : (widget.isSelected ? 1.04 : 1.0);

    return Semantics(
      label: widget.label,
      button: true,
      selected: widget.isSelected,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        scale: scale,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onTap();
            },
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            borderRadius: BorderRadius.circular(AppRadius.full),
            splashColor: widget.rippleColor,
            highlightColor: widget.rippleColor.withAlpha((0.08 * 255).toInt()),
            child: SizedBox.expand(
              child: Center(
                child: Icon(
                  widget.isSelected ? widget.activeIcon : widget.icon,
                  size: 21,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
