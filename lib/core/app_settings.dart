import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppSettings extends ChangeNotifier {
  Locale _locale = const Locale('en');
  String _currency = 'USD';

  Locale get locale => _locale;
  String get currency => _currency;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void setCurrency(String currency) {
    _currency = currency;
    notifyListeners();
  }

  String formatCurrency(double value) {
    final format = NumberFormat.currency(
      locale: _locale.toLanguageTag(),
      symbol: _currencySymbol(_currency),
      decimalDigits: _decimalDigits(_currency),
    );
    return format.format(value);
  }

  String _currencySymbol(String code) {
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

  int _decimalDigits(String code) {
    switch (code.toUpperCase()) {
      case 'IDR':
      case 'JPY':
        return 0;
      default:
        return 2;
    }
  }
}
