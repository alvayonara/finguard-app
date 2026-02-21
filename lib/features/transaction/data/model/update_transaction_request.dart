class UpdateTransactionRequest {
  final String type;
  final double amount;
  final int categoryId;
  final String occurredAt;

  UpdateTransactionRequest({
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.occurredAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "amount": amount,
      "categoryId": categoryId,
      "occurredAt": occurredAt,
    };
  }
}
