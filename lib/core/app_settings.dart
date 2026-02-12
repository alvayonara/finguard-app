import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppSettings extends ChangeNotifier {
  Locale _locale = const Locale('id');
  String _currency = 'IDR';

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
      symbol: _currency == 'IDR' ? 'Rp ' : '\$ ',
      decimalDigits: _currency == 'IDR' ? 0 : 2,
    );
    return format.format(value);
  }
}