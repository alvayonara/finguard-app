import 'package:finguard/features/user/data/model/user_preference.dart';
import 'package:finguard/features/user/data/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:finguard/core/storage/local_storage.dart';
import 'package:finguard/core/app_settings.dart';
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
      final access = await localStorage.getAccessToken();
      final refresh = await localStorage.getRefreshToken();
      final uid = await localStorage.getUserUid();

      if (access == null ||
          access.isEmpty ||
          refresh == null ||
          refresh.isEmpty ||
          uid == null ||
          uid.isEmpty) {
        final fallback = await _resolvePreferences(
          const UserPreference(language: 'en', currency: 'USD'),
        );
        await _applyPreferences(fallback);
        isBootstrapComplete = true;
        _setLoading(false);
        return;
      }

      final remotePref = await userRepository.getPreferences();
      final resolvedPref = await _resolvePreferences(remotePref);
      await _applyPreferences(resolvedPref);
      isBootstrapComplete = true;
    } catch (e) {
      final fallback = await _resolvePreferences(
        const UserPreference(language: 'en', currency: 'USD'),
      );
      await _applyPreferences(fallback);
      isBootstrapComplete = true;
    }
    _setLoading(false);
  }

  Future<void> _applyPreferences(UserPreference pref) async {
    appSettings.setLocale(Locale(pref.language));
    appSettings.setCurrency(pref.currency);

    await localStorage.saveLanguage(pref.language);
    await localStorage.saveCurrency(pref.currency);
  }

  Future<UserPreference> _resolvePreferences(UserPreference base) async {
    final localLanguage = await localStorage.getLanguage();
    final localCurrency = await localStorage.getCurrency();

    return base.copyWith(
      language: (localLanguage != null && localLanguage.isNotEmpty)
          ? localLanguage
          : null,
      currency: (localCurrency != null && localCurrency.isNotEmpty)
          ? localCurrency
          : null,
    );
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> syncPreferences() async {
    try {
      final access = await localStorage.getAccessToken();
      if (access == null || access.isEmpty) return;

      final remotePref = await userRepository.getPreferences();
      await _applyPreferences(remotePref);
    } catch (_) {}
  }

  Future<void> reauthenticate() async {
    await localStorage.clearAuthSession();
  }
}
