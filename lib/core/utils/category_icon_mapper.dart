class CategoryIconMapper {
  static String getIcon(String iconCode) {
    final Map<String, String> iconMap = {
      // Bills & Services
      'receipt_long': '🧾',
      'receipt': '🧾',
      'bills': '📄',

      // Education
      'school': '🎓',
      'education': '📚',

      // Entertainment
      'movie': '🎬',
      'entertainment': '🎮',
      'sports': '⚽',

      // Food & Dining
      'restaurant': '🍽️',
      'food': '🍔',
      'fastfood': '🍕',
      'cafe': '☕',

      // Health
      'local_hospital': '🏥',
      'health': '💊',
      'fitness': '💪',

      // Shopping
      'shopping_bag': '🛍️',
      'shopping': '🛍️',
      'shopping_cart': '🛒',
      'store': '🏪',

      // Transport
      'directions_car': '🚗',
      'transport': '🚌',
      'car': '🚙',
      'subway': '🚇',
      'train': '🚆',

      // Travel
      'flight': '✈️',
      'travel': '🧳',
      'hotel': '🏨',

      // Income
      'work': '💼',
      'salary': '💵',
      'gift': '🎁',
      'card_giftcard': '🎁',
      'gift_card': '🎁',
      'attach_money': '💵',
      'money': '💵',
      'account_balance': '🏦',
      'trending_up': '📈',
      'analytics': '📈',

      // Others
      'category': '📁',
      'other': '📦',
      'home': '🏠',
      'pets': '🐾',
      'phone': '📱',
      'briefcase': '💼',
      'push_pin': '📌',
      'pushpin': '📌',
      'pin': '📌',
      'money_bag': '💰',
      'moneybag': '💰',
      'wallet': '👛',
      'bonus': '🎁',
      'investment': '📈',
      'invest': '📈',
      'freelance': '💼',

      // Default
      'default': '📌',
    };

    final normalized = iconCode.trim();
    if (normalized.isEmpty) {
      return iconMap['default']!;
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

    // Preserve custom emoji/icons from backend/category creation.
    if (_looksLikeEmoji(normalized)) {
      return normalized;
    }

    // If unknown string comes from backend (e.g. new enum), render raw
    // instead of forcing push-pin.
    return normalized;
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
  ];

  static List<String> get expenseEmojis => [
    '🍽️',
    '🍔',
    '🍕',
    '☕',
    '🛒',
    '🧾',
    '🏠',
    '🚗',
    '⛽',
    '🎬',
    '✈️',
    '🏨',
    '💊',
    '🏥',
    '📱',
    '👕',
    '🎓',
    '⚡',
    '🔧',
    '🐾',
    '📦',
    '💄',
    '🎂',
    '📚',
  ];

  static List<String> emojisByType(String type) {
    return type.toUpperCase() == 'INCOME' ? incomeEmojis : expenseEmojis;
  }

  static List<String> get allEmojis => [...expenseEmojis, ...incomeEmojis];
}
