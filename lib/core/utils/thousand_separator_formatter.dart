import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numericOnly.isEmpty) {
      return const TextEditingValue();
    }

    final number = int.tryParse(numericOnly);
    if (number == null) {
      return oldValue;
    }

    final formatted = _formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
