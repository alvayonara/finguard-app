import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthViewmodel extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthViewmodel(this.authRepository);

  bool isLoading = false;
  UserModel? user;

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    user = await authRepository.createAnonymousUser();

    isLoading = false;
    notifyListeners();
  }
}
