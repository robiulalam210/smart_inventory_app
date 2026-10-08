import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../configs/app_constants.dart';
import '../configs/app_urls.dart';
import '../database/login.dart';
import '../../feature/auth/data/repositories/login_ser.dart';
import 'offline_config.dart';

/// "Wi-Fi connected" মানেই internet আছে না — তাই server এর /health/ endpoint এ
/// ছোট request পাঠিয়ে আসলেই server পাওয়া যাচ্ছে কিনা দেখা হয়।
class ConnectivityMonitor {
  ConnectivityMonitor._();
  static final ConnectivityMonitor instance = ConnectivityMonitor._();

  /// UI ও sync engine এটা শোনে
  final ValueNotifier<bool> online = ValueNotifier<bool>(true);

  Timer? _timer;
  StreamSubscription? _sub;
  bool _probing = false;

  bool get isOnline => online.value;

  Future<void> start() async {
    _sub ??= Connectivity().onConnectivityChanged.listen((_) => probe());
    await probe();
  }

  void stop() {
    _timer?.cancel();
    _sub?.cancel();
    _sub = null;
  }

  Future<bool> probe() async {
    if (_probing) return online.value;
    _probing = true;
    bool ok = false;
    try {
      final res = await http
          .get(Uri.parse('${AppUrls.baseUrlMain}/health/'))
          .timeout(const Duration(seconds: 6));
      ok = res.statusCode >= 200 && res.statusCode < 500;
    } catch (_) {
      ok = false;
    } finally {
      _probing = false;
    }
    _set(ok);
    return ok;
  }

  /// Network request ব্যর্থ হলে request layer এটা ডেকে সাথে সাথে offline ঘোষণা করে
  void markOffline() => _set(false);

  void _set(bool value) {
    if (online.value != value) online.value = value;
    _timer?.cancel();
    _timer = Timer(value ? OfflineConfig.onlineProbeInterval : OfflineConfig.offlineProbeInterval, probe);
  }
}

/// Access token (১ দিন) expire হলে user কে আবার login করতে না বলে চুপচাপ নতুন token নেওয়া হয়।
/// ১) প্রথমে refresh token দিয়ে চেষ্টা (mobile + desktop দুটোতেই)
/// ২) সেটা না হলে (যেমন desktop ৭ দিনের বেশি offline ছিল) সংরক্ষিত credential দিয়ে আবার login
class SessionKeeper {
  SessionKeeper._();

  static Future<bool>? _inFlight;

  /// একসাথে কয়েকটা request 401 পেলেও login একবারই হবে
  static Future<bool> renew() => _inFlight ??= _renew().whenComplete(() => _inFlight = null);

  static Future<bool> _renew() async {
    if (await _renewWithRefreshToken()) return true;
    return _renewWithPassword();
  }

  /// POST /api/auth/token/refresh/ → {access, refresh}
  /// Server এ ROTATE_REFRESH_TOKENS চালু, তাই প্রতিবার নতুন refresh token ও আসে — সেটাও রাখা হয়।
  static Future<bool> _renewWithRefreshToken() async {
    try {
      final refresh = await LocalDB.getRefreshToken();
      if (refresh == null) return false;
      final res = await http
          .post(
            Uri.parse(AppUrls.tokenRefresh),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh': refresh}),
          )
          .timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) return false;
      final data = jsonDecode(res.body);
      if (data is! Map) return false;
      final access = data['access']?.toString();
      if (access == null || access.isEmpty) return false;
      await LocalDB.updateTokens(
        access: access,
        refresh: data['refresh']?.toString(),
        tokenExpiry: AppConstants.sessionExpire,
      );
      return true;
    } catch (e) {
      debugPrint('SessionKeeper refresh failed: $e');
      return false;
    }
  }

  static Future<bool> _renewWithPassword() async {
    try {
      final info = await LocalDB.getLoginInfo();
      final email = '${info?['email'] ?? ''}';
      final password = '${info?['password'] ?? ''}';
      if (email.isEmpty || password.isEmpty) return false;
      final payload = <String, dynamic>{'password': password};
      if (email.contains('@')) {
        payload['email'] = email;
      } else {
        payload['username'] = email;
      }
      final res = await loginService(payload: payload);
      final access = res.tokens?.access;
      if (res.success != true || access == null || access.isEmpty) return false;
      await LocalDB.postLoginInfo(
        email: email,
        password: password,
        token: access,
        userId: res.user?.id ?? info?['userId'],
        userName: res.user?.username ?? '${info?['userName'] ?? ''}',
        userType: res.user?.role ?? '${info?['userType'] ?? ''}',
        isSupperAdmin: info?['isSupperAdmin'] == true ? 1 : 0,
        tokenExpiry: AppConstants.sessionExpire,
      );
      final newRefresh = res.tokens?.refresh;
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await LocalDB.saveRefreshToken(newRefresh);
      }
      return true;
    } catch (e) {
      debugPrint('SessionKeeper.renew failed: $e');
      return false;
    }
  }
}
