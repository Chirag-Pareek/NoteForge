import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/responsive/app_breakpoints.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColorsDark.primaryText
        : AppColorsLight.primaryText;
    final lightBg = isDark
        ? AppColorsDark.lightBackground
        : AppColorsLight.lightBackground;
    final secondaryText = isDark
        ? AppColorsDark.secondaryText
        : AppColorsLight.secondaryText;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isTablet = !AppBreakpoints.isMobile(width);
        final isLargeTablet = AppBreakpoints.isDesktop(width);

        // Responsive sizing
        final circleSize = isLargeTablet ? 280.0 : (isTablet ? 240.0 : 200.0);
        final iconSize = isLargeTablet ? 120.0 : (isTablet ? 100.0 : 80.0);
        final buttonWidth = isLargeTablet ? 400.0 : (isTablet ? 340.0 : 280.0);
        final horizontalPadding = isTablet
            ? AppSpacing.xxl * 3
            : AppSpacing.xxl;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLargeTablet ? 1200 : (isTablet ? 800 : 600),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: AppSpacing.xxl,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // Illustration Circle
                      Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          color: lightBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryText, width: 1.5),
                          boxShadow: AppEffects.subtleDepth(
                            Theme.of(context).brightness,
                          ),
                        ),
                        child: Icon(
                          Icons.menu_book_outlined,
                          size: iconSize,
                          color: primaryText,
                        ),
                      ),

                      const Spacer(flex: 1),

                      // App Name
                      Text(
                        'NoteForge',
                        style: isTablet
                            ? AppTextStyles.display.copyWith(
                                fontSize: isLargeTablet ? 48 : 40,
                              )
                            : AppTextStyles.display,
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(
                        height: isTablet ? AppSpacing.lg : AppSpacing.md,
                      ),

                      // Subtitle
                      Text(
                        'Your intelligent learning companion\nfor academic excellence',
                        style:
                            (isTablet
                                    ? AppTextStyles.bodyMedium
                                    : AppTextStyles.bodySmall)
                                .copyWith(color: secondaryText),
                        textAlign: TextAlign.center,
                      ),

                      const Spacer(),

                      // Continue Button
                      SizedBox(
                        width: buttonWidth,
                        child: AppButton(
                          label: 'Continue',
                          isFullWidth: true,
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.login);
                          },
                        ),
                      ),

                      SizedBox(
                        height: isTablet ? AppSpacing.xxl * 2 : AppSpacing.xxl,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
