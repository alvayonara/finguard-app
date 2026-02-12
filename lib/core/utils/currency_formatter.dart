import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format({
    required double amount,
    required String currencyCode,
    required String locale,
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: _symbol(currencyCode),
      decimalDigits: 0,
    );

    return formatter.format(amount);
  }

  static String _symbol(String code) {
    switch (code) {
      case 'IDR':
        return 'Rp ';
      case 'USD':
        return '\$ ';
      default:
        return '';
    }
  }
}
