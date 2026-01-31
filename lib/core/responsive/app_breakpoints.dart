
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
