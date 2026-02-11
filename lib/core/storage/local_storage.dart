import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _anonKey = "anonymous_id";
  static const _userUidKey = "user_uid";

  Future<void> saveAnonymous(String anonId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_anonKey, anonId);
  }

  Future<void> saveUserUid(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userUidKey, uid);
  }

  Future<String?> getUserUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userUidKey);
  }

  Future<String?> getAnonymousId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_anonKey);
  }
}
