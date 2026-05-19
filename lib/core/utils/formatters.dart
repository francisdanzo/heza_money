import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formateurs utilitaires pour Heza Money
/// — Montants BIF avec séparateurs de milliers
/// — Dates en français
class AppFormatters {
  AppFormatters._();

  // Formateur de nombre avec espace comme séparateur de milliers
  static final NumberFormat _bifFormatter = NumberFormat(
    '#,##0',
    'fr_FR',
  );

  // Formateur de nombre décimal
  static final NumberFormat _decimalFormatter = NumberFormat(
    '#,##0.##',
    'fr_FR',
  );

  /// Formate un montant avec la devise → "700 000 BIF"
  static String formatAmount(double amount, {String currency = 'BIF'}) {
    final formatted = _bifFormatter.format(amount.abs());
    // Remplace les virgules par des espaces (style français)
    final spaced = formatted.replaceAll(',', ' ');
    return '$spaced $currency';
  }

  /// Formate un montant compact sans devise → "700 000"
  static String formatNumber(double amount) {
    return _bifFormatter.format(amount.abs()).replaceAll(',', ' ');
  }

  /// Formate un montant décimal → "1 250,50"
  static String formatDecimal(double amount) {
    return _decimalFormatter.format(amount).replaceAll(',', '\u00A0');
  }

  /// Formate un pourcentage → "42%"
  static String formatPercent(double value, {int decimals = 0}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Format de date long en français → "lundi 3 mai 2026"
  static String formatDateLong(DateTime date) {
    return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
  }

  /// Format de date court → "3 mai 2026"
  static String formatDateMedium(DateTime date) {
    return DateFormat('d MMMM yyyy', 'fr_FR').format(date);
  }

  /// Format de date très court → "03/05/2026"
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format mois + année → "mai 2026"
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'fr_FR').format(date);
  }

  /// Format jour court → "lun. 3 mai"
  static String formatDayShort(DateTime date) {
    return DateFormat('EEE d MMM', 'fr_FR').format(date);
  }

  /// Retourne "Aujourd'hui", "Hier", ou la date courte
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Hier';
    if (diff < 7) return formatDayShort(date);
    return formatDateMedium(date);
  }

  /// Calcule le nombre de mois restants jusqu'à une deadline
  static int monthsUntil(DateTime deadline) {
    final now = DateTime.now();
    return ((deadline.year - now.year) * 12 + deadline.month - now.month)
        .clamp(0, 9999);
  }

  /// Retourne le nom du mois courant
  static String currentMonthName() {
    return DateFormat('MMMM', 'fr_FR').format(DateTime.now());
  }

  /// Formate une durée en mois → "6 mois", "1 an 3 mois"
  static String formatDuration(int months) {
    if (months < 12) return '$months mois';
    final years = months ~/ 12;
    final rem = months % 12;
    if (rem == 0) return '$years an${years > 1 ? 's' : ''}';
    return '$years an${years > 1 ? 's' : ''} $rem mois';
  }
}

/// TextInputFormatter qui ajoute des espaces tous les 3 chiffres (ex: 500 000).
class ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
