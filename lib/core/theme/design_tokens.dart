import 'package:flutter/material.dart';

/// Design tokens pour Heza Money — Glassmorphism avec Dark/Light Theme
/// Basé sur le design system UI/UX Pro Max

class HezaColors {
  // --- LIGHT MODE ---
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF1F5F9);
  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightOnSurfaceSecondary = Color(0xFF475569);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // --- DARK MODE ---
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1A2847);
  static const Color darkSurfaceAlt = Color(0xFF254264);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOnSurfaceSecondary = Color(0xFFCBD5E1);
  static const Color darkBorder = Color(0xFF334155);

  // --- SEMANTIC COLORS ---
  static const Color primary = Color(0xFF1E40AF); // Trust blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF059669); // Profit green
  static const Color accentLight = Color(0xFF10B981);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF059669);
  static const Color info = Color(0xFF0284C7);

  // --- GLASS EFFECT COLORS ---
  static const Color glassLight = Color(0xFFFFFFFF);
  static const Color glassDark = Color(0xFF1A2847);
}

class HezaSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}

class HezaRadii {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double full = 99.0;
}

class HezaShadows {
  // Light mode shadows
  static const List<BoxShadow> lightSm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> lightMd = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> lightLg = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  // Dark mode glass shadows (subtle, no black)
  static const List<BoxShadow> darkGlassInner = [
    BoxShadow(
      color: Color(0x33FFFFFF),
      blurRadius: 16,
      offset: Offset(0, 0),
    ),
  ];

  static const List<BoxShadow> darkGlassOuter = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}

/// Classe pour gérer les couleurs en fonction du thème
class ThemeColors {
  final bool isDark;

  const ThemeColors({required this.isDark});

  Color get background =>
      isDark ? HezaColors.darkBackground : HezaColors.lightBackground;

  Color get surface =>
      isDark ? HezaColors.darkSurface : HezaColors.lightSurface;

  Color get surfaceAlt =>
      isDark ? HezaColors.darkSurfaceAlt : HezaColors.lightSurfaceAlt;

  Color get onSurface =>
      isDark ? HezaColors.darkOnSurface : HezaColors.lightOnSurface;

  Color get onSurfaceSecondary => isDark
      ? HezaColors.darkOnSurfaceSecondary
      : HezaColors.lightOnSurfaceSecondary;

  Color get border =>
      isDark ? HezaColors.darkBorder : HezaColors.lightBorder;

  // Glass effect color adapté au thème
  Color get glassSurface =>
      isDark ? HezaColors.glassDark : HezaColors.glassLight;

  // Shadows adapté au thème
  List<BoxShadow> get shadowSm =>
      isDark ? HezaShadows.darkGlassOuter : HezaShadows.lightSm;

  List<BoxShadow> get shadowMd =>
      isDark ? HezaShadows.darkGlassOuter : HezaShadows.lightMd;

  List<BoxShadow> get shadowLg =>
      isDark ? HezaShadows.darkGlassOuter : HezaShadows.lightLg;
}
