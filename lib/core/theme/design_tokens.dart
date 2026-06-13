import 'package:flutter/material.dart';

// ─── PALETTE HEZA MONEY — PREMIUM FINANCIAL DARK ────────────────────────────
// Design system : Modern Dark Cinema × Financial Dashboard
// Source : ui-ux-pro-max + Financial Dashboard color palette
// ─────────────────────────────────────────────────────────────────────────────

class HezaColors {
  HezaColors._();

  // ── BRAND VERT (identité Heza Money) ───────────────────────────────────────
  static const Color primary       = Color(0xFF0F6E56); // Vert profond (light mode)
  static const Color primaryLight  = Color(0xFF22C55E); // Vert financier vif (dark mode)
  static const Color accent        = Color(0xFF4ADE80); // Vert lumineux (accents dark)
  static const Color accentSoft    = Color(0xFF86EFAC); // Vert doux (badges dark)

  // ── FONCTIONNEL ───────────────────────────────────────────────────────────
  static const Color success       = Color(0xFF22C55E);
  static const Color successSoft   = Color(0xFF14532D);
  static const Color warning       = Color(0xFFF59E0B);
  static const Color warningSoft   = Color(0xFF78350F);
  static const Color error         = Color(0xFFEF4444);
  static const Color errorSoft     = Color(0xFF7F1D1D);
  static const Color info          = Color(0xFF3B82F6);

  // ── CATÉGORIES ────────────────────────────────────────────────────────────
  static const Color catTransport  = Color(0xFF3B82F6);
  static const Color catFood       = Color(0xFFF97316);
  static const Color catLoyer      = Color(0xFFA855F7);
  static const Color catCharges    = Color(0xFFF59E0B);
  static const Color catDivers     = Color(0xFF64748B);
  static const Color catEpargne    = Color(0xFF22C55E);
  static const Color catRevenu     = Color(0xFF0F6E56);

  // ── LIGHT MODE SURFACES ───────────────────────────────────────────────────
  static const Color lightBg       = Color(0xFFF0F9F5);
  static const Color lightBg2      = Color(0xFFE8F5EE);
  static const Color lightSurface  = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFF9FAFB);
  static const Color lightBorder   = Color(0xFFD4EDE3);

  // ── DARK MODE SURFACES — Premium Financial Dark ───────────────────────────
  // Source : Financial Dashboard palette (#020617 bg, #0E1223 card)
  static const Color darkBg        = Color(0xFF020617); // Fond deep navy-black
  static const Color darkBg2       = Color(0xFF0E1223); // Fond secondaire / cards
  static const Color darkSurface   = Color(0xFF131929); // Surface élevée
  static const Color darkSurface2  = Color(0xFF1B2336); // Surface haute élévation
  static const Color darkBorder    = Color(0xFF1E293B); // Slate-800

  // ── LIGHT MODE TEXTES ─────────────────────────────────────────────────────
  static const Color lightText     = Color(0xFF0F2419);
  static const Color lightTextSub  = Color(0xFF4A6E5E);
  static const Color lightTextMuted= Color(0xFF9EC4B3);
  static const Color lightTextOn   = Color(0xFFFFFFFF);

  // ── DARK MODE TEXTES — Slate palette (lisibilité maximale) ────────────────
  static const Color darkText      = Color(0xFFF8FAFC); // Slate-50 — near-white
  static const Color darkTextSub   = Color(0xFF94A3B8); // Slate-400
  static const Color darkTextMuted = Color(0xFF475569); // Slate-600

  // ── GLASSMORPHISM ────────────────────────────────────────────────────────
  // Hairline border blanc pour dark mode (rgba(255,255,255,0.08))
  static const Color glassHairline = Color(0x14FFFFFF);
  // Opacité des cartes glass par mode
  static double get glassOpacityLight => 0.80;
  static double get glassOpacityDark  => 0.88;

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
  static const double overlay = 30.0;
}

// ─── SHADOWS ────────────────────────────────────────────────────────────────
class HezaShadows {
  HezaShadows._();

  static const List<BoxShadow> lightSm = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> lightMd = [
    BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> lightLg = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, 8)),
  ];

  // Dark mode — ombres profondes sur fond navy-black
  static const List<BoxShadow> darkSm = [
    BoxShadow(color: Color(0x55000000), blurRadius: 8,  offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> darkMd = [
    BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x0A22C55E), blurRadius: 12, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> darkLg = [
    BoxShadow(color: Color(0x77000000), blurRadius: 32, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x0F22C55E), blurRadius: 20, offset: Offset(0, 4)),
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

  // Primaire
  Color get primary     => isDark ? HezaColors.primaryLight  : HezaColors.primary;
  Color get accent      => isDark ? HezaColors.accent        : HezaColors.accent;

  // Glass — base de toutes les cartes glassmorphiques
  Color get glassBg     => isDark ? HezaColors.darkBg2       : HezaColors.lightSurface;
  double get glassOpacity => isDark
      ? HezaColors.glassOpacityDark
      : HezaColors.glassOpacityLight;

  // Bordure glassmorphique
  // Dark : hairline blanc rgba(255,255,255,0.08) — standard premium dark glass
  // Light : bordure verte subtile
  Color get glassBorder => isDark
      ? HezaColors.glassHairline
      : HezaColors.primary.withValues(alpha: 0.15);

  // Bordure top-edge highlight (plus lumineuse en haut des cartes dark)
  Color get glassTopEdge => isDark
      ? const Color(0x1FFFFFFF)   // rgba(255,255,255,0.12) — top shimmer
      : HezaColors.primary.withValues(alpha: 0.20);

  // Shadows
  List<BoxShadow> get shadowSm => isDark ? HezaShadows.darkSm : HezaShadows.lightSm;
  List<BoxShadow> get shadowMd => isDark ? HezaShadows.darkMd : HezaShadows.lightMd;
  List<BoxShadow> get shadowLg => isDark ? HezaShadows.darkLg : HezaShadows.lightLg;
}
