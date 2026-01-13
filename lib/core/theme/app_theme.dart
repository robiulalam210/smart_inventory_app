import 'package:flutter/material.dart';

import '../configs/app_colors.dart';
import '../configs/app_sizes.dart';
import '../configs/app_text.dart';

class AppTheme {
  // Pass BuildContext (from widgets) to get bloc/theme colors
  static ThemeData light(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        primary: AppColors.primaryColor(context),
        seedColor: AppColors.primaryColor(context),
        secondary: AppColors.secondary(context),
        error: AppColors.error,
        surface: AppColors.lightBg,
        brightness: Brightness.light,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyle.titleBold(context),
        titleMedium: AppTextStyle.subtitle(context),
        bodyMedium: AppTextStyle.body(context),
        labelLarge: AppTextStyle.button(context),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.lightText),
        titleTextStyle: TextStyle(
          color: AppColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryColor(context),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            side: BorderSide(color: AppColors.primaryColor(context)),
          ),
        ),
      ),
    );
  }

  static ThemeData dark(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        primary: AppColors.primaryColor(context),
        seedColor: AppColors.primaryColor(context),
        secondary: AppColors.secondary(context),
        error: AppColors.error,
        surface: Colors.black,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      // Copy text and button themes as above, adjusting colors for dark mode
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryColor(context),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            side: BorderSide(color: AppColors.primaryColor(context)),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyle.titleBold(context),
        titleMedium: AppTextStyle.subtitle(context),
        bodyMedium: AppTextStyle.body(context),
        labelLarge: AppTextStyle.button(context),
      ),
    );
  }
}