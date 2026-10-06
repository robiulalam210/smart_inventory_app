import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../../feature/auth/data/models/login_mod.dart';
import '../../feature/auth/data/repositories/auth_service.dart';
import 'local_store.dart';
import 'offline_config.dart';
import 'sync_engine.dart';

/// Internet না থাকলেও desktop এ login।
///
/// শর্ত: এই কম্পিউটারে ওই user আগে অন্তত একবার online এ login করেছে।
/// Password নিজে কোথাও রাখা হয় না — শুধু salt সহ বারবার hash করা মান (অনুমান করে ভাঙা কঠিন)।
class OfflineAuth {
  OfflineAuth._();

  static const int _rounds = 20000;
  static String _key(String username) => 'auth:${username.trim().toLowerCase()}';

  static String _hash(String salt, String password) {
    // FIX: utf8.encode এখন Uint8List দেয়; sha256 এর .bytes হলো List<int> — তাই type List<int>
    List<int> digest = utf8.encode('$salt:$password');
    for (var i = 0; i < _rounds; i++) {
      digest = sha256.convert(digest).bytes;
    }
    return base64.encode(digest);
  }

  /// সফল online login এর পর ডাকা হয়
  static Future<void> remember(String username, String password, LoginModel response) async {
    if (!OfflineConfig.enabled || !LocalStore.instance.isOpen) return;
    try {
      final rnd = Random.secure();
      final salt = base64.encode(List<int>.generate(16, (_) => rnd.nextInt(256)));
      final hash = await compute(_hashIsolate, [salt, password]);
      await LocalStore.instance.setMeta(_key(username), jsonEncode({
        'salt': salt,
        'hash': hash,
        'model': response.toJson(),
        'saved_at': DateTime.now().toIso8601String(),
      }));
      // নতুন user হলে device এ তাকে অনুমোদিত করা (তার offline কাজ sync হবে)
      if (await SyncEngine.instance.isSetupDone()) {
        SyncEngine.instance.registerDevice().catchError((_) {});
      }
    } catch (e) {
      debugPrint('OfflineAuth.remember failed: $e');
    }
  }

  /// Offline login: মিললে আগের login তথ্য ফেরত, নাহলে null
  static Future<LoginModel?> verify(String username, String password) async {
    if (!OfflineConfig.enabled || !LocalStore.instance.isOpen) return null;
    final raw = await LocalStore.instance.getMeta(_key(username));
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final hash = await compute(_hashIsolate, ['${data['salt']}', password]);
      if (hash != data['hash']) return null;
      final model = LoginModel.fromJson(Map<String, dynamic>.from(data['model'] as Map));
      model.success = true;
      model.message = 'Offline login';
      // Logout এ মুছে যাওয়া session তথ্য ফিরিয়ে আনা (token পুরনো হলে online হলেই নতুন নেওয়া হবে)
      await AuthService().saveUserLocally(password, model);
      return model;
    } catch (e) {
      debugPrint('OfflineAuth.verify failed: $e');
      return null;
    }
  }
}

String _hashIsolate(List<String> args) => OfflineAuth._hash(args[0], args[1]);

