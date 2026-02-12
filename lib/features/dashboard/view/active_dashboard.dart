import 'package:finguard_app/core/app_settings.dart';
import 'package:finguard_app/core/utils/currency_formatter.dart';
import 'package:finguard_app/core/utils/insight_resolver.dart';
import 'package:finguard_app/features/dashboard/data/model/dashboard_response.dart';
import 'package:finguard_app/features/risk/view/widget/risk_trend_card.dart';
import 'package:finguard_app/features/risk/viewmodel/risk_trend_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActiveDashboard extends StatelessWidget {
  final DashboardResponse data;

  const ActiveDashboard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final riskTrendVM = context.watch<RiskTrendViewmodel>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        if (data.financialHealth != null)
          _buildFinancialHero(context, data.financialHealth!),

        const SizedBox(height: 32),

        RiskTrendCard(
          data: riskTrendVM.data,
          isLoading: riskTrendVM.isLoading,
          selectedDays: riskTrendVM.selectedDays,
          trendDirection: riskTrendVM.trendDirection,
          onRangeChanged: (days) => riskTrendVM.load(days: days),
        ),

        const SizedBox(height: 32),

        _buildMonthSummary(data.monthSummary, settings),

        const SizedBox(height: 32),

        _buildRecentTransactions(data, settings),
      ],
    );
  }

  // ===================================================
  // HERO
  // ===================================================
  Widget _buildFinancialHero(BuildContext context, FinancialHealth health) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/risk-detail');
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: health.score.toDouble()),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, animatedScore, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: _gradient(health.level),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header + Arrow indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Financial Health",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      health.level,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${animatedScore.toInt()}/100",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  InsightResolver.resolveInsight(context, health.topInsightKey),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),

                const SizedBox(height: 6),

                if (health.lastDetectedAt != null &&
                    health.lastDetectedAt!.isNotEmpty)
                  Text(
                    "Updated ${health.lastDetectedAt}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),

                const SizedBox(height: 16),

                if (health.recommendationKey.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            InsightResolver.resolveRecommendation(
                              context,
                              health.recommendationKey,
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
          );
        },
      ),
    );
  }

  Widget _miniTrendIcon(FinancialHealth health) {
    if (health.score >= 70) {
      return const Icon(Icons.trending_up, color: Colors.white, size: 20);
    } else if (health.score <= 30) {
      return const Icon(Icons.trending_down, color: Colors.white, size: 20);
    } else {
      return const Icon(Icons.trending_flat, color: Colors.white, size: 20);
    }
  }

  // ===================================================
  // MONTH SUMMARY
  // ===================================================

  Widget _buildMonthSummary(MonthSummary? summary, AppSettings settings) {
    final income = summary?.totalIncome ?? 0;
    final expense = summary?.totalExpense ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _moneyRow("Income", income, true, settings),
          const SizedBox(height: 14),
          _moneyRow("Expense", expense, false, settings),
        ],
      ),
    );
  }

  Widget _moneyRow(
    String label,
    double value,
    bool isIncome,
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
          "${isIncome ? '+' : '-'} $formatted",
          style: TextStyle(
            color: isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ===================================================
  // RECENT TRANSACTIONS
  // ===================================================

  Widget _buildRecentTransactions(
    DashboardResponse data,
    AppSettings settings,
  ) {
    if (data.recentTransactions.isEmpty) {
      return const Center(
        child: Text(
          "No transactions yet",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Transactions",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...data.recentTransactions.map((tx) {
          final formatted = CurrencyFormatter.format(
            amount: tx.amount,
            currencyCode: settings.currency,
            locale: settings.locale.languageCode,
          );

          final isExpense = tx.type == "EXPENSE";

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
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
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tx.occurredAt,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Text(
                  "${isExpense ? '-' : '+'} $formatted",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isExpense ? Colors.red : Colors.green,
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
}
