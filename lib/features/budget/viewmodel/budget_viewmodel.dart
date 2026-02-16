import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/model/budget_usage_model.dart';
import '../data/budget_repository.dart';

class BudgetViewmodel extends ChangeNotifier {
  final BudgetRepository repository;
  BudgetViewmodel({required this.repository});

  List<BudgetUsageModel> budgets = [];
  bool isLoading = false;
  bool isSubmitting = false;
  String? error;
  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

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
      budgets = await repository.getBudgets(month: _monthQuery);
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
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
