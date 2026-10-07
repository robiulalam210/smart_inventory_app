import 'bootstrap.dart';
import 'core/configs/configs.dart';
import 'core/configs/login_redirect.dart';
import 'feature/auth/presentation/mobile/mobile_login_scr.dart';
import 'feature/splash/presentation/mobile/mobile_splash_screen.dart';

/// Android / iOS entry point:  flutter run -t lib/main_mobile.dart
Future<void> main() async {
  final startLocale = await initCommon();
  // Phone হলে portrait lock (ঘোরালে যেন layout না বদলায়)।
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final shortestSide = view.physicalSize.shortestSide / view.devicePixelRatio;
  if (shortestSide < 600) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  loginScreenBuilder = () => const MobileLoginScr();
  runMyApp(startLocale: startLocale, home: MobileSplashScreen());
}
