import 'package:crypto/crypto.dart';
import '/feature/auth/data/models/login_mod.dart';
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

    // Refresh token রাখা হচ্ছে — access token (১ দিন) শেষ হলে user কে logout না করে নতুন token নেওয়া হবে
    final refresh = response.tokens?.refresh;
    if (refresh != null && refresh.isNotEmpty) {
      await LocalDB.saveRefreshToken(refresh);
    }

  }


  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
