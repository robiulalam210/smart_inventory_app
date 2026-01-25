import 'package:flutter/cupertino.dart';

class AppRoutes {
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      CupertinoPageRoute(builder: (_) => page),
    );
  }

  static Future<T?> pushReplacement<T>(BuildContext context, Widget page) {
    return Navigator.pushReplacement<T, T>(
      context,
      CupertinoPageRoute(builder: (_) => page),
    );
  }

  static Future<T?> pushAndRemoveUntil<T>(
      BuildContext context, Widget page) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      CupertinoPageRoute(builder: (_) => page),
          (route) => false,
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }
}
