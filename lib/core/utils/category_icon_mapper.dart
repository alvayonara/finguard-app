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
      'shopping': '🛒',
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
      'salary': '💰',
      'gift': '🎁',
      'account_balance': '🏦',

      // Others
      'category': '📁',
      'other': '📦',
      'home': '🏠',
      'pets': '🐾',
      'phone': '📱',

      // Default
      'default': '📌',
    };

    final normalized = iconCode.trim();
    if (normalized.isEmpty) {
      return iconMap['default']!;
    }

    final mapped = iconMap[normalized.toLowerCase()];
    if (mapped != null) {
      return mapped;
    }

    // Preserve custom emoji/icons from backend/category creation.
    if (_looksLikeEmoji(normalized)) {
      return normalized;
    }

    return iconMap['default']!;
  }

  static bool _looksLikeEmoji(String value) {
    final hasAsciiWordChar = RegExp(r'[A-Za-z0-9_]').hasMatch(value);
    final hasNonAscii = value.runes.any((rune) => rune > 0x7F);
    return hasNonAscii && !hasAsciiWordChar;
  }

  static List<String> get allEmojis => [
        '🧾',
        '📄',
        '🎓',
        '📚',
        '🎬',
        '🎮',
        '⚽',
        '🍽️',
        '🍔',
        '🍕',
        '☕',
        '🏥',
        '💊',
        '💪',
        '🛍️',
        '🛒',
        '🏪',
        '🚗',
        '🚌',
        '🚙',
        '🚇',
        '🚆',
        '✈️',
        '🧳',
        '🏨',
        '💼',
        '💰',
        '🎁',
        '🏦',
        '📁',
        '📦',
        '🏠',
        '🐾',
        '📱',
        '⚡',
        '💳',
        '🎯',
        '🎨',
        '🎵',
        '📷',
        '💡',
        '🔧',
        '⛽',
        '🌳',
        '👕',
        '👟',
        '💄',
        '🎂',
        '🌟',
        '💎',
      ];
}
