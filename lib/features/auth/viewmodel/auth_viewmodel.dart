import 'package:finguard_app/core/storage/local_storage.dart';
import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

class AuthViewmodel extends ChangeNotifier {
  final AuthRepository authRepository;
  final LocalStorage localStorage;

  AuthViewmodel(this.authRepository, this.localStorage);

  bool isLoading = false;

  Future<String> initUser() async {
    isLoading = true;
    notifyListeners();

    final existingId = await localStorage.getUserUid();
    if (existingId != null) {
      isLoading = false;
      return existingId;
    }

    final res = await authRepository.createAnonymous();
    await localStorage.saveAnonymous(res.anonymousId);
    await localStorage.saveUserUid(res.userUid);

    isLoading = false;
    notifyListeners();

    return res.userUid;
  }
}
