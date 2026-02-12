class DashboardResponse {
  final String state;
  final FinancialHealth? financialHealth;
  final MonthSummary? monthSummary;
  final List<RecentTransactionItem> recentTransactions;

  DashboardResponse({
    required this.state,
    required this.financialHealth,
    required this.monthSummary,
    required this.recentTransactions,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      state: json['state'] ?? "ONBOARDING",
      financialHealth: json['financialHealth'] != null
          ? FinancialHealth.fromJson(json['financialHealth'])
          : null,
      monthSummary: json['monthSummary'] != null
          ? MonthSummary.fromJson(json['monthSummary'])
          : null,
      recentTransactions:
          (json['recentTransactions'] as List?)
              ?.map((e) => RecentTransactionItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class FinancialHealth {
  final String level;
  final int score;
  final String color;
  final String topInsightKey;
  final String recommendationKey;

  FinancialHealth({
    required this.level,
    required this.score,
    required this.color,
    required this.topInsightKey,
    required this.recommendationKey,
  });

  factory FinancialHealth.fromJson(Map<String, dynamic> json) {
    return FinancialHealth(
      level: json['level'] ?? "",
      score: json['score'] ?? 0,
      color: json['color'] ?? "",
      topInsightKey: json['topInsightKey'] ?? "",
      recommendationKey: json['recommendationKey'] ?? "",
    );
  }
}

class MonthSummary {
  final String? monthKey;
  final double totalIncome;
  final double totalExpense;

  MonthSummary({
    required this.monthKey,
    required this.totalIncome,
    required this.totalExpense,
  });

  factory MonthSummary.fromJson(Map<String, dynamic> json) {
    return MonthSummary(
      monthKey: json['monthKey'],
      totalIncome: (json['totalIncome'] ?? 0).toDouble(),
      totalExpense: (json['totalExpense'] ?? 0).toDouble(),
    );
  }
}

class RecentTransactionItem {
  final String type;
  final double amount;
  final String category;
  final String occurredAt;

  RecentTransactionItem({
    required this.type,
    required this.amount,
    required this.category,
    required this.occurredAt,
  });

  factory RecentTransactionItem.fromJson(Map<String, dynamic> json) {
    return RecentTransactionItem(
      type: json['type'] ?? "",
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? "",
      occurredAt: json['occurredAt'] ?? "",
    );
  }
}
