import 'package:flutter/material.dart';

// ─── PALETTE HEZA MONEY ─────────────────────────────────────────────────────
// Couleurs sémantiques pour glassmorphisme dark/light
// Utiliser ces tokens partout — jamais de hex bruts dans les écrans
// ─────────────────────────────────────────────────────────────────────────────

class HezaColors {
  HezaColors._();

  // ── BRAND VERT (identité Heza Money) ───────────────────────────────────────
  static const Color primary       = Color(0xFF0F6E56); // Vert profond (light mode)
  static const Color primaryLight  = Color(0xFF1D9E75); // Vert vif (dark mode + hover)
  static const Color accent        = Color(0xFF5DCAA5); // Vert menthe (accents)
  static const Color accentSoft    = Color(0xFFA8E6D4); // Vert doux (dark mode accents)

  // ── FONCTIONNEL ───────────────────────────────────────────────────────────
  static const Color success       = Color(0xFF1D9E75);
  static const Color successSoft   = Color(0xFFDCFCE7);
  static const Color warning       = Color(0xFFEF9F27);
  static const Color warningSoft   = Color(0xFFFEF9C3);
  static const Color error         = Color(0xFFDC2626);
  static const Color errorSoft     = Color(0xFFFEE2E2);
  static const Color info          = Color(0xFF0284C7);

  // ── CATÉGORIES ────────────────────────────────────────────────────────────
  static const Color catTransport  = Color(0xFF2196F3);
  static const Color catFood       = Color(0xFFFF7043);
  static const Color catLoyer      = Color(0xFF9C27B0);
  static const Color catCharges    = Color(0xFFEF9F27);
  static const Color catDivers     = Color(0xFF607D8B);
  static const Color catEpargne    = Color(0xFF1D9E75);
  static const Color catRevenu     = Color(0xFF0F6E56);

  // ── LIGHT MODE SURFACES ───────────────────────────────────────────────────
  static const Color lightBg       = Color(0xFFF0F9F5); // Fond général (blanc naturel)
  static const Color lightBg2      = Color(0xFFE8F5EE); // Fond secondaire léger
  static const Color lightSurface  = Color(0xFFFFFFFF); // Surface de carte
  static const Color lightSurface2 = Color(0xFFF9FAFB); // Surface secondaire
  static const Color lightBorder   = Color(0xFFD4EDE3); // Bordure subtile

  // ── DARK MODE SURFACES ────────────────────────────────────────────────────
  static const Color darkBg        = Color(0xFF0A1810); // Fond (vert-noir profond)
  static const Color darkBg2       = Color(0xFF0F2419); // Fond secondaire
  static const Color darkSurface   = Color(0xFF162B1F); // Surface de carte
  static const Color darkSurface2  = Color(0xFF1E3A2B); // Surface secondaire
  static const Color darkBorder    = Color(0xFF2D4A38); // Bordure subtile

  // ── LIGHT MODE TEXTES ─────────────────────────────────────────────────────
  static const Color lightText     = Color(0xFF0F2419); // Texte principal
  static const Color lightTextSub  = Color(0xFF4A6E5E); // Texte secondaire
  static const Color lightTextMuted= Color(0xFF9EC4B3); // Texte désactivé
  static const Color lightTextOn   = Color(0xFFFFFFFF); // Sur fond vert

  // ── DARK MODE TEXTES ──────────────────────────────────────────────────────
  static const Color darkText      = Color(0xFFE8F5EE); // Texte principal
  static const Color darkTextSub   = Color(0xFF7CB99A); // Texte secondaire
  static const Color darkTextMuted = Color(0xFF4A7060); // Texte désactivé

  // ── GLASS EFFECT ──────────────────────────────────────────────────────────
  // Opacités recommandées par mode dans GlassCard
  static double get glassOpacityLight => 0.75;
  static double get glassOpacityDark  => 0.10;

  // Retourne la couleur d'une catégorie de transaction
  static Color forCategory(String category) {
    switch (category.toLowerCase()) {
      case 'transport':              return catTransport;
      case 'food':
      case 'alimentation':           return catFood;
      case 'loyer':                  return catLoyer;
      case 'charges':                return catCharges;
      case 'epargne':
      case 'épargne':                return catEpargne;
      case 'revenu':
      case 'income':                 return catRevenu;
      default:                       return catDivers;
    }
  }
}

// ─── ESPACEMENT ─────────────────────────────────────────────────────────────
class HezaSpacing {
  HezaSpacing._();
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 24.0;
  static const double xxl  = 32.0;
  static const double xxxl = 48.0;
}

// ─── BORDER RADIUS ──────────────────────────────────────────────────────────
class HezaRadius {
  HezaRadius._();
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double full = 99.0;
}

// ─── BLUR / GLASSMORPHISM ────────────────────────────────────────────────────
class HezaBlur {
  HezaBlur._();
  static const double subtle  = 8.0;
  static const double normal  = 15.0;
  static const double strong  = 20.0;
  static const double overlay = 25.0;
}

// ─── SHADOWS ────────────────────────────────────────────────────────────────
class HezaShadows {
  HezaShadows._();

  static const List<BoxShadow> lightSm = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> lightMd = [
    BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> lightLg = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> darkSm = [
    BoxShadow(color: Color(0x33000000), blurRadius: 8,  offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> darkMd = [
    BoxShadow(color: Color(0x40000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> darkLg = [
    BoxShadow(color: Color(0x55000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

// ─── HELPER THÈME CONTEXTUEL ─────────────────────────────────────────────────
// Usage: final t = HezaTheme.of(context);
class HezaTheme {
  final bool isDark;
  const HezaTheme({required this.isDark});

  static HezaTheme of(BuildContext context) =>
      HezaTheme(isDark: Theme.of(context).brightness == Brightness.dark);

  // Surfaces
  Color get bg          => isDark ? HezaColors.darkBg        : HezaColors.lightBg;
  Color get bg2         => isDark ? HezaColors.darkBg2       : HezaColors.lightBg2;
  Color get surface     => isDark ? HezaColors.darkSurface   : HezaColors.lightSurface;
  Color get surface2    => isDark ? HezaColors.darkSurface2  : HezaColors.lightSurface2;
  Color get border      => isDark ? HezaColors.darkBorder    : HezaColors.lightBorder;

  // Textes
  Color get text        => isDark ? HezaColors.darkText      : HezaColors.lightText;
  Color get textSub     => isDark ? HezaColors.darkTextSub   : HezaColors.lightTextSub;
  Color get textMuted   => isDark ? HezaColors.darkTextMuted : HezaColors.lightTextMuted;

  // Primaire (adapté au mode)
  Color get primary     => isDark ? HezaColors.primaryLight  : HezaColors.primary;
  Color get accent      => isDark ? HezaColors.accentSoft    : HezaColors.accent;

  // Glass
  Color get glassBg     => isDark ? HezaColors.darkSurface   : HezaColors.lightSurface;
  double get glassOpacity => isDark ? HezaColors.glassOpacityDark : HezaColors.glassOpacityLight;

  // Bordure glassmorphique
  Color get glassBorder  => isDark
      ? HezaColors.accent.withValues(alpha: 0.15)
      : HezaColors.primary.withValues(alpha: 0.15);

  // Shadows
  List<BoxShadow> get shadowSm => isDark ? HezaShadows.darkSm : HezaShadows.lightSm;
  List<BoxShadow> get shadowMd => isDark ? HezaShadows.darkMd : HezaShadows.lightMd;
  List<BoxShadow> get shadowLg => isDark ? HezaShadows.darkLg : HezaShadows.lightLg;
}
