import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Typography system using Space Grotesk (headings) and Inter (body).
/// Maps to the design-theme.md type scale.
class AppTypography {
  AppTypography._();

  static const String bodyFont = 'Inter';
  static const List<String> bodyFallback = <String>[
    'Inter',
    'Roboto',
    'Helvetica',
    'Arial',
    'sans-serif',
  ];
  static const String headingFont = 'Space Grotesk';

  // Font weights
  static const FontWeight wLight = FontWeight.w300;
  static const FontWeight wRegular = FontWeight.w400;
  static const FontWeight wMedium = FontWeight.w500;
  static const FontWeight wSemibold = FontWeight.w600;
  static const FontWeight wBold = FontWeight.w700;

  // ── Helper constructors ──

  static TextStyle _heading({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = 0,
    double height = 1.1,
    Color color = AppColors.foreground,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  static TextStyle _body({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w400,
    double letterSpacing = 0,
    double height = 1.7,
    Color color = AppColors.muted,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  // ── Heading styles (Space Grotesk) ──

  /// Hero title — largest display text
  static TextStyle get hero => _heading(
    fontSize: 64,
    fontWeight: wBold,
    letterSpacing: -2.56, // -0.04em
    height: 0.95,
  );

  /// Display large — section titles
  static TextStyle get displayLarge => _heading(
    fontSize: 56,
    fontWeight: wBold,
    letterSpacing: -1.68, // -0.03em
  );

  /// Display medium
  static TextStyle get displayMedium => _heading(
    fontSize: 45,
    fontWeight: wBold,
    letterSpacing: -1.35,
  );

  /// Display small
  static TextStyle get displaySmall => _heading(
    fontSize: 36,
    fontWeight: wBold,
    letterSpacing: -1.08,
  );

  /// Headline large
  static TextStyle get headlineLarge => _heading(
    fontSize: 32,
    fontWeight: wBold,
    letterSpacing: -0.96,
  );

  /// Headline medium
  static TextStyle get headlineMedium => _heading(
    fontSize: 28,
    fontWeight: wBold,
    letterSpacing: -0.84,
  );

  /// Headline small — feature headings
  static TextStyle get headlineSmall => _heading(
    fontSize: 21,
    fontWeight: wSemibold,
    letterSpacing: -0.21,
    height: 1.2,
  );

  /// Card value / stat number
  static TextStyle get statValue => _heading(
    fontSize: 48,
    fontWeight: wBold,
    letterSpacing: -1.44,
    height: 1.0,
  );

  /// Metric large
  static TextStyle get metricLarge => _heading(
    fontSize: 72,
    fontWeight: wBold,
    letterSpacing: -2.16,
    height: 1.0,
  );

  /// Logo text
  static TextStyle get logo => _heading(
    fontSize: 24,
    fontWeight: wBold,
    letterSpacing: -0.48,
    height: 1.0,
  );

  // ── Title styles (Space Grotesk) ──

  static TextStyle get titleLarge => _heading(
    fontSize: 22,
    fontWeight: wSemibold,
    letterSpacing: -0.22,
    height: 1.2,
  );

  static TextStyle get titleMedium => _heading(
    fontSize: 18,
    fontWeight: wSemibold,
    letterSpacing: -0.18,
    height: 1.25,
  );

  static TextStyle get titleSmall => _heading(
    fontSize: 16,
    fontWeight: wSemibold,
    letterSpacing: -0.16,
    height: 1.3,
  );

  // ── Body styles (Inter) ──

  /// Body text — main content
  static TextStyle get bodyLarge => _body(
    fontSize: 17,
    height: 1.7,
  );

  static TextStyle get bodyMedium => _body(
    fontSize: 15,
    height: 1.7,
  );

  /// Feature body / smaller content
  static TextStyle get bodySmall => _body(
    fontSize: 13,
    height: 1.6,
    color: AppColors.subtle,
  );

  // ── Label / UI styles (Inter) ──

  /// Nav links
  static TextStyle get navLink => _body(
    fontSize: 14,
    fontWeight: wMedium,
    letterSpacing: 0.56,
    height: 1.0,
    color: AppColors.foreground,
  );

  /// Button text
  static TextStyle get buttonLarge => _body(
    fontSize: 16,
    fontWeight: wSemibold,
    letterSpacing: 0.48,
    height: 1.2,
    color: AppColors.background,
  );

  static TextStyle get buttonMedium => _body(
    fontSize: 14,
    fontWeight: wSemibold,
    letterSpacing: 0.42,
    height: 1.2,
    color: AppColors.background,
  );

  /// Tags / eyebrows — uppercase
  static TextStyle get tag => _body(
    fontSize: 13,
    fontWeight: wMedium,
    letterSpacing: 3.25,
    height: 1.3,
    color: AppColors.subtle,
  );

  /// Labels
  static TextStyle get labelLarge => _body(
    fontSize: 14,
    fontWeight: wSemibold,
    letterSpacing: 0.42,
    height: 1.4,
    color: AppColors.foreground,
  );

  static TextStyle get labelMedium => _body(
    fontSize: 12,
    fontWeight: wSemibold,
    letterSpacing: 1.8,
    height: 1.4,
    color: AppColors.subtle,
  );

  /// Small labels
  static TextStyle get labelSmall => _body(
    fontSize: 11,
    fontWeight: wMedium,
    letterSpacing: 1.1,
    height: 1.4,
    color: AppColors.faint,
  );

  /// Chip / badge
  static TextStyle get chip => _body(
    fontSize: 12,
    fontWeight: wSemibold,
    letterSpacing: 0.3,
    height: 1.3,
    color: AppColors.foreground,
  );

  // ── Input styles (Inter) ──

  static TextStyle get input => _body(
    fontSize: 16,
    height: 1.5,
    color: AppColors.foreground,
  );

  static TextStyle get inputLabel => _body(
    fontSize: 12,
    fontWeight: wMedium,
    letterSpacing: 0.3,
    height: 1.4,
    color: AppColors.subtle,
  );

  static TextStyle get inputHint => _body(
    fontSize: 16,
    height: 1.5,
    color: AppColors.faint,
  );

  // ── Status text ──

  static TextStyle get errorText => _body(
    fontSize: 12,
    fontWeight: wMedium,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.error,
  );

  static TextStyle get successText => _body(
    fontSize: 12,
    fontWeight: wMedium,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.success,
  );

  // ── Overline / caption ──

  static TextStyle get overline => _body(
    fontSize: 10,
    fontWeight: wSemibold,
    letterSpacing: 2.5,
    height: 1.4,
    color: AppColors.subtle,
  );

  static TextStyle get caption => _body(
    fontSize: 12,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.subtle,
  );

  /// Stat label
  static TextStyle get statLabel => _body(
    fontSize: 13,
    fontWeight: wMedium,
    letterSpacing: 1.3,
    height: 1.3,
    color: AppColors.subtle,
  );
}
