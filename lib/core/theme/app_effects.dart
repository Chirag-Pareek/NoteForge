import 'package:flutter/material.dart';

/// Shared visual effects used across the app.
/// Keeps depth and shadow behavior consistent on all screens.
class AppEffects {
  static const Offset subtleDepthOffset = Offset(3, 4);
  static const double subtleDepthBlur = 0;
  static const double subtleDepthSpread = 0;

  /// Returns a subtle 3D-like shadow with a fixed 2x2 offset.
  static List<BoxShadow> subtleDepth(Brightness brightness) {
    // Light mode: black drop shadow.
    // Dark mode: lighter tinted shadow to avoid heavy black crush.
    final color = brightness == Brightness.dark
        ? const Color.fromARGB(255, 0, 0, 0)
        : Colors.black;
    return [
      BoxShadow(
        color: color,
        offset: subtleDepthOffset,
        blurRadius: subtleDepthBlur,
        spreadRadius: subtleDepthSpread,
      ),
    ];
  }
}
