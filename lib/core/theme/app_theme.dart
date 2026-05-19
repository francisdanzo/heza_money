import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_tokens.dart';

/// Thème glassmorphisme Heza Money — dark/light avec couleurs vertes de marque
class AppTheme {
  AppTheme._();

  // ─── Constantes partagées ───────────────────────────────────────────────
  static const double radiusCard   = 16.0;
  static const double radiusButton = 12.0;
  static const double radiusBadge  = 99.0;
  static const double radiusInput  = 12.0;
  static const double radiusModal  = 20.0;

  static const double paddingPage  = 16.0;
  static const double gapSmall     = 8.0;
  static const double gapMedium    = 12.0;
  static const double gapLarge     = 16.0;
  static const double gapXLarge    = 24.0;

  // ─── THÈME CLAIR ────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const cs = ColorScheme.light(
      primary:          HezaColors.primary,
      onPrimary:        HezaColors.lightTextOn,
      secondary:        HezaColors.primaryLight,
      onSecondary:      HezaColors.lightTextOn,
      tertiary:         HezaColors.accent,
      onTertiary:       HezaColors.lightText,
      error:            HezaColors.error,
      onError:          HezaColors.lightTextOn,
      surface:          HezaColors.lightBg,
      onSurface:        HezaColors.lightText,
      surfaceContainerHighest: HezaColors.lightSurface,
      outline:          HezaColors.lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      scaffoldBackgroundColor: HezaColors.lightBg,
      fontFamily: 'Inter',

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: HezaColors.lightTextOn,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: HezaColors.lightTextOn,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: HezaColors.lightSurface.withValues(alpha: 0.95),
        selectedItemColor: HezaColors.primary,
        unselectedItemColor: HezaColors.lightTextSub,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HezaColors.primary,
          foregroundColor: HezaColors.lightTextOn,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: HezaColors.primary,
          side: const BorderSide(color: HezaColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: HezaColors.primary,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HezaColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: HezaColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: HezaColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: HezaColors.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: HezaColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: HezaColors.lightTextMuted,
        ),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: HezaColors.lightTextSub,
        ),
      ),

      cardTheme: CardThemeData(
        color: HezaColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: HezaColors.lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: HezaColors.lightBg2,
        selectedColor: HezaColors.primary,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: HezaColors.lightText,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(),
      ),

      dividerTheme: const DividerThemeData(
        color: HezaColors.lightBorder,
        thickness: 1,
        space: 0,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: HezaColors.primary,
        foregroundColor: HezaColors.lightTextOn,
        elevation: 4,
        shape: CircleBorder(),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: HezaColors.darkSurface,
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: HezaColors.darkText,
        ),
      ),

      textTheme: _buildTextTheme(HezaColors.lightText, HezaColors.lightTextSub),
    );
  }

  // ─── THÈME SOMBRE ────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const cs = ColorScheme.dark(
      primary:          HezaColors.primaryLight,
      onPrimary:        HezaColors.lightTextOn,
      secondary:        HezaColors.accent,
      onSecondary:      HezaColors.darkText,
      tertiary:         HezaColors.accentSoft,
      onTertiary:       HezaColors.darkText,
      error:            HezaColors.error,
      onError:          HezaColors.lightTextOn,
      surface:          HezaColors.darkBg,
      onSurface:        HezaColors.darkText,
      surfaceContainerHighest: HezaColors.darkSurface,
      outline:          HezaColors.darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: HezaColors.darkBg,
      fontFamily: 'Inter',

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: HezaColors.darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: HezaColors.darkText,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: HezaColors.darkSurface.withValues(alpha: 0.95),
        selectedItemColor: HezaColors.primaryLight,
        unselectedItemColor: HezaColors.darkTextSub,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HezaColors.primaryLight,
          foregroundColor: HezaColors.lightTextOn,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: HezaColors.primaryLight,
          side: const BorderSide(color: HezaColors.primaryLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: HezaColors.primaryLight,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HezaColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusInput),
          borderSide: const BorderSide(color: HezaColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusInput),
          borderSide: const BorderSide(color: HezaColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusInput),
          borderSide: const BorderSide(color: HezaColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusInput),
          borderSide: const BorderSide(color: HezaColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: HezaColors.darkTextMuted,
        ),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: HezaColors.darkTextSub,
        ),
      ),

      cardTheme: CardThemeData(
        color: HezaColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          side: const BorderSide(color: HezaColors.darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: HezaColors.darkSurface2,
        selectedColor: HezaColors.primaryLight,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: HezaColors.darkText,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(),
      ),

      dividerTheme: const DividerThemeData(
        color: HezaColors.darkBorder,
        thickness: 1,
        space: 0,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: HezaColors.primaryLight,
        foregroundColor: HezaColors.lightTextOn,
        elevation: 4,
        shape: CircleBorder(),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: HezaColors.darkSurface2,
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: HezaColors.darkText,
        ),
      ),

      textTheme: _buildTextTheme(HezaColors.darkText, HezaColors.darkTextSub),
    );
  }

  // ─── TextTheme partagé ───────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge:  TextStyle(fontFamily: 'Inter', fontSize: 36, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5, height: 1.1),
      displayMedium: TextStyle(fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5, height: 1.2),
      headlineLarge: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w600, color: primary, height: 1.3),
      headlineMedium:TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600, color: primary, height: 1.3),
      headlineSmall: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: primary, height: 1.4),
      titleMedium:   TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w500, color: primary, height: 1.4),
      titleSmall:    TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: primary, height: 1.4),
      bodyLarge:     TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w400, color: primary, height: 1.5),
      bodyMedium:    TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400, color: primary, height: 1.5),
      bodySmall:     TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400, color: secondary, height: 1.5),
      labelLarge:    TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: primary, height: 1.2),
      labelMedium:   TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: secondary, height: 1.2),
      labelSmall:    TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w500, color: secondary, letterSpacing: 0.5, height: 1.2),
    );
  }
}
