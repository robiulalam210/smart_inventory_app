import 'package:crypto/crypto.dart';
import 'package:http/http.dart'as http;
import '../../../../core/configs/configs.dart';
import 'login_ser.dart';

class AuthService {
  Future<dynamic> tryOnlineLogin(String username, String password) async {
    return await loginService(payload: {
      'email': username,
      'password': password,
    });
  }
  Future<void> saveUserLocally(dynamic db, String plainPassword, dynamic response) async {
    final user = response.user;
    final now = DateTime.now();

    // Download logo image bytes for offline use
    Uint8List? logoBytes;
    try {
      final logoUrl = user?.organizationLogo;
      if (logoUrl != null && logoUrl.isNotEmpty) {
        final imageResponse = await http.get(Uri.parse(logoUrl));
        if (imageResponse.statusCode == 200) {
          logoBytes = imageResponse.bodyBytes;
        }
      }
    } catch (e) {
      debugPrint('Failed to download organization logo: $e');
    }

    // Save some login info to local preferences/db
    await LocalDB.postLoginInfo(
      email: user?.email ?? "",
      password: plainPassword,
      token: response.accessToken ?? "",
      branchId: user?.branchId,
      branchName: user?.branchName ?? '',
      bsType: user?.bsType ?? '',
      userId: user?.id,
      userType: user?.userType ?? '',
      isSupperAdmin: 0,
      userName: user?.name ?? '',
      tokenExpiry: AppConstants.sessionExpire,
    );

    // Insert or replace user in database, including logo bytes
    await db.execute('''
      INSERT OR REPLACE INTO users (
        saas_user_id, name, email, phone, password,
        dbname, token, last_verify_date,
        branch_id, branch_name, bs_type,
        user_id, user_type, is_supper_admin, offline_login_expiry,
        organization_name, organization_address, organization_logo_blob
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      user?.id,
      user?.name,
      user?.email,
      user?.mobile,
      hashPassword(plainPassword),
      user?.branchName ?? '',
      response.accessToken ?? '',
      now.toIso8601String(),
      user?.branchId,
      user?.branchName ?? '',
      user?.bsType ?? '',
      user?.userId,
      user?.userType ?? '',
      0,
      AppConstants.sessionExpire.toIso8601String(),
      user?.organizationName ?? '',
      user?.organizationAddress ?? '',
      logoBytes, // actual image bytes as blob
    ]);
  }


  //
  // Future<void> saveUserLocally(
  //     dynamic db, String plainPassword, dynamic response) async {
  //   final user = response.user;
  //   final now = DateTime.now();
  //
  //   await LocalDB.postLoginInfo(
  //     email: user?.email ?? "",
  //     password: plainPassword,
  //     token: response.accessToken ?? "",
  //     branchId: user?.branchId,
  //     branchName: user?.branchName ?? '',
  //     bsType: user?.bsType ?? '',
  //     userId: user?.id,
  //     userType: user?.userType ?? '',
  //     isSupperAdmin: 0,
  //     userName: user?.name ?? '',
  //     tokenExpiry: AppConstants.sessionExpire,
  //   );
  //
  //   await db.execute('''
  //     INSERT OR REPLACE INTO users (
  //       saas_user_id, name, email, phone, password,
  //       dbname, token, last_verify_date,
  //       branch_id, branch_name, bs_type,
  //       user_id, user_type, is_supper_admin, offline_login_expiry
  //     ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  //   ''', [
  //     user?.sUid,
  //     user?.name,
  //     user?.email,
  //     user?.mobile,
  //     hashPassword(plainPassword),
  //     user?.branchName ?? '',
  //     response.accessToken ?? '',
  //     now.toIso8601String(),
  //     user?.branchId,
  //     user?.branchName ?? '',
  //     user?.bsType ?? '',
  //     user?.userId,
  //     user?.userType ?? '',
  //     0,
  //     AppConstants.sessionExpire.toIso8601String(),
  //   ]);
  // }

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
