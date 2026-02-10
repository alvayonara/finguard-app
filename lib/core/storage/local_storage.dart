import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  Future<void> saveUser(String anonymousId, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('anonymous_id', anonymousId);
    await prefs.setString('user_id', userId);
  }

  Future<String?> getAnonymousId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('anonymous_id');
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}
