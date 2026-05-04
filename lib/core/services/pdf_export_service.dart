import 'dart:io' show File, Directory;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../database/app_database.dart';

/// Service pour exporter un bilan mensuel en PDF
class PdfExportService {
  static final PdfExportService _instance = PdfExportService._internal();

  factory PdfExportService() {
    return _instance;
  }

  PdfExportService._internal();

  /// Génère et sauvegarde un PDF du bilan mensuel
  /// Retourne le chemin du fichier généré
  Future<String> exportMonthlyBilan({
    required String userName,
    required double salary,
    required String currency,
    required List<Transaction> transactions,
    required List<Goal> goals,
    required int financialScore,
    DateTime? date,
  }) async {
    date ??= DateTime.now();

    // Créer le document PDF
    final pdf = pw.Document();

    // Calculer les stats du mois
    final expenses = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (s, t) => s + t.amount);
    final income = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (s, t) => s + t.amount);
    final savings = transactions
        .where((t) => t.category == 'epargne')
        .fold(0.0, (s, t) => s + t.amount);

    // Dépenses par catégorie
    final expensesByCategory = <String, double>{};
    for (final t in transactions.where((t) => t.type == 'expense')) {
      expensesByCategory[t.category] =
          (expensesByCategory[t.category] ?? 0) + t.amount;
    }

    // Règle 50/30/20
    final needs = salary * 0.50;
    final wants = salary * 0.30;
    final savingsTarget = salary * 0.20;

    final needsSpent = transactions
        .where((t) =>
            t.type == 'expense' &&
            ['loyer', 'food', 'transport', 'charges'].contains(t.category))
        .fold(0.0, (s, t) => s + t.amount);
    final wantsSpent = transactions
        .where((t) => t.type == 'expense' && t.category == 'divers')
        .fold(0.0, (s, t) => s + t.amount);

    // Ajouter une page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // --- En-tête ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'HEZA MONEY',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('0F6E56'),
                      ),
                    ),
                    pw.Text(
                      'Bilan mensuel',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColor.fromHex('666666'),
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  DateFormat('MMMM yyyy', 'fr_FR').format(date).toUpperCase(),
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // --- Infos utilisateur ---
            pw.Text(
              'Bilan de $userName',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),

            // --- Stats principales ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox(
                  'Salaire',
                  AppFormatters.formatNumber(salary),
                  currency,
                ),
                _buildStatBox(
                  'Dépenses',
                  AppFormatters.formatNumber(expenses),
                  currency,
                ),
                _buildStatBox(
                  'Épargne',
                  AppFormatters.formatNumber(savings),
                  currency,
                ),
                _buildStatBox(
                  'Score',
                  '$financialScore/100',
                  '',
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // --- Règle 50/30/20 ---
            pw.Text(
              'Règle 50/30/20',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            _build502030Table(needs, wants, savingsTarget, needsSpent,
                wantsSpent, savings, currency),
            pw.SizedBox(height: 20),

            // --- Dépenses par catégorie ---
            pw.Text(
              'Dépenses par catégorie',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            _buildExpenseCategoryTable(expensesByCategory, currency),
            pw.SizedBox(height: 20),

            // --- Objectifs ---
            if (goals.isNotEmpty) ...[
              pw.Text(
                'Objectifs d\'épargne',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildGoalsTable(goals, currency),
              pw.SizedBox(height: 20),
            ],

            // Footer
            pw.Spacer(),
            pw.Text(
              'Généré le ${DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(DateTime.now())}',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColor.grey,
              ),
            ),
          ],
        ),
      ),
    );

    // Sauvegarder le fichier
    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'Heza_Bilan_${DateFormat('yyyy-MM', 'fr_FR').format(date)}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  /// Widget boîte stat
  static pw.Widget _buildStatBox(
    String label,
    String value,
    String unit,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('D4EDE3')),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (unit.isNotEmpty)
            pw.Text(
              unit,
              style: const pw.TextStyle(fontSize: 9),
            ),
        ],
      ),
    );
  }

  /// Table 50/30/20
  static pw.Widget _build502030Table(
    double needs,
    double wants,
    double savingsTarget,
    double needsSpent,
    double wantsSpent,
    double savingsActual,
    String currency,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColor.fromHex('D4EDE3'),
        width: 1,
      ),
      children: [
        _buildTableRow(
          ['Catégorie', 'Cible', 'Dépensé', 'Pourcentage'],
          isHeader: true,
        ),
        _buildTableRow([
          '50% Besoins',
          AppFormatters.formatNumber(needs),
          AppFormatters.formatNumber(needsSpent),
          '${((needsSpent / needs) * 100).toStringAsFixed(1)}%',
        ]),
        _buildTableRow([
          '30% Envies',
          AppFormatters.formatNumber(wants),
          AppFormatters.formatNumber(wantsSpent),
          '${((wantsSpent / wants) * 100).toStringAsFixed(1)}%',
        ]),
        _buildTableRow([
          '20% Épargne',
          AppFormatters.formatNumber(savingsTarget),
          AppFormatters.formatNumber(savingsActual),
          '${((savingsActual / savingsTarget) * 100).toStringAsFixed(1)}%',
        ]),
      ],
    );
  }

  /// Table catégories
  static pw.Widget _buildExpenseCategoryTable(
    Map<String, double> categories,
    String currency,
  ) {
    final sorted = (categories.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(7)
        .toList();

    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColor.fromHex('D4EDE3'),
        width: 1,
      ),
      children: [
        _buildTableRow(['Catégorie', 'Montant', 'Pourcentage'], isHeader: true),
        ...sorted.map((e) {
          final total = categories.values.fold(0.0, (s, v) => s + v);
          final pct = total > 0 ? (e.value / total) * 100 : 0.0;
          return _buildTableRow([
            _categoryLabel(e.key),
            AppFormatters.formatNumber(e.value),
            '${pct.toStringAsFixed(1)}%',
          ]);
        }),
      ],
    );
  }

  /// Table objectifs
  static pw.Widget _buildGoalsTable(
    List<Goal> goals,
    String currency,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColor.fromHex('D4EDE3'),
        width: 1,
      ),
      children: [
        _buildTableRow(['Objectif', 'Cible', 'Épargné', 'Progression'],
            isHeader: true),
        ...goals.map((g) {
          final pct = g.targetAmount > 0
              ? ((g.currentAmount / g.targetAmount) * 100).toStringAsFixed(1)
              : '0.0';
          return _buildTableRow([
            g.title,
            AppFormatters.formatNumber(g.targetAmount),
            AppFormatters.formatNumber(g.currentAmount),
            '$pct%',
          ]);
        }),
      ],
    );
  }

  /// Row de table
  static pw.TableRow _buildTableRow(
    List<String> cells, {
    bool isHeader = false,
  }) {
    return pw.TableRow(
      decoration: isHeader
          ? pw.BoxDecoration(
              color: PdfColor.fromHex('0F6E56'),
            )
          : null,
      children: cells.map((cell) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            cell,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isHeader ? PdfColors.white : PdfColors.black,
            ),
          ),
        );
      }).toList(),
    );
  }

  static String _categoryLabel(String cat) {
    const labels = {
      'transport': 'Transport',
      'food': 'Alimentation',
      'loyer': 'Loyer',
      'charges': 'Charges',
      'epargne': 'Épargne',
      'divers': 'Divers',
      'revenu': 'Revenu',
      'income': 'Revenu',
    };
    return labels[cat.toLowerCase()] ?? cat;
  }
}
