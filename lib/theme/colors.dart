import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Transparent
  static const Color transparent = Color(0x00000000);

  // Primary monochrome palette with soft ink tone
  static const Color black = Color(0xFF0D0D0D);
  static const Color white = Color(0xFFFFFFFF);

  // Modern neutrals - refined gray scale
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFE8E8E8);
  static const Color gray300 = Color(0xFFD4D4D4);
  static const Color gray400 = Color(0xFFA3A3A3);
  static const Color gray500 = Color(0xFF737373);
  static const Color gray600 = Color(0xFF525252);
  static const Color gray700 = Color(0xFF404040);
  static const Color gray800 = Color(0xFF262626);
  static const Color gray900 = Color(0xFF171717);

  // Global P2F accent colors based on login theme
  static const Color accentPrimary = Color(0xFF2E63D3);
  static const Color accentSecondary = Color(0xFF5F7FD8);
  static const Color accentMuted = Color(0xFF93A9E6);

  // Semantic colors with modern tints
  static const Color primary = accentPrimary;
  static const Color secondary = gray800;
  static const Color accent = accentPrimary;

  // Background layers - subtle depth
  static const Color background = Color(0xFFF4F8FF);
  static const Color surface = Color(0xFFF9FBFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceDark = gray900;

  // Glassmorphism backgrounds
  static const Color glassLight = Color(0xCCFFFFFF);
  static const Color glassDark = Color(0xCC0D0D0D);

  // Text colors with better contrast
  static const Color textPrimary = black;
  static const Color textSecondary = gray600;
  static const Color textTertiary = gray400;
  static const Color textMuted = gray500;
  static const Color textInverse = white;

  // On colors for Material 3 compatibility
  static const Color onPrimary = white;
  static const Color onSecondary = white;
  static const Color onSurface = black;

  // Interactive states
  static const Color hoverOverlay = Color(0x0D000000);
  static const Color pressedOverlay = Color(0x1A000000);
  static const Color focusRing = Color(0x33444444);

  // Borders & Dividers - refined
  static const Color border = Color(0xFFE8E8E8);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color divider = Color(0xFFE8E8E8);
  static const Color borderDark = Color(0xFF404040);

  // Status colors - modern muted palette
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFEA580C);
  static const Color warningLight = Color(0xFFFFEDD5);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Gradient colors
  static const List<Color> gradientSurface = [
    Color(0xFFFFFFFF),
    Color(0xFFFAFAFA),
  ];

  static const List<Color> appGradientLight = [
    Color(0xFFF4F8FF),
    Color(0xFFEAF1FF),
    Color(0xFFF7ECF4),
  ];

  static const List<Color> appGradientDark = [
    Color(0xFF101726),
    Color(0xFF121B2D),
    Color(0xFF1A1322),
  ];

  static const List<Color> gradientDark = [
    Color(0xFF171717),
    Color(0xFF0D0D0D),
  ];

  // Shadow colors with opacity
  static Color shadowLight = const Color(0x0D000000);
  static Color shadowMedium = const Color(0x1A000000);
  static Color shadowDark = const Color(0x33000000);
}
