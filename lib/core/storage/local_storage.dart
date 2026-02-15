import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _anonKey = "anonymous_id";
  static const _userUidKey = "user_uid";
  static const _accessTokenKey = "access_token";
  static const _refreshTokenKey = "refresh_token";
  static const _languageKey = "language";
  static const _currencyKey = "currency";
  static const _onboardingCompletedKey = "onboarding_completed";
  static const _firstLoginCoachmarkPendingKey = "first_login_coachmark_pending";

  Future<void> saveAnonymous(String anonId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_anonKey, anonId);
    await prefs.reload();
  }

  Future<void> saveUserUid(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userUidKey, uid);
  }

  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  Future<void> saveAuthSession({
    required String userUid,
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_userUidKey, userUid),
      prefs.setString(_accessTokenKey, accessToken),
      prefs.setString(_refreshTokenKey, refreshToken),
    ]);
    await prefs.reload();
  }

  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  Future<void> saveCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
  }

  // getter
  Future<String?> getUserUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userUidKey);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<String?> getAnonymousId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_anonKey);
  }

  Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  Future<String?> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  Future<void> markFirstLoginCoachmarkPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLoginCoachmarkPendingKey, true);
  }

  Future<bool> consumeFirstLoginCoachmarkPending() async {
    final prefs = await SharedPreferences.getInstance();
    final isPending = prefs.getBool(_firstLoginCoachmarkPendingKey) ?? false;
    if (isPending) {
      await prefs.setBool(_firstLoginCoachmarkPendingKey, false);
    }
    return isPending;
  }

  /// Clears authentication session (tokens and userUid)
  /// IMPORTANT: Does NOT clear anonymousId - this preserves user data
  Future<void> clearAuthSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userUidKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    // NOTE: anonymousId is intentionally NOT removed to preserve user data
  }
}
