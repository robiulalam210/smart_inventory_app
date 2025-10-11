import '../configs/configs.dart';
import 'widgets/app_text_form_field_theme.dart';

class AppTheme {
  static ThemeData light(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      // <--- Set your custom font family here

      // scaffoldBackgroundColor: AppColors.bgLight,
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
      ),
      primaryColor: AppColors.white,
      textTheme: ThemeData.light().textTheme.copyWith(
            displayLarge: TextStyle(color: AppColors.text),
            displayMedium: const TextStyle(color: AppColors.text  ,  fontFamily: 'Roboto',
            ),
            displaySmall: const TextStyle(color: AppColors.text,  fontFamily: 'Roboto',),
            headlineLarge: const TextStyle(color: AppColors.text,  fontFamily: 'Roboto',),
            headlineMedium: const TextStyle(color: AppColors.text,  fontFamily: 'Roboto',),
            headlineSmall: const TextStyle(color: AppColors.text,  fontFamily: 'Roboto',),
            titleLarge: const TextStyle(color: AppColors.text,  fontFamily: 'Roboto',),
            titleMedium: const TextStyle(color: AppColors.text,  fontFamily: 'Roboto',),
            titleSmall: const TextStyle(color: AppColors.text,  fontFamily: 'Roboto',),
            bodyLarge: const TextStyle(color: AppColors.text,  fontFamily: 'Roboto',),
            bodyMedium: const TextStyle(color: AppColors.text,  fontFamily: 'Roboto',),
            bodySmall: const TextStyle(color: AppColors.text,  fontFamily: 'Roboto',),
            labelLarge: const TextStyle(color: AppColors.text,  fontFamily: 'Roboto',),
            labelMedium: const TextStyle(color: AppColors.text,  fontFamily: 'Roboto',),
            labelSmall: const TextStyle(color: AppColors.text,  fontFamily: 'Roboto',),
          ),
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),

      bottomSheetTheme:
          const BottomSheetThemeData(backgroundColor: Colors.white),
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white, scrolledUnderElevation: 0),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.red,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(AppColors.primaryColor),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius))),
        ),
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(AppColors.primaryColor),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          side: const BorderSide(color: AppColors.primaryColor),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius)),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.iconLight),
      dividerColor: AppColors.highlightLight,
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: AppColors.highlightLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(100, 56),
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppSizes.borderRadiusSize),
            ),
          ),
        ),
      ),

      inputDecorationTheme: AppTextFormFieldTheme.lightInputDecorationTheme,
      expansionTileTheme:
          const ExpansionTileThemeData(shape: RoundedRectangleBorder()),
      badgeTheme:
          BadgeThemeData(backgroundColor: AppColors.redColor, smallSize: 8),
    );
  }
}
