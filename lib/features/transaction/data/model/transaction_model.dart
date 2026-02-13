class TransactionModel {
  final int id;
  final String type;
  final double amount;
  final int categoryId;
  final String categoryName;
  final String occurredAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.occurredAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'],
      categoryName: json['category'],
      occurredAt: json['occurredAt'],
    );
  }
}
