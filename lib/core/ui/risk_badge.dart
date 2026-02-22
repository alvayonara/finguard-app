import 'package:finguard/core/ui/app_colors.dart';
import 'package:flutter/material.dart';

class RiskBadge extends StatelessWidget {
  final String level;

  const RiskBadge({super.key, required this.level});

  Color _color() {
    switch (level) {
      case "HIGH":
        return AppColors.danger;
      case "MEDIUM":
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color().withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        level,
        style: TextStyle(color: _color(), fontWeight: FontWeight.bold),
      ),
    );
  }
}
