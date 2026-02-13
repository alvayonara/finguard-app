import 'package:finguard_app/features/transaction/data/enum/transaction_type_enum.dart';

class CreateTransactionRequest {
  final String type;
  final double amount;
  final int categoryId;
  final String occurredAt;

  CreateTransactionRequest({
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
