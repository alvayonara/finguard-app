// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get insightNegativeCashFlow => 'Pengeluaran bulan ini lebih besar dari pemasukan.';

  @override
  String get insightExpenseSpike => 'Pengeluaran kamu jauh lebih besar dari rata-rata biasanya.';

  @override
  String get insightBudgetExceeded => 'Kamu telah melampaui batas anggaran.';

  @override
  String get insightSpendingSpike => 'Pengeluaran kamu meningkat signifikan.';

  @override
  String get insightStable => 'Kondisi keuangan kamu stabil minggu ini.';

  @override
  String get insightLowRisk => 'Kondisi keuangan kamu sehat. Pertahankan!';

  @override
  String get insightMediumRisk => 'Keuangan kamu perlu perhatian.';

  @override
  String get insightHighRisk => 'Tindakan segera diperlukan untuk keuangan kamu.';

  @override
  String get recNegativeCashflow => 'Kurangi pengeluaran non-esensial bulan ini.';

  @override
  String get recExpenseSpike => 'Tahan pengeluaran besar beberapa hari ke depan.';

  @override
  String get recBudgetExceeded => 'Tinjau anggaran dan sesuaikan pengeluaran.';

  @override
  String get recStable => 'Pertahankan pola pengeluaran kamu saat ini.';
}
