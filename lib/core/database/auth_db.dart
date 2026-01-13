import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDB {
  static const storage = FlutterSecureStorage();

  static const String tokenKey = "accessToken";
  static const String userIdKey = "userId";
  static const String userTypeKey = "userType";
  static const String branchIdKey = "branchId";
  static const String branchNameKey = "branchName";
  static const String sUidKey = "sUid";
  static const String bsTypeKey = "bsType";
  static const String organizationIdKey = "organization_id";
  static const String organizationMobileKey = "organization_mobile";
  static const String organizationNameKey = "organization_name";

  static const String emailKey = "email";
  static const String passwordKey = "password";

  // UI prefs - persist these across logout
  static const String languageKey = "app_language";
  static const String primaryColorKey = "primary_color"; // store Color.value as string
  static const String themeModeKey = "theme_mode"; // 'light'|'dark'|'system'
  static const String appBackgroundKey = "app_background"; // optional use

  // Save login data
  static Future<void> saveLoginData(Map<String, dynamic> user, String token) async {
    await storage.write(key: tokenKey, value: token);
    await storage.write(key: userIdKey, value: user["user_id"].toString());
    await storage.write(key: userTypeKey, value: user["user_type"].toString());
    await storage.write(key: branchIdKey, value: user["branch_id"].toString());
    await storage.write(key: branchNameKey, value: user["branch_name"].toString());
    await storage.write(key: sUidKey, value: user["s_uid"].toString());
    await storage.write(key: organizationIdKey, value: user["organization_id"].toString());
    await storage.write(key: organizationNameKey, value: user["organization_name"].toString());
    await storage.write(key: organizationMobileKey, value: user["organization_mobile"].toString());
    await storage.write(key: bsTypeKey, value: user["bs_type"].toString());
  }

  // Save email & password
  static Future<void> saveCredentials(String email, String password) async {
    await storage.write(key: emailKey, value: email);
    await storage.write(key: passwordKey, value: password);
  }

  // Get saved email & password
  static Future<String?> getSavedEmail() => storage.read(key: emailKey);
  static Future<String?> getSavedPassword() => storage.read(key: passwordKey);

  // Build headers
  static Future<Map<String, String>> buildHeader() async {
    final token = await storage.read(key: tokenKey);
    final userId = await storage.read(key: userIdKey);
    final userType = await storage.read(key: userTypeKey);
    final branchId = await storage.read(key: branchIdKey);
    final branchName = await storage.read(key: branchNameKey);
    final bsType = await storage.read(key: bsTypeKey);

    return {
      "Content-Type": "application/json",
      "accept": "application/json",
      "Authorization": "Bearer ${token ?? ''}",
      "branch-id": branchId ?? '',
      "branch-name": branchName ?? '',
      "bs-type": bsType ?? '',
      "user-id": userId ?? '',
      "is-super-admin": (userType == "Super_Admin").toString(),
    };
  }

  static Future<String?> getToken() => storage.read(key: tokenKey);
  static Future<String?> getUserid() => storage.read(key: userIdKey);
  static Future<String?> getOrganizationId() => storage.read(key: organizationIdKey);
  static Future<String?> getOrganizationMobile() => storage.read(key: organizationMobileKey);
  static Future<String?> getOrganizationName() => storage.read(key: organizationNameKey);

  // ---------------- UI prefs getters/setters ----------------

  static Future<void> saveLanguage(String code) =>
      storage.write(key: languageKey, value: code);

  static Future<String?> getLanguage() => storage.read(key: languageKey);

  static Future<void> savePrimaryColor(String colorValue) =>
      storage.write(key: primaryColorKey, value: colorValue);

  static Future<String?> getPrimaryColor() => storage.read(key: primaryColorKey);

  static Future<void> saveThemeMode(String mode) =>
      storage.write(key: themeModeKey, value: mode);

  static Future<String?> getThemeMode() => storage.read(key: themeModeKey);

  static Future<void> saveAppBackground(String value) =>
      storage.write(key: appBackgroundKey, value: value);

  static Future<String?> getAppBackground() => storage.read(key: appBackgroundKey);

  // ---------------- Clear ----------------
  /// Clears only login-related sensitive data while keeping UI preferences (language, color, theme, background).
  static Future<void> clear() async {
    // শুধু login-related sensitive data মুছে ফেলুন
    await storage.delete(key: tokenKey);
    await storage.delete(key: userIdKey);
    await storage.delete(key: userTypeKey);
    await storage.delete(key: branchIdKey);
    await storage.delete(key: branchNameKey);
    await storage.delete(key: sUidKey);
    await storage.delete(key: bsTypeKey);

    // Keep email & password and UI prefs (language, theme, color, background)
    // If you want to remove saved credentials on logout as well, uncomment:
    // await storage.delete(key: emailKey);
    // await storage.delete(key: passwordKey);
  }

  /// Delete everything (useful for dev or full reset).
  static Future<void> clearAll() async {
    await storage.deleteAll();
  }
}