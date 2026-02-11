import 'package:flutter/material.dart';
import '../data/model/dashboard_response.dart';

class ActiveDashboard extends StatelessWidget {
  final DashboardResponse data;

  const ActiveDashboard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final health = data.financialHealth;
    final summary = data.monthSummary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("FinGuard")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (health != null) ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        "Financial Health",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        health.level,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(health.topInsight),
                      const SizedBox(height: 16),
                      Text(
                        "Score: ${health.score}",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (summary != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "This Month",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Income:"),
                          Text("\$${summary.totalIncome.toStringAsFixed(2)}"),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Expenses:"),
                          Text("\$${summary.totalExpense.toStringAsFixed(2)}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (data.recentTransactions.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recent Transactions",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...data.recentTransactions.map((tx) => ListTile(
                            title: Text(tx.category),
                            subtitle: Text(tx.type),
                            trailing: Text(
                              "\$${tx.amount.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: tx.type == "INCOME"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
