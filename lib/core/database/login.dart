import 'package:shared_preferences/shared_preferences.dart';

import '../configs/configs.dart';

class LocalDB {
  static const String _prefix = 'login_lab_box_';

  //! Save login info
  static Future<void> postLoginInfo({
    required String email,
    required String password,
    required String token,
    required dynamic userId,
    required String userName,
    required String userType,
    required dynamic isSupperAdmin,
    required DateTime tokenExpiry,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('${_prefix}email', email);
    await prefs.setString('${_prefix}password', password);
    await prefs.setString('${_prefix}token', token);
    await prefs.setString('${_prefix}userId', userId.toString());
    await prefs.setString('${_prefix}userName', userName);
    await prefs.setString('${_prefix}userType', userType);
    await prefs.setBool(
        '${_prefix}isSupperAdmin', isSupperAdmin == 1 || isSupperAdmin == true);
    await prefs.setString(
        '${_prefix}token_expiry', tokenExpiry.toIso8601String()); // নতুন সেভ
  }

  //! Read login info
  static Future<Map<String, dynamic>?> getLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();

    final email = prefs.getString('${_prefix}email');
    if (email == null) return null;

    return {
      'email': email,
      'password': prefs.getString('${_prefix}password') ?? '',
      'token': prefs.getString('${_prefix}token') ?? '',
      'branchId': prefs.getString('${_prefix}branchId'),
      'branchName': prefs.getString('${_prefix}branchName') ?? '',
      'bsType': prefs.getString('${_prefix}bsType') ?? '',
      'userId': prefs.getString('${_prefix}userId'),
      'userName': prefs.getString('${_prefix}userName') ?? '',
      'userType': prefs.getString('${_prefix}userType') ?? '',
      'token_expiry ': prefs.getString('${_prefix}token_expiry') ?? '',
      'isSupperAdmin': prefs.getBool('${_prefix}isSupperAdmin') ?? false,
    };
  }

  //! Clear login info
  static Future<void> delLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_prefix)) {
        await prefs.remove(key);
      }
    }
  }

  static Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString('${_prefix}token_expiry');
    if (expiryStr == null) {
      debugPrint("Token expiry not found");
      return false;
    }

    final expiryDate = DateTime.parse(expiryStr);
    final now = DateTime.now();

    final difference = expiryDate.difference(now);
    if (difference.isNegative) {
      debugPrint("Token already expired");
      return false;
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    debugPrint("Time left until token expires: $hours hours, $minutes minutes, $seconds seconds");

    return now.isBefore(expiryDate);
  }


}
