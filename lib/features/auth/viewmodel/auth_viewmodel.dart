import 'package:finguard_app/features/user/data/model/user_preference.dart';
import 'package:finguard_app/features/user/data/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:finguard_app/core/storage/local_storage.dart';
import 'package:finguard_app/core/app_settings.dart';
import '../data/auth_repository.dart';

class AuthViewmodel extends ChangeNotifier {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final LocalStorage localStorage;
  final AppSettings appSettings;

  AuthViewmodel(
    this.authRepository,
    this.userRepository,
    this.localStorage,
    this.appSettings,
  );

  bool isLoading = false;
  bool isBootstrapComplete = false;

  Future<void> bootstrap() async {
    _setLoading(true);
    try {
      await _initUser();
      final pref = await userRepository.getPreferences();
      await _applyPreferences(pref);
      isBootstrapComplete = true;
    } catch (e) {
      debugPrint("Bootstrap error: $e");
      await _applyPreferences(
        const UserPreference(language: 'en', currency: 'USD'),
      );
      isBootstrapComplete = true;
    }
    _setLoading(false);
  }

  Future<void> _initUser() async {
    final existingId = await localStorage.getUserUid();
    final existingRefreshToken = await localStorage.getRefreshToken();
    if (existingId != null &&
        existingRefreshToken != null &&
        existingRefreshToken.isNotEmpty) {
      return;
    }

    final currentAnonymousId = await localStorage.getAnonymousId();
    final res = await authRepository.createAnonymous(
      anonymousId: currentAnonymousId,
    );

    final resolvedAnonymousId = res.anonymousId;
    if (resolvedAnonymousId != null && resolvedAnonymousId.isNotEmpty) {
      await localStorage.saveAnonymous(resolvedAnonymousId);
    }
    await localStorage.saveAuthSession(
      userUid: res.userUid,
      accessToken: res.accessToken,
      refreshToken: res.refreshToken,
    );
  }

  Future<void> _applyPreferences(UserPreference pref) async {
    appSettings.setLocale(Locale(pref.language));
    appSettings.setCurrency(pref.currency);

    await localStorage.saveLanguage(pref.language);
    await localStorage.saveCurrency(pref.currency);
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> reauthenticate() async {
    try {
      await localStorage.clearAuthSession();
      await _initUser();
    } catch (e) {
      rethrow;
    }
  }
}
