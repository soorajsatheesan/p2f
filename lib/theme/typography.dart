import 'package:flutter/material.dart';
import 'colors.dart';

class AppTypography {
  AppTypography._();

  // Font families - editorial leaning fallback stack
  static const List<String> fontFamily = [
    'Avenir Next',
    'Futura',
    'Baskerville',
    'Iowan Old Style',
    'Palatino',
    'Trebuchet MS',
    'Verdana',
    'Segoe UI',
    'sans-serif',
  ];

  // Font weights - modern naming
  static const FontWeight wLight = FontWeight.w300;
  static const FontWeight wRegular = FontWeight.w400;
  static const FontWeight wMedium = FontWeight.w500;
  static const FontWeight wSemibold = FontWeight.w600;
  static const FontWeight wBold = FontWeight.w700;

  // Display styles - Large headings with tight letter spacing
  static TextStyle get displayLarge => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 57,
    fontWeight: wBold,
    letterSpacing: -1.5,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 45,
    fontWeight: wSemibold,
    letterSpacing: -1.0,
    height: 1.15,
    color: AppColors.textPrimary,
  );

  static TextStyle get displaySmall => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 36,
    fontWeight: wSemibold,
    letterSpacing: -0.8,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  // Headline styles - Section headers
  static TextStyle get headlineLarge => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 32,
    fontWeight: wSemibold,
    letterSpacing: -0.6,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 28,
    fontWeight: wSemibold,
    letterSpacing: -0.5,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineSmall => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 24,
    fontWeight: wSemibold,
    letterSpacing: -0.4,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // Title styles - Card titles, app bar
  static TextStyle get titleLarge => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 22,
    fontWeight: wSemibold,
    letterSpacing: -0.3,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 18,
    fontWeight: wMedium,
    letterSpacing: -0.2,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleSmall => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 16,
    fontWeight: wMedium,
    letterSpacing: -0.1,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // Body styles - Main content
  static TextStyle get bodyLarge => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 16,
    fontWeight: wRegular,
    letterSpacing: 0,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 14,
    fontWeight: wRegular,
    letterSpacing: 0,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 12,
    fontWeight: wRegular,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // Label styles - UI elements, buttons
  static TextStyle get labelLarge => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 14,
    fontWeight: wSemibold,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 12,
    fontWeight: wMedium,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelSmall => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 11,
    fontWeight: wMedium,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.textTertiary,
  );

  // Button text styles
  static TextStyle get buttonLarge => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 16,
    fontWeight: wSemibold,
    letterSpacing: 0,
    height: 1.2,
    color: AppColors.textInverse,
  );

  static TextStyle get buttonMedium => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 14,
    fontWeight: wSemibold,
    letterSpacing: 0,
    height: 1.2,
    color: AppColors.textInverse,
  );

  // Overline and caption
  static TextStyle get overline => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 10,
    fontWeight: wSemibold,
    letterSpacing: 1.5,
    height: 1.4,
    color: AppColors.textTertiary,
  );

  static TextStyle get caption => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 12,
    fontWeight: wRegular,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // Modern chip/tag style
  static TextStyle get chip => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 12,
    fontWeight: wSemibold,
    letterSpacing: 0.2,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // Hero/Display text for special emphasis
  static TextStyle get hero => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 64,
    fontWeight: wBold,
    letterSpacing: -2,
    height: 1.0,
    color: AppColors.textPrimary,
  );

  // Fitness app specific styles
  static TextStyle get statValue => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 40,
    fontWeight: wBold,
    letterSpacing: -1,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  static TextStyle get statLabel => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 13,
    fontWeight: wMedium,
    letterSpacing: 0.3,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  static TextStyle get metricLarge => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 72,
    fontWeight: wLight,
    letterSpacing: -2,
    height: 1.0,
    color: AppColors.textPrimary,
  );

  // Input styles
  static TextStyle get input => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 16,
    fontWeight: wRegular,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get inputLabel => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 12,
    fontWeight: wMedium,
    letterSpacing: 0.3,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static TextStyle get inputHint => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 16,
    fontWeight: wRegular,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.textTertiary,
  );

  // Status/error text
  static TextStyle get errorText => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 12,
    fontWeight: wMedium,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.error,
  );

  static TextStyle get successText => const TextStyle(
    fontFamilyFallback: fontFamily,
    fontSize: 12,
    fontWeight: wMedium,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.success,
  );
}
