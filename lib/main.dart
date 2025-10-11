import 'dart:io';
import 'package:window_manager/window_manager.dart';
import 'app/app.dart';
import 'core/configs/configs.dart';
import 'feature/keyboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final dbHelper = DatabaseHelper();
  await dbHelper.initDatabase();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      center: true,
      minimumSize: Size(1200, 800),
      title: AppConstants.appName,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
  );
  runApp(
    ToastificationWrapper(
      child: KeyboardGuard( // 👈 Add this wrapper
        child: MyApp(dbHelper: dbHelper),
      ),
    ),
  );

}
