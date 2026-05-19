import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// AppColors — alias vers HezaColors pour compatibilité
/// Utiliser HezaColors directement dans les nouveaux composants
class AppColors {
  AppColors._();

  static const Color primary       = HezaColors.primary;
  static const Color action        = HezaColors.primaryLight;
  static const Color accent        = HezaColors.accent;
  static const Color background    = HezaColors.lightBg;
  static const Color alert         = HezaColors.warning;

  static const Color primaryLight  = HezaColors.lightBg2;
  static const Color primarySurface= HezaColors.primary;
  static const Color cardBackground= HezaColors.lightSurface;
  static const Color inputBackground= HezaColors.lightSurface;

  static const Color textPrimary   = HezaColors.lightText;
  static const Color textSecondary = HezaColors.lightTextSub;
  static const Color textDisabled  = HezaColors.lightTextMuted;
  static const Color textOnPrimary = HezaColors.lightTextOn;

  static const Color success       = HezaColors.success;
  static const Color warning       = HezaColors.warning;
  static const Color error         = HezaColors.error;
  static const Color info          = HezaColors.info;

  static const Color catTransport  = HezaColors.catTransport;
  static const Color catFood       = HezaColors.catFood;
  static const Color catLoyer      = HezaColors.catLoyer;
  static const Color catCharges    = HezaColors.catCharges;
  static const Color catDivers     = HezaColors.catDivers;
  static const Color catEpargne    = HezaColors.catEpargne;
  static const Color catRevenu     = HezaColors.catRevenu;

  static const Color darkBackground= HezaColors.darkBg;
  static const Color darkSurface   = HezaColors.darkSurface;
  static const Color darkCard      = HezaColors.darkSurface2;
  static const Color darkTextPrimary  = HezaColors.darkText;
  static const Color darkTextSecondary= HezaColors.darkTextSub;

  static const Color divider       = HezaColors.lightBorder;

  static Color forCategory(String category) => HezaColors.forCategory(category);
}
