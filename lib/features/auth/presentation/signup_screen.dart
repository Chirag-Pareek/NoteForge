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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final AuthController _authController;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _authController = AuthController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignup() async {
    final success = await _authController.signUpWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    }
  }

  Future<void> _handleGoogleSignup() async {
    final result = await _authController.signInWithGoogle(allowNewUser: true);

    if (!mounted) return;

    if (result == AuthResult.success) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    } else if (result == AuthResult.newUser) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.profileSetup, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColorsDark.secondaryText : AppColorsLight.secondaryText;
    final primaryText = isDark ? AppColorsDark.primaryText : AppColorsLight.primaryText;

    return ListenableBuilder(
      listenable: _authController,
      builder: (context, _) {
        // Show error using AppSnackbar
        if (_authController.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Check if still mounted and not just loading
             if (!_authController.isLoading) {
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
                            'Create account',
                            style: titleFontSize != null
                                ? AppTextStyles.display.copyWith(fontSize: titleFontSize)
                                : AppTextStyles.display,
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          // Subtitle
                          Text(
                            'Start your learning journey',
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
                                hintText: 'Create a password',
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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

                          const SizedBox(height: AppSpacing.lg),

                          // Confirm Password Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Confirm Password',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: primaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppTextField(
                                hintText: 'Confirm your password',
                                controller: _confirmPasswordController,
                                obscureText: !_isConfirmPasswordVisible,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Create Account Button
                          AppButton(
                            label: 'Create Account',
                            isFullWidth: true,
                            isLoading: _authController.isLoading,
                            onPressed: _authController.isLoading ? null : _handleEmailSignup,
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

                          // Google Sign Up Button
                          AppOutlinedButton(
                            label: 'Sign up with Google',
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
                            onPressed: _authController.isLoading ? null : _handleGoogleSignup,
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Login Link
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(context, AppRoutes.login);
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'Already have an account? ',
                                  style: AppTextStyles.bodyMedium.copyWith(color: secondaryText),
                                  children: [
                                    TextSpan(
                                      text: 'Sign In',
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
