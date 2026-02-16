class BudgetUsageModel {
  final int? categoryId;
  final String category;
  final double monthlyLimit;
  final double spent;
  final double remaining;
  final double percentageUsed;

  BudgetUsageModel({
    required this.categoryId,
    required this.category,
    required this.monthlyLimit,
    required this.spent,
    required this.remaining,
    required this.percentageUsed,
  });

  factory BudgetUsageModel.fromJson(Map<String, dynamic> json) {
    return BudgetUsageModel(
      categoryId: (json['categoryId'] as num?)?.toInt(),
      category: json['category'],
      monthlyLimit: (json['monthlyLimit'] ?? 0).toDouble(),
      spent: (json['spent'] ?? 0).toDouble(),
      remaining: (json['remaining'] ?? 0).toDouble(),
      percentageUsed: (json['percentageUsed'] ?? 0).toDouble(),
    );
  }
}
