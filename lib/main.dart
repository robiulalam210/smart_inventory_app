import 'dart:io';
import 'package:window_manager/window_manager.dart';
import 'app/app.dart';
import 'core/configs/configs.dart';
import 'feature/keyboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_retriever/screen_retriever.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final dbHelper = DatabaseHelper();
  await dbHelper.initDatabase();
  // 🖥️ Desktop window setup (dynamic sizing)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    final display = await screenRetriever.getPrimaryDisplay();
    final width = display.size.width;

    Size windowSize;
    Size minSize;

    if (width <= 1366) {
      windowSize = const Size(1000, 650);
      minSize = const Size(950, 600);
      await windowManager.maximize();
    } else if (width <= 1920) {
      windowSize = const Size(1200, 750);
      minSize = const Size(1100, 700);
    } else {
      windowSize = const Size(1400, 850);
      minSize = const Size(1200, 750);
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
