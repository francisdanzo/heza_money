import 'dart:io' show File;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../data/database/app_database.dart';

class CsvExportService {
  static final CsvExportService _instance = CsvExportService._internal();
  factory CsvExportService() => _instance;
  CsvExportService._internal();

  /// Génère un CSV de toutes les transactions et retourne le chemin du fichier.
  Future<String> exportTransactions({
    required List<Transaction> transactions,
    required String currency,
  }) async {
    final buf = StringBuffer();
    buf.writeln('Date,Type,Catégorie,Montant ($currency),Note');

    final fmt = DateFormat('dd/MM/yyyy');
    for (final t in transactions) {
      final date     = fmt.format(t.date);
      final type     = t.type == 'income' ? 'Revenu' : 'Dépense';
      final category = _catLabel(t.category);
      final amount   = t.amount.toStringAsFixed(0);
      final note     = (t.note ?? '').replaceAll('"', '""');
      buf.writeln('$date,$type,$category,$amount,"$note"');
    }

    final dir      = await getApplicationDocumentsDirectory();
    final now      = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final filePath = p.join(dir.path, 'heza_money_$now.csv');
    await File(filePath).writeAsString(buf.toString());
    return filePath;
  }

  static String _catLabel(String cat) {
    const labels = {
      'transport': 'Transport', 'food': 'Alimentation', 'loyer': 'Loyer',
      'charges': 'Charges', 'epargne': 'Épargne', 'divers': 'Divers',
      'revenu': 'Revenu', 'income': 'Revenu',
    };
    return labels[cat.toLowerCase()] ?? cat;
  }
}
