import 'package:flutter/material.dart';

/// Palette de couleurs officielle Heza Money
/// Toutes les couleurs de l'application sont définies ici
class AppColors {
  AppColors._();

  // --- Couleurs principales ---
  static const Color primary = Color(0xFF0F6E56);      // Vert profond — header, éléments clés
  static const Color action = Color(0xFF1D9E75);        // Vert vif — boutons d'action
  static const Color accent = Color(0xFF5DCAA5);        // Vert menthe — accents et highlights
  static const Color background = Color(0xFFF5FAF8);    // Blanc naturel — fond général
  static const Color alert = Color(0xFFEF9F27);         // Or ambré — alertes, objectifs

  // --- Variantes de surface ---
  static const Color primaryLight = Color(0xFFE1F5EE);  // Fond léger sur vert profond
  static const Color primarySurface = Color(0xFF0D5C47); // Vert encore plus profond
  static const Color cardBackground = Color(0xFFFFFFFF); // Fond des cartes
  static const Color inputBackground = Color(0xFFF0F9F5); // Fond des champs

  // --- Textes ---
  static const Color textPrimary = Color(0xFF0F2419);   // Texte principal — quasi noir vert
  static const Color textSecondary = Color(0xFF4A6E5E); // Texte secondaire — gris vert
  static const Color textDisabled = Color(0xFF9EC4B3);  // Texte désactivé
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Texte blanc sur fond vert

  // --- États ---
  static const Color success = Color(0xFF1D9E75);
  static const Color warning = Color(0xFFEF9F27);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF1976D2);

  // --- Catégories de dépenses ---
  static const Color catTransport = Color(0xFF2196F3);  // Bleu
  static const Color catFood = Color(0xFFFF7043);       // Orange
  static const Color catLoyer = Color(0xFF9C27B0);      // Violet
  static const Color catCharges = Color(0xFFEF9F27);    // Or
  static const Color catDivers = Color(0xFF607D8B);     // Gris bleu
  static const Color catEpargne = Color(0xFF1D9E75);    // Vert
  static const Color catRevenu = Color(0xFF0F6E56);     // Vert profond

  // --- Mode sombre ---
  static const Color darkBackground = Color(0xFF0D1F17);
  static const Color darkSurface = Color(0xFF162B1F);
  static const Color darkCard = Color(0xFF1E3A2B);
  static const Color darkTextPrimary = Color(0xFFE8F5EE);
  static const Color darkTextSecondary = Color(0xFF7CB99A);

  // --- Niveaux de leçons ---
  static const Color levelDebutant = Color(0xFF1D9E75);
  static const Color levelIntermediaire = Color(0xFFEF9F27);
  static const Color levelAvance = Color(0xFF9C27B0);

  // --- Divider / Séparateur ---
  static const Color divider = Color(0xFFD4EDE3);

  /// Retourne la couleur d'une catégorie de transaction
  static Color forCategory(String category) {
    switch (category.toLowerCase()) {
      case 'transport': return catTransport;
      case 'food':
      case 'alimentation': return catFood;
      case 'loyer': return catLoyer;
      case 'charges': return catCharges;
      case 'epargne':
      case 'épargne': return catEpargne;
      case 'revenu':
      case 'income': return catRevenu;
      default: return catDivers;
    }
  }
}
