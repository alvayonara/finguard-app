import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###');
  final bool allowDecimal;
  final int maxDecimalDigits;

  ThousandsSeparatorInputFormatter({
    this.allowDecimal = false,
    this.maxDecimalDigits = 2,
  });

  static String formatAmount(double value, {int maxDecimalDigits = 2}) {
    return formatAmountFixed(
      value,
      decimalDigits: maxDecimalDigits,
      trimTrailingZeros: true,
    );
  }

  static String formatAmountFixed(
    double value, {
    int decimalDigits = 2,
    bool trimTrailingZeros = false,
  }) {
    final hasDecimal = value % 1 != 0;
    if (!hasDecimal && trimTrailingZeros) {
      return NumberFormat('#,###').format(value);
    }

    final pattern = '#,##0.${'0' * decimalDigits}';
    var text = NumberFormat(pattern).format(value);
    if (trimTrailingZeros && text.contains('.')) {
      text = text.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    return text;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final rawInput = newValue.text.replaceAll(',', '');

    if (!allowDecimal) {
      final numericOnly = rawInput.replaceAll(RegExp(r'[^0-9]'), '');
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

    final sanitized = rawInput.replaceAll(RegExp(r'[^0-9.]'), '');
    if (sanitized.isEmpty) {
      return const TextEditingValue();
    }

    final firstDotIndex = sanitized.indexOf('.');
    String normalized = sanitized;
    if (firstDotIndex != -1) {
      final beforeDot = sanitized.substring(0, firstDotIndex);
      final afterDot =
          sanitized.substring(firstDotIndex + 1).replaceAll('.', '');
      normalized = '$beforeDot.$afterDot';
    }

    final parts = normalized.split('.');
    final integerPartRaw = parts.first;
    var decimalPart = parts.length > 1 ? parts[1] : '';
    if (decimalPart.length > maxDecimalDigits) {
      decimalPart = decimalPart.substring(0, maxDecimalDigits);
    }

    final integerPart = integerPartRaw.isEmpty ? '0' : integerPartRaw;
    final integerNumber = int.tryParse(integerPart);
    if (integerNumber == null) {
      return oldValue;
    }

    final formattedInteger = _formatter.format(integerNumber);
    final hadDecimal = normalized.contains('.');
    final formatted =
        hadDecimal ? '$formattedInteger.$decimalPart' : formattedInteger;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
