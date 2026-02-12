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
  String get insightGeneric => 'Terdeteksi aktivitas keuangan yang tidak biasa.';

  @override
  String get insightStable => 'Kondisi keuangan kamu stabil minggu ini.';

  @override
  String get recNegativeCashflow => 'Kurangi pengeluaran non-esensial bulan ini.';

  @override
  String get recExpenseSpike => 'Tahan pengeluaran besar beberapa hari ke depan.';

  @override
  String get recStable => 'Pertahankan pola pengeluaran kamu saat ini.';
}
