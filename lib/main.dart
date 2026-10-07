import 'dart:io';
import 'main_desktop.dart' as desktop;
import 'main_mobile.dart' as mobile;

/// শুধু সুবিধার জন্য (IDE default run)। এটা দুটো অ্যাপই কম্পাইলে টানে।
/// আলাদা build এর জন্য:  -t lib/main_desktop.dart  অথবা  -t lib/main_mobile.dart
Future<void> main() =>
    (Platform.isAndroid || Platform.isIOS) ? mobile.main() : desktop.main();
