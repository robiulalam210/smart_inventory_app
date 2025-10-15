import 'package:crypto/crypto.dart';
import 'package:http/http.dart'as http;
import 'package:smart_inventory/feature/auth/data/models/login_mod.dart';
import '../../../../core/configs/configs.dart';
import 'login_ser.dart';

class AuthService {
  // Future<dynamic> tryOnlineLogin(String username, String password) async {
  //   return await loginService(payload: {
  //     'email': username,
  //     'password': password,
  //   });
  // }
  Future<void> saveUserLocally( String plainPassword, LoginModel response) async {
    final user = response.user;



    // Save some login info to local preferences/db
    await LocalDB.postLoginInfo(
      email: user?.email ?? "",
      password: plainPassword,
      token: response.tokens?.access ?? "",

      userId: user?.id,
      userType: user?.role ?? '',
      isSupperAdmin: 0,
      userName: user?.username ?? '',
      tokenExpiry: AppConstants.sessionExpire,
    );

  }


  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
