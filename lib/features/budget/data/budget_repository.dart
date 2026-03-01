import 'package:finguard/core/network/api_client.dart';
import 'package:finguard/features/budget/data/model/budget_usage_page_response.dart';
import 'package:finguard/features/budget/data/model/budget_usage_model.dart';

class BudgetRepository {
  final ApiClient apiClient;
  BudgetRepository({required this.apiClient});

  Future<BudgetUsagePageResponse> getBudgets({
    String? month,
    String? cursorTime,
    int? cursorId,
    int limit = 10,
  }) async {
    final queryParameters = <String, dynamic>{'limit': limit};
    if (month != null) {
      queryParameters['month'] = month;
    }
    if (cursorTime != null) {
      queryParameters['cursorTime'] = cursorTime;
    }
    if (cursorId != null) {
      queryParameters['cursorId'] = cursorId;
    }

    final response = await apiClient.dio.get(
      '/v1/budgets',
      queryParameters: queryParameters,
    );

    final payload = response.data;

    if (payload is List) {
      return BudgetUsagePageResponse(
        items: payload
            .whereType<Map<String, dynamic>>()
            .map(BudgetUsageModel.fromJson)
            .toList(),
      );
    }

    if (payload is Map<String, dynamic>) {
      return BudgetUsagePageResponse.fromJson(payload);
    }

    return BudgetUsagePageResponse(items: const []);
  }

  Future<void> createOrUpdateBudget({
    required int categoryId,
    required double monthlyLimit,
  }) async {
    await apiClient.dio.post(
      '/v1/budgets',
      data: {'categoryId': categoryId, 'monthlyLimit': monthlyLimit},
    );
  }

  Future<void> deleteBudget({required int categoryId}) async {
    await apiClient.dio.delete('/v1/budgets/$categoryId');
  }
}
