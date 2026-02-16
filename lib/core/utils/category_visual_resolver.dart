import 'package:finguard_app/core/utils/category_icon_mapper.dart';
import 'package:flutter/material.dart';

class CategoryVisual {
  final String emoji;
  final Color color;

  const CategoryVisual({required this.emoji, required this.color});
}

class CategoryVisualResolver {
  static CategoryVisual resolve({
    required String categoryName,
    String? iconCode,
    String? colorCode,
  }) {
    final iconToMap = iconCode?.isNotEmpty == true
        ? iconCode!
        : categoryName.toLowerCase();

    final emoji = CategoryIconMapper.getIcon(iconToMap);
    final color = _parseColorCode(colorCode) ?? _fallbackColor(categoryName);
    return CategoryVisual(emoji: emoji, color: color);
  }

  static Color? _parseColorCode(String? colorCode) {
    if (colorCode == null || colorCode.isEmpty) return null;
    final normalized =
        colorCode.startsWith('#') ? colorCode.substring(1) : colorCode;
    if (normalized.length != 6) return null;

    final hex = int.tryParse(normalized, radix: 16);
    if (hex == null) return null;
    return Color(0xFF000000 | hex);
  }

  static Color _fallbackColor(String categoryName) {
    switch (categoryName.toUpperCase()) {
      case "FOOD":
        return Colors.orange;
      case "SHOPPING":
        return Colors.redAccent;
      case "TRANSPORT":
        return Colors.blueAccent;
      case "SALARY":
      case "INCOME":
        return Colors.green;
      case "ENTERTAINMENT":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
