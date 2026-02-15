class DashboardResponse {
  final FinancialHealth? financialHealth;
  final MonthSummary? monthSummary;
  final List<RecentTransactionItem> recentTransactions;

  DashboardResponse({
    required this.financialHealth,
    required this.monthSummary,
    required this.recentTransactions,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      financialHealth: json['financialHealth'] != null
          ? FinancialHealth.fromJson(json['financialHealth'])
          : null,
      monthSummary: json['monthSummary'] != null
          ? MonthSummary.fromJson(json['monthSummary'])
          : null,
      recentTransactions: (json['recentTransactions'] as List?)
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
  final String? lastDetectedAt;

  FinancialHealth({
    required this.level,
    required this.score,
    required this.color,
    required this.topInsightKey,
    required this.recommendationKey,
    required this.lastDetectedAt,
  });

  factory FinancialHealth.fromJson(Map<String, dynamic> json) {
    return FinancialHealth(
      level: json['level'] ?? "",
      score: json['score'] ?? 0,
      color: json['color'] ?? "",
      topInsightKey: json['topInsightKey'] ?? "",
      recommendationKey: json['recommendationKey'] ?? "",
      lastDetectedAt: json['lastDetectedAt'],
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
  final int id;
  final String type;
  final double amount;
  final int categoryId;
  final String category;
  final String? categoryIcon;
  final String? categoryColor;
  final String occurredAt;

  RecentTransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.category,
    required this.categoryIcon,
    required this.categoryColor,
    required this.occurredAt,
  });

  factory RecentTransactionItem.fromJson(Map<String, dynamic> json) {
    final categoryRaw = json['category'];
    final categoryObj =
        categoryRaw is Map<String, dynamic> ? categoryRaw : null;

    final categoryName = categoryObj?['name']?.toString() ??
        json['categoryName']?.toString() ??
        (categoryRaw is String ? categoryRaw : '');

    final categoryId = (json['categoryId'] as num?)?.toInt() ??
        (categoryObj?['id'] as num?)?.toInt() ??
        0;

    final categoryIcon = categoryObj?['icon']?.toString() ??
        json['categoryIcon']?.toString() ??
        json['icon']?.toString();

    final categoryColor = categoryObj?['color']?.toString() ??
        json['categoryColor']?.toString() ??
        json['color']?.toString();

    return RecentTransactionItem(
      id: json['id'],
      type: json['type'] ?? "",
      amount: (json['amount'] ?? 0).toDouble(),
      categoryId: categoryId,
      category: categoryName,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
      occurredAt: json['occurredAt'] ?? "",
    );
  }
}
