import 'package:finguard_app/core/app_settings.dart';
import 'package:finguard_app/core/utils/currency_formatter.dart';
import 'package:finguard_app/core/utils/insight_resolver.dart';
import 'package:finguard_app/features/dashboard/data/model/dashboard_response.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActiveDashboard extends StatelessWidget {
  final DashboardResponse data;

  const ActiveDashboard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final financialHealth = data.financialHealth;
    final monthSummary = data.monthSummary;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (financialHealth != null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: _gradient(financialHealth.level),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Financial Health",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  financialHealth.level,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  InsightResolver.resolveInsight(
                    context,
                    financialHealth.topInsightKey,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          InsightResolver.resolveRecommendation(
                            context,
                            financialHealth.recommendationKey,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _row(
                "Income",
                monthSummary?.totalIncome ?? 0,
                Colors.green,
                settings,
              ),
              const SizedBox(height: 12),
              _row(
                "Expense",
                monthSummary?.totalExpense ?? 0,
                Colors.red,
                settings,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          "Recent Transactions",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        if (data.recentTransactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: const Text(
              "No transactions yet",
              style: TextStyle(color: Colors.grey),
            ),
          ),

        ...data.recentTransactions.map((tx) {
          final formattedAmount = CurrencyFormatter.format(
            amount: tx.amount,
            currencyCode: settings.currency,
            locale: settings.locale.languageCode,
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tx.occurredAt,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  formattedAmount,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  LinearGradient _gradient(String level) {
    switch (level) {
      case "HIGH":
        return const LinearGradient(
          colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
        );
      case "MEDIUM":
        return const LinearGradient(
          colors: [Color(0xFFFFB347), Color(0xFFFFCC33)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
        );
    }
  }

  Widget _row(
      String label,
      double value,
      Color color,
      AppSettings settings,
      ) {
    final formatted = CurrencyFormatter.format(
      amount: value,
      currencyCode: settings.currency,
      locale: settings.locale.languageCode,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          formatted,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}