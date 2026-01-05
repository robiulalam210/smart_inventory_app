import 'package:flutter/material.dart';

class AppSizes{
  static const double bodyPadding     = 12;
  static const double bodyTabPadding     = 45;
  static const double preferredBottom = 25;
  static const double borderRadiusSize = 4;
  static const double radius = 12;

  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;
  static double width(BuildContext context)  => MediaQuery.sizeOf(context).width;



  static const double paddingInside = 10;
  // static const double radiusSmall = 10;
  static const double boarderWidth = 0.5;

  // For text
  static TextStyle normalBold(BuildContext context) => Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w800); // 14,  700

  static TextStyle normalLight(BuildContext context) => Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w400); // 14,  400

  static TextStyle xSmallLight(BuildContext context) => Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w400, fontSize: 10); // 10,  400
  static TextStyle xSmallBold(BuildContext context) => Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w800, fontSize: 10); // 10,  400

  static TextStyle docSmallLight(BuildContext context) => Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 6); // 8,  400
  static TextStyle docSmallBold(BuildContext context) => Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w800, fontSize: 6); // 8,  400
  static TextStyle docBigLight(BuildContext context) => Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 8); // 10,  400
  static TextStyle docBigBold(BuildContext context) => Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w800, fontSize: 8); // 10,  400

  static TextStyle smallLight(BuildContext context) => Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w400); // 12,  400

  static TextStyle smallBold(BuildContext context) => Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w800); // 12,  800

  static TextStyle bigBold(BuildContext context) => Theme.of(context).textTheme.titleMedium!; // 16,  500

  static TextStyle vBigBold(BuildContext context) => Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w800, fontSize: 20); // 20,  500

  static TextStyle vBigLight(BuildContext context) => Theme.of(context).textTheme.headlineMedium!; // 28,  400

  static TextStyle vvBigBold(BuildContext context) => Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w800); // 28,  400



}