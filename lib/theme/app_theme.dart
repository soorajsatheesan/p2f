import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

class AppTheme {
  AppTheme._();

  // Animation durations
  static const Duration fastDuration = Duration(milliseconds: 150);
  static const Duration normalDuration = Duration(milliseconds: 250);
  static const Duration slowDuration = Duration(milliseconds: 400);

  static ThemeData get light {
    final scheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.gray100,
      onPrimaryContainer: AppColors.black,
      secondary: AppColors.accentSecondary,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.gray100,
      onSecondaryContainer: AppColors.gray900,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.gray100,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.borderLight,
      error: AppColors.error,
      onError: AppColors.white,
      errorContainer: AppColors.errorLight,
      onErrorContainer: AppColors.error,
      shadow: AppColors.shadowMedium,
      scrim: AppColors.shadowDark,
      surfaceTint: AppColors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamilyFallback: AppTypography.fontFamily,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),

      // Card theme - modern with subtle elevation
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Input decoration - modern floating label
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.accentPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTypography.inputLabel,
        hintStyle: AppTypography.inputHint,
        errorStyle: AppTypography.errorText,
        floatingLabelStyle: AppTypography.inputLabel.copyWith(
          color: AppColors.accentPrimary,
          fontWeight: AppTypography.wSemibold,
        ),
      ),

      // Elevated button - modern filled style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTypography.buttonLarge,
          splashFactory: InkRipple.splashFactory,
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.transparent,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Icon button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
        ),
      ),

      // Floating action button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.gray900,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        insetPadding: const EdgeInsets.all(16),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: const BorderSide(color: AppColors.gray400, width: 2),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          if (states.contains(WidgetState.disabled)) {
            return AppColors.gray200;
          }
          return AppColors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.white;
          }
          return AppColors.gray400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.gray200;
        }),
        trackOutlineColor: WidgetStateProperty.all(AppColors.transparent),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gray100,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.gray200,
        labelStyle: AppTypography.chip,
        secondaryLabelStyle: AppTypography.chip.copyWith(
          color: AppColors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide.none,
        elevation: 0,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: AppTypography.headlineSmall,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),

      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.dark(
      primary: AppColors.white,
      onPrimary: AppColors.black,
      primaryContainer: AppColors.gray800,
      onPrimaryContainer: AppColors.white,
      secondary: AppColors.gray300,
      onSecondary: AppColors.black,
      secondaryContainer: AppColors.gray800,
      onSecondaryContainer: AppColors.white,
      surface: AppColors.gray900,
      onSurface: AppColors.white,
      surfaceContainerHighest: AppColors.gray800,
      onSurfaceVariant: AppColors.gray400,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.gray700,
      error: AppColors.errorLight,
      onError: AppColors.black,
      errorContainer: AppColors.gray800,
      onErrorContainer: AppColors.errorLight,
      shadow: AppColors.shadowDark,
      scrim: AppColors.black,
      surfaceTint: AppColors.transparent,
    );

    return light.copyWith(
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.gray900,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.white,
        ),
        iconTheme: const IconThemeData(color: AppColors.white, size: 24),
      ),

      cardTheme: CardThemeData(
        color: AppColors.gray800,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray800,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorLight, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
        ),
        labelStyle: AppTypography.inputLabel.copyWith(color: AppColors.gray400),
        hintStyle: AppTypography.inputHint.copyWith(color: AppColors.gray500),
        errorStyle: AppTypography.errorText,
        floatingLabelStyle: AppTypography.inputLabel.copyWith(
          color: AppColors.white,
          fontWeight: AppTypography.wSemibold,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTypography.buttonLarge.copyWith(color: AppColors.black),
          splashFactory: InkRipple.splashFactory,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.white,
          backgroundColor: AppColors.transparent,
          side: const BorderSide(color: AppColors.borderDark, width: 1.5),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTypography.labelLarge.copyWith(color: AppColors.white),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.white,
          textStyle: AppTypography.labelLarge.copyWith(color: AppColors.white),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.white,
          backgroundColor: AppColors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.gray800,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        insetPadding: const EdgeInsets.all(16),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: const BorderSide(color: AppColors.gray500, width: 2),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.white;
          }
          if (states.contains(WidgetState.disabled)) {
            return AppColors.gray700;
          }
          return AppColors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.black),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.white;
          }
          return AppColors.gray500;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.white.withAlpha(128);
          }
          return AppColors.gray700;
        }),
        trackOutlineColor: WidgetStateProperty.all(AppColors.transparent),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gray800,
        selectedColor: AppColors.white,
        disabledColor: AppColors.gray700,
        labelStyle: AppTypography.chip.copyWith(color: AppColors.white),
        secondaryLabelStyle: AppTypography.chip.copyWith(
          color: AppColors.black,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide.none,
        elevation: 0,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.gray800,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.white,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.gray200,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.gray900,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(
          color: AppColors.white,
        ),
        displayMedium: AppTypography.displayMedium.copyWith(
          color: AppColors.white,
        ),
        displaySmall: AppTypography.displaySmall.copyWith(
          color: AppColors.white,
        ),
        headlineLarge: AppTypography.headlineLarge.copyWith(
          color: AppColors.white,
        ),
        headlineMedium: AppTypography.headlineMedium.copyWith(
          color: AppColors.white,
        ),
        headlineSmall: AppTypography.headlineSmall.copyWith(
          color: AppColors.white,
        ),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.white),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.white),
        titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.white),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.gray200),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.gray300),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.gray400),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.white),
        labelMedium: AppTypography.labelMedium.copyWith(
          color: AppColors.gray400,
        ),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.gray500),
      ),
    );
  }
}
