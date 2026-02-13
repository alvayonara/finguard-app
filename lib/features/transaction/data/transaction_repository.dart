import 'package:finguard_app/core/network/api_client.dart';
import 'package:finguard_app/features/transaction/data/model/update_transaction_request.dart';

class TransactionRepository {
  final ApiClient apiClient;

  TransactionRepository(this.apiClient);

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
