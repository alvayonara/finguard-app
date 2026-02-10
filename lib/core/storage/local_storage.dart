import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _anonKey = "anonymous_id";
  static const _userUidKey = "user_uid";

  Future<void> saveUser(String anonymousId, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_anonKey, anonymousId);
    await prefs.setString(_userUidKey, userId);
  }

  Future<String?> getAnonymousId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_anonKey);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userUidKey);
  }
}
