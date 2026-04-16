import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData light(Locale locale) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: _textTheme(Brightness.light, locale),
      elevatedButtonTheme: _buttonTheme(),
    );
  }

  static ThemeData dark(Locale locale) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkSurface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkPrimary,
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: Colors.white,
        secondary: AppColors.darkPrimaryContainer,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        outline: AppColors.darkOutline,
        outlineVariant: AppColors.darkOutlineVariant,
        surfaceContainer: AppColors.darkSurfaceContainer,
        surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
        surfaceContainerLow: AppColors.darkSurfaceContainerLow,
        surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
      ),
      textTheme: _textTheme(Brightness.dark, locale),
      elevatedButtonTheme: _buttonTheme(),
    );
  }

  static TextTheme _textTheme(Brightness brightness, Locale locale) {
    final isArabic = locale.languageCode == 'ar';
    final onSurface = brightness == Brightness.light ? AppColors.onSurface : AppColors.darkOnSurface;
    final onSurfaceVariant = brightness == Brightness.light ? AppColors.onSurfaceVariant : AppColors.darkOnSurfaceVariant;
    final outline = brightness == Brightness.light ? AppColors.outline : AppColors.darkOutline;

    return TextTheme(
      displayLarge: isArabic 
        ? GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w800, color: onSurface)
        : GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w800, color: onSurface, letterSpacing: -1.0),
      headlineLarge: isArabic
        ? GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w800, color: onSurface)
        : GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, color: onSurface, letterSpacing: -0.5),
      headlineMedium: isArabic
        ? GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700, color: onSurface)
        : GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: onSurface),
      bodyLarge: isArabic
        ? GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w400, color: onSurface, height: 1.5)
        : GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: onSurface, height: 1.5),
      bodyMedium: isArabic
        ? GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w400, color: onSurfaceVariant, height: 1.5)
        : GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: onSurfaceVariant, height: 1.5),
      labelLarge: isArabic
        ? GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: outline)
        : GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: outline),
    );
  }

  static ElevatedButtonThemeData _buttonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }
}
