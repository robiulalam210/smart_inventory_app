import 'package:easy_localization/easy_localization.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';
import 'bootstrap.dart';
import 'core/configs/configs.dart';
import 'core/offline/offline_gateway.dart';
import 'core/configs/login_redirect.dart';
import 'feature/auth/presentation/desktop/login_scr.dart';
import 'feature/splash/presentation/desktop/splash_screen.dart';

/// Windows / Linux / macOS entry point:  flutter run -t lib/main_desktop.dart -d windows
Future<void> main() async {
  final startLocale = await initCommon();
  // 🖥️ Desktop window setup (dynamic sizing)
  {
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
      windowSize = const Size(1280, 800);
      minSize = const Size(1200, 700);
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
  // Desktop: offline database + auto sync চালু
  try {
    await OfflineGateway.instance.init();
  } catch (e) {
    debugPrint('Offline layer init failed: $e');
  }
  loginScreenBuilder = () => const LogInScreen();
  runMyApp(startLocale: startLocale, home: SplashScreen());
}
