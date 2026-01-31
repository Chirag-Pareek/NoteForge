import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/responsive/app_breakpoints.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColorsDark.secondaryText : AppColorsLight.secondaryText;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isTablet = !AppBreakpoints.isMobile(width);
        final isLargeTablet = AppBreakpoints.isDesktop(width);

        final horizontalPadding = isTablet ? AppSpacing.xxl * 2 : AppSpacing.xxl;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Setup Profile'),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLargeTablet ? 1200 : (isTablet ? 800 : 600),
                ),
                child: Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tell us more about you',
                        style: isTablet 
                            ? AppTextStyles.display.copyWith(fontSize: 40)
                            : AppTextStyles.display.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'We need a few details to customize your experience.',
                        style: AppTextStyles.bodyLarge.copyWith(color: secondaryText),
                      ),
                      const Spacer(),
                      // Placeholder for future form
                      Center(
                        child: Text(
                          'Profile Form Placeholder',
                          style: AppTextStyles.bodyMedium.copyWith(color: secondaryText),
                        ),
                      ),
                      const Spacer(),
                      AppButton(
                        label: 'Complete Setup',
                        isFullWidth: true,
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
                        },
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
