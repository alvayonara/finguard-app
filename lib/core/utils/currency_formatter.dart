import 'package:intl/intl.dart';
import 'package:finguard_app/core/utils/currency_symbol.dart';

class CurrencyFormatter {
  static String format({
    required double amount,
    required String currencyCode,
    required String locale,
    int decimalDigits = 2,
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: CurrencySymbol.of(currencyCode),
      decimalDigits: decimalDigits,
    );

    return formatter.format(amount);
  }
}
