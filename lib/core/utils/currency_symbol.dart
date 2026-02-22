class CurrencySymbol {
  static String of(String code, {bool trailingSpace = true}) {
    String symbol;
    switch (code.toUpperCase()) {
      case 'IDR':
        symbol = 'Rp';
        break;
      case 'USD':
        symbol = '\$';
        break;
      case 'JPY':
        symbol = '¥';
        break;
      case 'EUR':
        symbol = '€';
        break;
      case 'SGD':
        symbol = 'S\$';
        break;
      default:
        symbol = code.toUpperCase();
    }

    return trailingSpace ? '$symbol ' : symbol;
  }
}
