// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColorsLight.primaryButton,
      scaffoldBackgroundColor: AppColorsLight.background,
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: _textTheme(AppColorsLight.primaryText, AppColorsLight.secondaryText),
      colorScheme: const ColorScheme.light(
        primary: AppColorsLight.primaryButton,
        onPrimary: Colors.white,
        background: AppColorsLight.background,
        onBackground: AppColorsLight.primaryText,
        surface: AppColorsLight.background,
        onSurface: AppColorsLight.primaryText,
        error: AppColorsLight.error,
        outline: AppColorsLight.border,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColorsLight.border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: AppColorsLight.primaryText,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColorsDark.primaryButton,
      scaffoldBackgroundColor: AppColorsDark.background,
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: _textTheme(AppColorsDark.primaryText, AppColorsDark.secondaryText),
      colorScheme: const ColorScheme.dark(
        primary: AppColorsDark.primaryButton,
        onPrimary: Colors.black, // Inverted for dark mode primary button text
        background: AppColorsDark.background,
        onBackground: AppColorsDark.primaryText,
        surface: AppColorsDark.background,
        onSurface: AppColorsDark.primaryText,
        error: AppColorsDark.error,
        outline: AppColorsDark.border,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColorsDark.border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: AppColorsDark.primaryText,
      ),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: AppTextStyles.display.copyWith(color: primary),
      displayMedium: AppTextStyles.titleLarge.copyWith(color: primary),
      displaySmall: AppTextStyles.titleMedium.copyWith(color: primary),
      headlineMedium: AppTextStyles.titleMedium.copyWith(color: primary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: primary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: primary),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: secondary),
      labelSmall: AppTextStyles.label.copyWith(color: secondary),
    );
  }
}
