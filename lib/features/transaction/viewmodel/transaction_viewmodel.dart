import 'package:finguard/features/transaction/data/model/create_transaction_request.dart';
import 'package:finguard/features/transaction/data/model/update_transaction_request.dart';
import 'package:finguard/features/transaction/data/transaction_repository.dart';
import 'package:flutter/material.dart';
import 'package:finguard/features/auth/data/auth_repository.dart';
import 'package:finguard/core/storage/local_storage.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository repository;
  final AuthRepository authRepository;
  final LocalStorage localStorage;

  bool isLoading = false;

  TransactionViewModel(this.repository, this.authRepository, this.localStorage);

  Future<void> createTransaction({
    required CreateTransactionRequest request,
  }) async {
    try {
      isLoading = true;
      notifyListeners();
      final existingId = await localStorage.getUserUid();
      final existingRefreshToken = await localStorage.getRefreshToken();
      if (existingId == null ||
          existingRefreshToken == null ||
          existingRefreshToken.isEmpty) {
        throw StateError('Authentication required');
      }

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
