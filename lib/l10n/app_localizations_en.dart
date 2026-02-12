// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get insightNegativeCashFlow => 'Your expenses this month are higher than your income.';

  @override
  String get insightExpenseSpike => 'Your spending is much higher than usual.';

  @override
  String get insightGeneric => 'Unusual financial activity detected.';

  @override
  String get insightStable => 'Your financial condition is stable this week.';

  @override
  String get recNegativeCashflow => 'Reduce non-essential expenses this month.';

  @override
  String get recExpenseSpike => 'Avoid large spending for the next few days.';

  @override
  String get recStable => 'Maintain your current spending pattern.';
}
