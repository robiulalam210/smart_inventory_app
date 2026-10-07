import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'core/configs/configs.dart';
import 'core/database/auth_db.dart';
import 'feature/keyboard.dart';

/// দুই অ্যাপের (desktop + mobile) কমন সেটআপ।
Future<Locale> initCommon() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final savedLang = await AuthLocalDB.getLanguage();
  return savedLang != null && savedLang.isNotEmpty
      ? Locale(savedLang)
      : const Locale('en');
}

void runMyApp({required Locale startLocale, required Widget home}) {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
  );
  runApp(
    ToastificationWrapper(
      child: KeyboardGuard(
        child: EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('bn')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          startLocale: startLocale,
          child: MyApp(home: home),
        ),
      ),
    ),
  );
}
