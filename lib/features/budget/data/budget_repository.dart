import 'package:finguard_app/core/network/api_client.dart';
import 'package:finguard_app/features/budget/data/model/budget_usage_model.dart';

class BudgetRepository {
  final ApiClient apiClient;
  BudgetRepository(this.apiClient);

  Future<List<BudgetUsageModel>> getBudgets({String? month}) async {
    final response = await apiClient.dio.get(
      '/v1/budgets',
      queryParameters: month != null ? {'month': month} : null,
    );

    final payload = response.data;

    if (payload is List) {
      return payload
          .whereType<Map<String, dynamic>>()
          .map(BudgetUsageModel.fromJson)
          .toList();
    }

    if (payload is Map<String, dynamic>) {
      final list = payload['data'] ?? payload['items'] ?? payload['budgets'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(BudgetUsageModel.fromJson)
            .toList();
      }
    }

    return const [];
  }

  Future<void> createOrUpdateBudget({
    required int categoryId,
    required double monthlyLimit,
  }) async {
    await apiClient.dio.post(
      '/v1/budgets',
      data: {
        'categoryId': categoryId,
        'monthlyLimit': monthlyLimit,
      },
    );
  }

  Future<void> deleteBudget({required int categoryId}) async {
    await apiClient.dio.delete('/v1/budgets/$categoryId');
  }
}
