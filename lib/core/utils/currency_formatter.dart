import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format({
    required double amount,
    required String currencyCode,
    required String locale,
    int decimalDigits = 2,
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: _symbol(currencyCode),
      decimalDigits: decimalDigits,
    );

    return formatter.format(amount);
  }

  static String _symbol(String code) {
    switch (code.toUpperCase()) {
      case 'IDR':
        return 'Rp ';
      case 'USD':
        return '\$ ';
      case 'JPY':
        return '¥ ';
      case 'EUR':
        return '€ ';
      case 'SGD':
        return 'S\$ ';
      default:
        return '${code.toUpperCase()} ';
    }
  }
}
