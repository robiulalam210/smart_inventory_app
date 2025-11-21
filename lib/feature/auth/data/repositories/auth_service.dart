import 'package:crypto/crypto.dart';
import 'package:meherin_mart/feature/auth/data/models/login_mod.dart';
import '../../../../core/configs/configs.dart';

class AuthService {

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
