import 'package:finguard/core/app_settings.dart';
import 'package:finguard/core/utils/currency_formatter.dart';
import 'package:finguard/features/budget/data/model/budget_usage_model.dart';
import 'package:finguard/core/ui/app_colors.dart';
import 'package:flutter/material.dart';

class BudgetCard extends StatelessWidget {
  final BudgetUsageModel budget;
  final AppSettings settings;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.settings,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formattedLimit = CurrencyFormatter.format(
      amount: budget.monthlyLimit,
      currencyCode: settings.currency,
      locale: settings.locale.languageCode,
    );

    final formattedSpent = CurrencyFormatter.format(
      amount: budget.spent,
      currencyCode: settings.currency,
      locale: settings.locale.languageCode,
    );

    final percent = (budget.percentageUsed / 100).clamp(0.0, 1.0);

    final isOver = budget.percentageUsed >= 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Category
          Text(
            budget.category,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onEdit != null)
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text("Edit"),
                ),
              if (onDelete != null)
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: Colors.red,
                  ),
                  label: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            "$formattedSpent / $formattedLimit",
            style: TextStyle(
              fontSize: 13,
              color: isOver ? Colors.red : Colors.grey,
            ),
          ),

          const SizedBox(height: 14),

          /// Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOver ? Colors.red : AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${budget.percentageUsed.toStringAsFixed(0)}%",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isOver ? Colors.red : Colors.black,
                ),
              ),
              Text(
                isOver
                    ? "Over budget"
                    : "Remaining: ${CurrencyFormatter.format(amount: budget.remaining, currencyCode: settings.currency, locale: settings.locale.languageCode)}",
                style: TextStyle(
                  fontSize: 12,
                  color: isOver ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
