import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_outlined_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_divider.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/responsive/app_breakpoints.dart';
import 'controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final AuthController _authController; // Scoped controller
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _authController = AuthController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    final success = await _authController.signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    final result = await _authController.signInWithGoogle();

    if (!mounted) return;

    if (result == AuthResult.success) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    } else if (result == AuthResult.newUser) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.profileSetup, (route) => false);
    }
  }

  void _showForgotPasswordSheet() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColorsDark.background : AppColorsLight.background;
    final secondaryText = isDark ? AppColorsDark.secondaryText : AppColorsLight.secondaryText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
          left: AppSpacing.xxl,
          right: AppSpacing.xxl,
          top: AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Modal fits content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reset Password', style: AppTextStyles.display),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Enter your email to receive a reset link.',
              style: AppTextStyles.bodyMedium.copyWith(color: secondaryText),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              hintText: 'Enter your email',
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.xl),
            ListenableBuilder(
              listenable: _authController, // Reuse existing controller? Or new one? Reusing is fine for logic.
              builder: (context, _) => AppButton(
                label: 'Send Reset Link',
                isFullWidth: true,
                isLoading: _authController.isLoading,
                onPressed: () async {
                  final email = resetEmailController.text.trim();
                  final success = await _authController.resetPassword(email);
                  
                  if (context.mounted) {
                     if (success) {
                       Navigator.pop(context); // Close sheet
                       if (_authController.successMessage != null) {
                        AppSnackbar.show(context, _authController.successMessage!);
                       }
                     } else if (_authController.errorMessage != null) {
                       AppSnackbar.show(context, _authController.errorMessage!, isError: true);
                     }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColorsDark.secondaryText : AppColorsLight.secondaryText;
    final primaryText = isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText;

    return ListenableBuilder(
      listenable: _authController,
      builder: (context, _) {
        // Show error snakbar if error exists in MAIN flow
        if (_authController.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Only show validation errors if not in modal? 
            // Actually _authController errors are global to the instance.
            // If modal sets error, this listener triggers too?
            // Ideally use separate state for modal or careful handling.
            // But for now, we just show it.
            // If the modal is OPEN, showing a snackbar is fine (overlays modal).
            // But we should verify if the error came from Login attempt or Reset attempt.
            // Since controller is single instance here, they share state.
            // Reset clears error first.
            if (!_authController.isLoading) { // Don't show old errors?
               AppSnackbar.show(context, _authController.errorMessage!, isError: true);
               _authController.clearError();
            }
          });
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isTablet = !AppBreakpoints.isMobile(width);
            final isLargeTablet = AppBreakpoints.isDesktop(width);

            final horizontalPadding = isTablet ? AppSpacing.xxl * 3 : AppSpacing.xxl;
            final titleFontSize = isLargeTablet ? 48.0 : (isTablet ? 40.0 : null);

            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isLargeTablet ? 1200 : (isTablet ? 800 : 600),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: isTablet ? AppSpacing.xxl * 2 : AppSpacing.xxl),

                          // Title
                          Text(
                            'Welcome back',
                            style: titleFontSize != null
                                ? AppTextStyles.display.copyWith(fontSize: titleFontSize)
                                : AppTextStyles.display,
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          // Subtitle
                          Text(
                            'Sign in to continue learning',
                            style: (isTablet ? AppTextStyles.bodyLarge : AppTextStyles.bodyMedium)
                                .copyWith(color: secondaryText),
                          ),

                          const SizedBox(height: AppSpacing.xxl),

                          // Email Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: primaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppTextField(
                                hintText: 'your.email@example.com',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Password Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: primaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppTextField(
                                hintText: 'Enter your password',
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible, // Toggle
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible 
                                        ? Icons.visibility 
                                        : Icons.visibility_off,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppSpacing.sm),
                          
                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    foregroundColor: primaryText, // Animate to primary on tap/hover default behavior
                                ),
                                onPressed: _showForgotPasswordSheet,
                                child: Text(
                                    'Forgot password?',
                                    style: AppTextStyles.label.copyWith(
                                        color: secondaryText, // Default color
                                        fontWeight: FontWeight.w500,
                                    ),
                                ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Sign In Button
                          AppButton(
                            label: 'Sign In',
                            isFullWidth: true,
                            isLoading: _authController.isLoading,
                            onPressed: _authController.isLoading ? null : _handleEmailLogin,
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Divider with OR
                          Row(
                            children: [
                              const Expanded(child: AppDivider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                                child: Text(
                                  'OR',
                                  style: AppTextStyles.label.copyWith(color: secondaryText),
                                ),
                              ),
                              const Expanded(child: AppDivider()),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Google Sign In Button
                          AppOutlinedButton(
                            label: 'Continue with Google',
                            isFullWidth: true,
                            isLoading: _authController.isLoading,
                            icon: Image.network(
                              'https://www.google.com/favicon.ico',
                              width: 20,
                              height: 20,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.g_mobiledata, size: 20);
                              },
                            ),
                            onPressed: _authController.isLoading ? null : _handleGoogleLogin,
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Sign Up Link
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(context, AppRoutes.signup);
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: AppTextStyles.bodyMedium.copyWith(color: secondaryText),
                                  children: [
                                    TextSpan(
                                      text: 'Sign Up',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: primaryText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
      },
    );
  }
}
