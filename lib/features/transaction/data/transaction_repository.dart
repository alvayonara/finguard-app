import 'package:finguard/core/network/api_client.dart';
import 'package:finguard/features/transaction/data/model/create_transaction_request.dart';
import 'package:finguard/features/transaction/data/model/update_transaction_request.dart';

class TransactionRepository {
  final ApiClient apiClient;

  TransactionRepository({required this.apiClient});

  Future<void> createTransaction(CreateTransactionRequest request) async {
    await apiClient.dio.post("/v1/transactions", data: request.toJson());
  }

  Future<void> updateTransaction(
    int id,
    UpdateTransactionRequest request,
  ) async {
    await apiClient.dio.put("/v1/transactions/$id", data: request.toJson());
  }

  Future<void> deleteTransaction(int id) async {
    await apiClient.dio.delete("/v1/transactions/$id");
  }
}
