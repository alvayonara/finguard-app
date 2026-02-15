import 'package:finguard_app/core/app_settings.dart';
import 'package:finguard_app/core/ui/bounce_wrapper.dart';
import 'package:finguard_app/core/utils/category_icon_mapper.dart';
import 'package:finguard_app/core/utils/currency_formatter.dart';
import 'package:finguard_app/core/utils/insight_resolver.dart';
import 'package:finguard_app/features/dashboard/data/model/dashboard_response.dart';
import 'package:finguard_app/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:finguard_app/features/risk/view/widget/risk_trend_card.dart';
import 'package:finguard_app/features/risk/viewmodel/risk_trend_viewmodel.dart';
import 'package:finguard_app/features/transaction/data/model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActiveDashboard extends StatefulWidget {
  final DashboardResponse data;

  const ActiveDashboard({super.key, required this.data});

  @override
  State<ActiveDashboard> createState() => _ActiveDashboardState();
}

class _ActiveDashboardState extends State<ActiveDashboard> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final riskTrendVM = context.watch<RiskTrendViewmodel>();
    final dashboardVM = context.watch<DashboardViewmodel>();
    final summary = widget.data.monthSummary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        if (widget.data.financialHealth != null)
          _buildFinancialHero(
            context,
            widget.data.financialHealth!,
            dashboardVM.isFinancialHealthUpdating,
          ),
        const SizedBox(height: 20),
        _buildNetBalance(summary, settings),
        const SizedBox(height: 20),
        if (summary != null) _buildIncomeExpense(summary, settings),
        const SizedBox(height: 28),
        _buildTabChips(),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: selectedTab == 0
              ? _buildRecentTransactions(widget.data, settings)
              : RiskTrendCard(
                  key: const ValueKey("risk_tab"),
                  data: riskTrendVM.data,
                  isLoading: riskTrendVM.isLoading,
                  selectedDays: riskTrendVM.selectedDays,
                  trendDirection: riskTrendVM.trendDirection,
                  onRangeChanged: (days) => riskTrendVM.load(days: days),
                ),
        ),
      ],
    );
  }

  Widget _buildTabChips() {
    return Row(
      children: [
        _chip("Transactions", 0),
        const SizedBox(width: 10),
        _chip("Risk Trend", 1),
      ],
    );
  }

  Widget _chip(String label, int index) {
    final isSelected = selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5E5CE6) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialHero(
    BuildContext context,
    FinancialHealth health,
    bool isUpdating,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/risk-detail'),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: health.score.toDouble()),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, animatedScore, child) {
          return Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: _gradient(health.level),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Financial Health",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isUpdating) ...[
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Updating...",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      health.level,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${animatedScore.toInt()}/100",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Last detected: ${_formatLastDetectedAt(health.lastDetectedAt)}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.82),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (health.recommendationKey.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.white,
                          size: 18,
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
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatLastDetectedAt(String? raw) {
    if (raw == null || raw.isEmpty) return "-";
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd MMM yyyy, HH:mm').format(parsed.toLocal());
  }

  Widget _buildNetBalance(MonthSummary? summary, AppSettings settings) {
    final income = summary?.totalIncome ?? 0;
    final expense = summary?.totalExpense ?? 0;
    final balance = income - expense;

    final formatted = CurrencyFormatter.format(
      amount: balance.abs(),
      currencyCode: settings.currency,
      locale: settings.locale.languageCode,
    );

    final isNegative = balance < 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Net Balance",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Text(
            "${isNegative ? '-' : '+'} $formatted",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isNegative ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpense(MonthSummary summary, AppSettings settings) {
    return Row(
      children: [
        Expanded(
          child: _miniMoneyCard("Income", summary.totalIncome, true, settings),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _miniMoneyCard(
            "Expense",
            summary.totalExpense,
            false,
            settings,
          ),
        ),
      ],
    );
  }

  Widget _miniMoneyCard(
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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            formatted,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

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

    /// Group by date
    final Map<DateTime, List<dynamic>> grouped = {};

    for (var tx in data.recentTransactions) {
      final parsed = DateTime.parse(tx.occurredAt);
      final dateOnly = DateTime(parsed.year, parsed.month, parsed.day);

      grouped.putIfAbsent(dateOnly, () => []);
      grouped[dateOnly]!.add(tx);
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Transactions",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...sortedDates.map((date) {
          final txList = grouped[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _prettyDate(date),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.12)),
                ),
                child: Column(
                  children: txList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tx = entry.value;

                    final formatted = CurrencyFormatter.format(
                      amount: tx.amount,
                      currencyCode: settings.currency,
                      locale: settings.locale.languageCode,
                    );

                    final isExpense = tx.type == "EXPENSE";

                    final iconEmoji = CategoryIconMapper.getIcon(
                      tx.categoryIcon ?? tx.category,
                    );
                    final iconColor = _parseCategoryColor(tx.categoryColor) ??
                        _categoryColor(tx.category);

                    return Column(
                      children: [
                        BounceWrapper(
                          onTap: () async {
                            final model = TransactionModel(
                              id: tx.id,
                              type: tx.type,
                              amount: tx.amount,
                              categoryId: tx.categoryId,
                              categoryName: tx.category,
                              occurredAt: tx.occurredAt,
                            );

                            final result = await Navigator.pushNamed(
                              context,
                              '/transaction-detail',
                              arguments: model,
                            );

                            if (result == true && context.mounted) {
                              context
                                  .read<DashboardViewmodel>()
                                  .loadDashboard();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                /// ICON
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: iconColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      iconEmoji,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                /// CATEGORY
                                Expanded(
                                  child: Text(
                                    tx.category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),

                                /// AMOUNT
                                Text(
                                  "${isExpense ? '-' : '+'} $formatted",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color:
                                        isExpense ? Colors.red : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (index != txList.length - 1)
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
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ],
    );
  }

  LinearGradient _gradient(String level) {
    switch (level) {
      case "HIGH":
        return const LinearGradient(
          colors: [Color(0xFFFF5F6D), Color(0xFFFF9966)],
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

String _prettyDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  if (date == today) return "Today";
  if (date == yesterday) return "Yesterday";

  return "${_monthName(date.month)} ${date.day}, ${date.year}";
}

String _monthName(int month) {
  const months = [
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  return months[month];
}

Color _categoryColor(String category) {
  switch (category.toUpperCase()) {
    case "FOOD":
      return Colors.orange;
    case "SHOPPING":
      return Colors.redAccent;
    case "TRANSPORT":
      return Colors.blueAccent;
    case "SALARY":
      return Colors.green;
    case "ENTERTAINMENT":
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

Color? _parseCategoryColor(String? colorCode) {
  if (colorCode == null || colorCode.isEmpty) return null;
  final normalized =
      colorCode.startsWith('#') ? colorCode.substring(1) : colorCode;
  if (normalized.length != 6) return null;

  final hex = int.tryParse(normalized, radix: 16);
  if (hex == null) return null;
  return Color(0xFF000000 | hex);
}
