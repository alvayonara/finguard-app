import 'package:flutter/material.dart';
import '../data/model/profile_model.dart';

class ProfileViewmodel extends ChangeNotifier {
  ProfileModel? profile;
  bool isLoading = false;
  String? error;

  Future<void> loadProfile() async {
    try {
      isLoading = true;
      notifyListeners();

      // TODO: replace with real API call
      await Future.delayed(const Duration(milliseconds: 500));

      profile = ProfileModel(
        userUid: "USR_123",
        name: "Alva Yonara",
        email: "alva@email.com",
        role: "USER",
        plan: "FREE",
        preferredCurrency: "USD",
        preferredLanguage: "en",
        createdAt: "2026-01-01",
      );

      error = null;
    } catch (e) {
      error = "Failed to load profile";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void signOut() {
    // TODO clear token & reload app state
  }
}
