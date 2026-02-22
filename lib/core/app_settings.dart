import 'package:flutter/material.dart';
import 'package:finguard/core/utils/currency_symbol.dart';
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
      symbol: CurrencySymbol.of(_currency),
      decimalDigits: 2,
    );
    return format.format(value);
  }
}
