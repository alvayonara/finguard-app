import 'package:finguard/features/transaction/data/model/create_transaction_request.dart';
import 'package:finguard/features/transaction/data/model/update_transaction_request.dart';
import 'package:finguard/features/transaction/data/transaction_repository.dart';
import 'package:flutter/material.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository repository;

  bool isLoading = false;

  TransactionViewModel({required this.repository});

  Future<void> createTransaction({
    required CreateTransactionRequest request,
  }) async {
    try {
      isLoading = true;
      notifyListeners();
      await repository.createTransaction(request);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTransaction({
    required int id,
    required UpdateTransactionRequest request,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await repository.updateTransaction(id, request);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      isLoading = true;
      notifyListeners();

      await repository.deleteTransaction(id);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
