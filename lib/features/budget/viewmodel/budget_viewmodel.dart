import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/model/budget_usage_model.dart';
import '../data/budget_repository.dart';

class BudgetViewmodel extends ChangeNotifier {
  final BudgetRepository repository;
  BudgetViewmodel({required this.repository});
  static const int _pageLimit = 10;

  List<BudgetUsageModel> budgets = [];
  String? nextCursorTime;
  int? nextCursorId;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isSubmitting = false;
  String? error;
  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  bool get hasMore => nextCursorTime != null && nextCursorId != null;

  Future<void> loadBudgets({bool refresh = false, DateTime? month}) async {
    if (month != null) {
      selectedMonth = DateTime(month.year, month.month);
    }

    if (isLoading) {
      return;
    }
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await repository.getBudgets(
        month: _monthQuery,
        limit: _pageLimit,
      );
      budgets = response.items;
      nextCursorTime = response.nextCursorTime;
      nextCursorId = response.nextCursorId;
    } catch (e) {
      error = e.toString();
      if (refresh) {
        budgets = [];
        nextCursorTime = null;
        nextCursorId = null;
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreBudgets() async {
    if (!hasMore || isLoading || isLoadingMore) {
      return;
    }

    isLoadingMore = true;
    notifyListeners();

    try {
      final response = await repository.getBudgets(
        month: _monthQuery,
        cursorTime: nextCursorTime,
        cursorId: nextCursorId,
        limit: _pageLimit,
      );
      budgets.addAll(response.items);
      nextCursorTime = response.nextCursorTime;
      nextCursorId = response.nextCursorId;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> createOrUpdateBudget({
    required int categoryId,
    required double monthlyLimit,
  }) async {
    try {
      isSubmitting = true;
      notifyListeners();
      await repository.createOrUpdateBudget(
        categoryId: categoryId,
        monthlyLimit: monthlyLimit,
      );
      await loadBudgets(refresh: true);
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteBudget({required int categoryId}) async {
    try {
      isSubmitting = true;
      notifyListeners();
      await repository.deleteBudget(categoryId: categoryId);
      await loadBudgets(refresh: true);
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  String get _monthQuery => DateFormat('yyyy-MM').format(selectedMonth);
}
