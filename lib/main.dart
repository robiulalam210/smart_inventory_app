import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:window_manager/window_manager.dart';
import 'app/app.dart';
import 'core/configs/configs.dart';
import 'core/database/auth_db.dart';
import 'feature/keyboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_retriever/screen_retriever.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final savedLang = await AuthLocalDB.getLanguage();
  final startLocale = savedLang != null && savedLang.isNotEmpty
      ? Locale(savedLang)
      : const Locale('en');
  // 🖥️ Desktop window setup (dynamic sizing)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    final display = await screenRetriever.getPrimaryDisplay();
    final width = display.size.width;

    Size windowSize;
    Size minSize;
    bool shouldMaximize = false;

    if (width <= 1366) {
      // For small screens, maximize to use full available space
      windowSize = const Size(1350, 768); // Set to common small screen resolution
      minSize = const Size(900, 600);
      shouldMaximize = true;
    } else if (width <= 1920) {

      // For medium screens, use reasonable window size
      windowSize = const Size(1150, 750);
      minSize = const Size(1100, 700);
      shouldMaximize = false;
    } else {
      // For large screens, use larger window but don't maximize
      windowSize = const Size(1400, 850);
      minSize = const Size(1200, 750);
      shouldMaximize = false;
    }

    final windowOptions = WindowOptions(
      size: windowSize,
      minimumSize: minSize,
      center: true,
      title: AppConstants.appName,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();

      // Only maximize after the window is shown
      if (shouldMaximize) {
        await windowManager.maximize();
      }
    });
  }
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
          child: const MyApp(),
        ),
      ),
    ),
  );
}