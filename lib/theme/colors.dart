import 'package:flutter/material.dart';

/// Strictly monochrome color system — black and white only.
/// Hierarchy is achieved through opacity levels of white on black.
class AppColors {
  AppColors._();

  // Core
  static const Color transparent = Color(0x00000000);
  static const Color background = Color(0xFF000000);
  static const Color foreground = Color(0xFFFFFFFF);

  // Opacity layers — white on black
  static const Color muted = Color(0x80FFFFFF); // 0.5
  static const Color subtle = Color(0x59FFFFFF); // 0.35
  static const Color faint = Color(0x26FFFFFF); // 0.15

  // Borders
  static const Color border = Color(0x14FFFFFF); // 0.08
  static const Color borderHover = Color(0x33FFFFFF); // 0.2
  static const Color borderStrong = Color(0x4DFFFFFF); // 0.3

  // Surfaces
  static const Color surface = Color(0x05FFFFFF); // 0.02
  static const Color surfaceHover = Color(0x0AFFFFFF); // 0.04
  static const Color surfaceElevated = Color(0x14FFFFFF); // 0.08

  // Overlays
  static const Color overlayLight = Color(0x80000000); // 0.5
  static const Color overlayHeavy = Color(0xBF000000); // 0.75
  static const Color overlayFade = Color(0xF2000000); // 0.95

  // Dividers
  static const Color divider = Color(0x0FFFFFFF); // 0.06
  static const Color dividerStrong = Color(0x14FFFFFF); // 0.08

  // Shadows
  static const Color shadowCard = Color(0x66000000); // card hover
  static const Color shadowButton = Color(0x1AFFFFFF); // button glow

  // Semantic — kept minimal for status
  static const Color error = Color(0xFFFF4444);
  static const Color success = Color(0xFF44FF44);
  static const Color warning = Color(0xFFFFAA00);
}
