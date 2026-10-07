import 'package:flutter/widgets.dart';

/// Session শেষ হলে কোন login স্ক্রিনে যাবে। main_desktop.dart / main_mobile.dart এ সেট হয়,
/// যাতে core কোড কোনো UI (desktop/mobile) সরাসরি import না করে।
Widget Function()? loginScreenBuilder;
