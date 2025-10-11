import 'package:flutter/cupertino.dart';

class AppRoutes{
  static Future pushReplacement(BuildContext context,page)    => Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_)=> page));
  static Future push(BuildContext context,page)               => Navigator.push(context, CupertinoPageRoute(builder: (_)=> page));
  static Future pushAndRemoveUntil(BuildContext context,page) => Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (_)=> page), (route) => false);
  static void pop(BuildContext context)                     =>Navigator.pop(context);
}