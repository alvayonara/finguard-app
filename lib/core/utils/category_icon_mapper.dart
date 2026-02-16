class CategoryIconMapper {
  static String getIcon(String iconCode) {
    final Map<String, String> iconMap = {
      'restaurant': '🍽️',
      'food': '🍔',
      'fastfood': '🍕',
      'cafe': '☕',
      'coffee': '☕',

      'shopping_bag': '🛍️',
      'shopping': '🛍️',
      'shopping_cart': '🛒',
      'store': '🏪',
      'clothes': '👕',

      'home': '🏠',
      'house': '🏠',
      'bills': '📄',
      'receipt_long': '🧾',
      'receipt': '🧾',

      'directions_car': '🚗',
      'car': '🚙',
      'transport': '🚌',
      'bus': '🚌',
      'subway': '🚇',
      'train': '🚆',
      'gas': '⛽',
      'fuel': '⛽',
      'flight': '✈️',
      'travel': '🧳',
      'hotel': '🏨',

      'entertainment': '🎬',
      'game': '🎮',
      'gaming': '🎮',
      'movie': '🎬',
      'movies': '🎬',
      'film': '🎬',
      'cinema': '🎬',
      'sports': '⚽',
      'sport': '⚽',

      'school': '🎓',
      'education': '📚',
      'book': '📚',

      'local_hospital': '🏥',
      'hospital': '🏥',
      'health': '💊',
      'medicine': '💊',
      'fitness': '💪',
      'gym': '💪',

      'phone': '📱',
      'mobile': '📱',

      'work': '💼',
      'briefcase': '💼',
      'freelance': '💼',
      'salary': '💵',
      'attach_money': '💵',
      'money': '💵',
      'money_bag': '💰',
      'moneybag': '💰',
      'account_balance': '🏦',
      'bank': '🏦',
      'gift': '🎁',
      'card_giftcard': '🎁',
      'gift_card': '🎁',
      'bonus': '🎁',
      'trending_up': '📈',
      'analytics': '📈',
      'investment': '📈',
      'invest': '📈',
      'wallet': '👛',
      'coin': '🪙',
      'card': '💳',
      'chart': '📊',
      'star': '⭐',

      'other': '📦',
      'pets': '🐾',
      'pet': '🐾',
      'tools': '🔧',
      'tool': '🔧',

      'category': '📦',
      'push_pin': '📦',
      'pushpin': '📦',
      'pin': '📦',
      'default': '📦',
    };

    final normalized = iconCode.trim();
    if (normalized.isEmpty) {
      return iconMap['default']!;
    }

    if (_looksLikeEmoji(normalized)) {
      return normalized;
    }

    final lower = normalized.toLowerCase();
    final normalizedKey = lower.replaceAll(RegExp(r'[\s\-]'), '_');

    String? mapped = iconMap[lower] ?? iconMap[normalizedKey];

    if (mapped == null &&
        normalized.startsWith(':') &&
        normalized.endsWith(':')) {
      final shortcode = normalized
          .substring(1, normalized.length - 1)
          .toLowerCase()
          .replaceAll(RegExp(r'[\s\-]'), '_');
      mapped = iconMap[shortcode];
    }

    if (mapped != null) {
      return mapped;
    }

    return iconMap['default']!;
  }

  static bool _looksLikeEmoji(String value) {
    final hasAsciiWordChar = RegExp(r'[A-Za-z0-9_]').hasMatch(value);
    final hasNonAscii = value.runes.any((rune) => rune > 0x7F);
    return hasNonAscii && !hasAsciiWordChar;
  }

  static List<String> get incomeEmojis => [
    '💼',
    '💰',
    '💵',
    '🏦',
    '🎁',
    '📈',
    '🪙',
    '💳',
    '🧾',
    '📊',
    '⭐',
    '👛',
  ];

  static List<String> get expenseEmojis => [
    '🍽️',
    '🍔',
    '🍕',
    '☕',
    '🛒',
    '🛍️',
    '🏠',
    '🚗',
    '🚙',
    '🚌',
    '⛽',
    '🎬',
    '🎮',
    '✈️',
    '🧳',
    '🏨',
    '💊',
    '🏥',
    '📱',
    '👕',
    '🎓',
    '📚',
    '⚽',
    '💪',
    '🐾',
    '📦',
    '📄',
    '🔧',
    '🏪',
  ];

  static List<String> emojisByType(String type) {
    return type.toUpperCase() == 'INCOME' ? incomeEmojis : expenseEmojis;
  }

  static List<String> get allEmojis => [...expenseEmojis, ...incomeEmojis];
}
