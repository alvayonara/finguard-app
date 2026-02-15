import 'package:finguard_app/core/app_settings.dart';
import 'package:finguard_app/core/ui/bounce_wrapper.dart';
import 'package:finguard_app/core/utils/currency_formatter.dart';
import 'package:finguard_app/features/activity/data/model/activity_item.dart';
import 'package:finguard_app/features/activity/viewmodel/activity_viewmodel.dart';
import 'package:finguard_app/features/transaction/data/model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActivityGroupCard extends StatelessWidget {
  final List<ActivityItem> items;
  final bool showConnector;
  final AppSettings settings;

  const ActivityGroupCard({
    super.key,
    required this.items,
    this.showConnector = false,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFF5E5CE6),
                    shape: BoxShape.circle,
                  ),
                ),
                if (showConnector)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: showConnector ? 0 : 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.12)),
              ),
              child: Column(
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Column(
                    children: [
                      _buildItem(item),
                      if (index != items.length - 1)
                        Divider(
                          height: 1,
                          thickness: 0.6,
                          color: Colors.grey.withOpacity(0.12),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(ActivityItem item) {
    return switch (item) {
      ActivityTransaction tx => _buildTransaction(tx),
      ActivityRiskChange risk => _buildRiskChange(risk),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildTransaction(ActivityTransaction tx) {
    final isIncome = tx.type == 'INCOME';
    final iconColor = _getCategoryColor(tx.category.color);

    return Builder(
      builder: (context) => BounceWrapper(
        onTap: () async {
          final transactionModel = TransactionModel(
            id: tx.id,
            type: tx.type,
            amount: tx.amount,
            categoryId: tx.category.id,
            categoryName: tx.category.name,
            occurredAt: DateFormat('yyyy-MM-dd').format(tx.occurredAt),
          );

          final result = await Navigator.pushNamed(
            context,
            '/transaction-detail',
            arguments: transactionModel,
          );

          if (result == true && context.mounted) {
            // Refresh activity list when transaction is deleted/updated
            context.read<ActivityViewmodel>().loadActivities(refresh: true);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    _getIconData(tx.category.icon),
                    size: 18,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.category.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(tx.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}${CurrencyFormatter.format(amount: tx.amount, currencyCode: settings.currency, locale: settings.locale.languageCode)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskChange(ActivityRiskChange risk) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB347).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFFB347),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Risk Level Changed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildRiskBadge(risk.previousLevel),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: Colors.grey,
                      ),
                    ),
                    _buildRiskBadge(risk.currentLevel),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskBadge(String level) {
    final color = _getRiskColor(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        level,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getCategoryColor(String colorStr) {
    try {
      if (colorStr.startsWith('#')) {
        return Color(int.parse(colorStr.substring(1), radix: 16) + 0xFF000000);
      }
      return const Color(0xFF9E9E9E);
    } catch (_) {
      return const Color(0xFF9E9E9E);
    }
  }

  IconData _getIconData(String icon) {
    final iconMap = {
      'restaurant': Icons.restaurant,
      'shopping_bag': Icons.shopping_bag,
      'attach_money': Icons.attach_money,
      'directions_car': Icons.directions_car,
      'movie': Icons.movie,
      'home': Icons.home,
      'flight': Icons.flight,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'fitness_center': Icons.fitness_center,
    };

    return iconMap[icon] ?? Icons.category;
  }

  Color _getRiskColor(String level) {
    return switch (level) {
      'HIGH' => const Color(0xFFFF5F6D),
      'MEDIUM' => const Color(0xFFFFB347),
      'LOW' => const Color(0xFF56AB2F),
      _ => Colors.grey,
    };
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }
}
