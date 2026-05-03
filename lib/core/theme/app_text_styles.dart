import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Système de typographie Inter pour Heza Money
/// Inter 400 = corps de texte, Inter 500 = titres
class AppTextStyles {
  AppTextStyles._();

  // --- Display (grands chiffres de solde) ---
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // --- Headlines (titres de section) ---
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // --- Title (titres de cards) ---
  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // --- Body (corps de texte) ---
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // --- Label (badges, pills, chips) ---
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // --- Montants financiers ---
  static const TextStyle amountLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle amountMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle amountSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // --- Variantes blanches (pour fond vert) ---
  static TextStyle onPrimary(TextStyle base) =>
      base.copyWith(color: AppColors.textOnPrimary);

  static TextStyle secondary(TextStyle base) =>
      base.copyWith(color: AppColors.textSecondary);

  static TextStyle colored(TextStyle base, Color color) =>
      base.copyWith(color: color);
}
