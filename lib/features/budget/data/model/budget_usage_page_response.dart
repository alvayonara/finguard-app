import 'package:finguard/features/budget/data/model/budget_usage_model.dart';

class BudgetUsagePageResponse {
  final List<BudgetUsageModel> items;
  final String? nextCursorTime;
  final int? nextCursorId;

  BudgetUsagePageResponse({
    required this.items,
    this.nextCursorTime,
    this.nextCursorId,
  });

  factory BudgetUsagePageResponse.fromJson(Map<String, dynamic> json) {
    final rawItems =
        (json['items'] ??
                json['data'] ??
                json['budgets'] ??
                json['content'] ??
                const [])
            as List;

    return BudgetUsagePageResponse(
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(BudgetUsageModel.fromJson)
          .toList(),
      nextCursorTime:
          json['nextCursorTime']?.toString() ?? json['cursorTime']?.toString(),
      nextCursorId: ((json['nextCursorId'] ?? json['cursorId']) as num?)
          ?.toInt(),
    );
  }

  bool get hasMore => nextCursorTime != null && nextCursorId != null;
}
