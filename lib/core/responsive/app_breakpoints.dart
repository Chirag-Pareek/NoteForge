/// Centralized breakpoint system for the application.
/// Usage: AppBreakpoints.isMobile(constraints.maxWidth)
class AppBreakpoints {
  // Breakpoint values
  static const double mobileMax = 600;
  static const double tabletMax = 900;

  // Helper methods
  static bool isMobile(double width) => width < mobileMax;
  static bool isTablet(double width) => width >= mobileMax && width < tabletMax;
  static bool isDesktop(double width) => width >= tabletMax;

  /// Responsive horizontal page padding used by list/detail screens.
  static double pageHorizontalPadding(double width) {
    if (isDesktop(width)) return 48;
    if (isTablet(width)) return 28;
    return 16;
  }

  /// Max content width to prevent stretched layouts on large tablets/desktop.
  static double pageMaxContentWidth(double width) {
    if (isDesktop(width)) return 1100;
    if (isTablet(width)) return 860;
    return width;
  }

  /// Responsive grid helper for compact-to-wide screens.
  static int gridCount(
    double width, {
    required int mobile,
    required int tablet,
    required int desktop,
  }) {
    if (isDesktop(width)) return desktop;
    if (isTablet(width)) return tablet;
    return mobile;
  }

  // Layout helper
  static T value<T>({
    required double width,
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isMobile(width)) return mobile;
    if (isTablet(width)) return tablet ?? desktop;
    return desktop;
  }
}
