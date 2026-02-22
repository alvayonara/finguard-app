import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _userUidKey = "user_uid";
  static const _accessTokenKey = "access_token";
  static const _refreshTokenKey = "refresh_token";
  static const _languageKey = "language";
  static const _currencyKey = "currency";
  static const _onboardingCompletedKey = "onboarding_completed";
  static const _firstLoginCoachmarkPendingKey = "first_login_coachmark_pending";
  static const _pendingOnboardingStepKey = "pending_onboarding_step";
  static const _loggedOutKey = "logged_out";
  static const _skippedUpdateVersionKey = "skipped_update_version";
  static const _skippedUpdateUntilEpochMsKey = "skipped_update_until_epoch_ms";

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
    await prefs.reload();
  }

  Future<void> markFirstLoginCoachmarkPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLoginCoachmarkPendingKey, true);
  }

  Future<void> setPendingOnboardingStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pendingOnboardingStepKey, step);
    await prefs.reload();
  }

  Future<int?> getPendingOnboardingStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pendingOnboardingStepKey);
  }

  Future<void> clearPendingOnboardingStep() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingOnboardingStepKey);
    await prefs.reload();
  }

  Future<bool> consumeFirstLoginCoachmarkPending() async {
    final prefs = await SharedPreferences.getInstance();
    final isPending = prefs.getBool(_firstLoginCoachmarkPendingKey) ?? false;
    if (isPending) {
      await prefs.setBool(_firstLoginCoachmarkPendingKey, false);
    }
    return isPending;
  }

  Future<void> clearAuthSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userUidKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.reload();
  }

  Future<void> clearOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
    await prefs.remove(_pendingOnboardingStepKey);
    await prefs.remove(_firstLoginCoachmarkPendingKey);
    await prefs.reload();
  }

  Future<void> markLoggedOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedOutKey, true);
    await prefs.reload();
  }

  Future<void> clearLoggedOutFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedOutKey);
    await prefs.reload();
  }

  Future<bool> wasLoggedOut() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedOutKey) ?? false;
  }

  Future<void> snoozeOptionalUpdate({
    required String latestVersion,
    required Duration duration,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final until = DateTime.now().add(duration).millisecondsSinceEpoch;
    await prefs.setString(_skippedUpdateVersionKey, latestVersion);
    await prefs.setInt(_skippedUpdateUntilEpochMsKey, until);
    await prefs.reload();
  }

  Future<void> clearOptionalUpdateSnooze() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_skippedUpdateVersionKey);
    await prefs.remove(_skippedUpdateUntilEpochMsKey);
    await prefs.reload();
  }

  Future<bool> shouldSuppressOptionalUpdate(String latestVersion) async {
    final prefs = await SharedPreferences.getInstance();
    final skippedVersion = prefs.getString(_skippedUpdateVersionKey);
    final untilEpoch = prefs.getInt(_skippedUpdateUntilEpochMsKey);
    if (skippedVersion == null ||
        skippedVersion.isEmpty ||
        untilEpoch == null ||
        untilEpoch <= 0) {
      return false;
    }

    if (skippedVersion != latestVersion) {
      return false;
    }

    return DateTime.now().millisecondsSinceEpoch < untilEpoch;
  }
}
