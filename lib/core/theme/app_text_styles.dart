import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_font_sizes.dart';

class AppTextStyles {
  // We'll define base styles that can be adapted with color in the Theme
  
  static TextStyle get _base => GoogleFonts.poppins();

  static TextStyle get display => _base.copyWith(
        fontSize: AppFontSizes.display,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  static TextStyle get titleLarge => _base.copyWith(
        fontSize: AppFontSizes.xxl,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );
      
  static TextStyle get titleMedium => _base.copyWith(
        fontSize: AppFontSizes.xl,
        fontWeight: FontWeight.w500,
        height: 1.3,
      );

  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: AppFontSizes.lg,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: AppFontSizes.md,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodySmall => _base.copyWith(
        fontSize: AppFontSizes.sm,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );
      
  static TextStyle get label => _base.copyWith(
        fontSize: AppFontSizes.xs,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );
      
  static TextStyle get button => _base.copyWith(
    fontSize: AppFontSizes.sm,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
