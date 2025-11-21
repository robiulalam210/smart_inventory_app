import 'package:shared_preferences/shared_preferences.dart';

class LoginLocalStorage {
  static const String _keyUsername = 'saved_username';
  static const String _keyPassword = 'saved_password';

  /// Save username & password
  static Future<void> saveLogin(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyPassword, password);
  }

  /// Get saved login data
  static Future<Map<String, String?>> getSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString(_keyUsername),
      'password': prefs.getString(_keyPassword),
    };
  }

  /// Clear login (optional)
  static Future<void> clearLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyPassword);
  }
}
