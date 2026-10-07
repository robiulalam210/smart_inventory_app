import 'package:flutter/material.dart';

import '../configs/app_colors.dart';
import '../configs/app_sizes.dart';
import '../configs/app_text.dart';

/// অ্যাপের পুরো রঙ/কম্পোনেন্ট থিম (desktop + mobile একই)।
///
/// নীতি:
///  * একটাই ব্র্যান্ড রঙ (primary) — তার উপরের লেখা সবসময় [AppColors.onColor] দিয়ে contrast-নিরাপদ
///  * নিরপেক্ষ রঙ slate স্কেলের (খাঁটি কালো/সাদা নয়) — চোখে আরামদায়ক
///  * semantic রঙ: success সবুজ, danger লাল, warning অ্যাম্বার, info নীল
class AppTheme {
  static ThemeData light(BuildContext context) {
    final primary = AppColors.primaryColor(context);
    final onPrimary = AppColors.onColor(primary);

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      onPrimary: onPrimary,
      secondary: AppColors.secondary(context),
      error: AppColors.danger,
      surface: Colors.white,
      onSurface: AppColors.lightText,
      outline: AppColors.border,
      outlineVariant: AppColors.borderLight,
    );

    return _base(
      context: context,
      brightness: Brightness.light,
      scheme: scheme,
      primary: primary,
      onPrimary: onPrimary,
      scaffold: AppColors.lightBg,
      surface: Colors.white,
      text: AppColors.lightText,
      border: AppColors.borderLight,
      tooltipBg: const Color(0xFF0F172A),
    );
  }

  static ThemeData dark(BuildContext context) {
    final primary = AppColors.primaryColor(context);
    final onPrimary = AppColors.onColor(primary);

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primary,
      onPrimary: onPrimary,
      secondary: AppColors.secondary(context),
      error: const Color(0xFFF87171),
      surface: AppColors.darkBgBottomNav,
      onSurface: AppColors.darkText,
      outline: const Color(0xFF334155),
      outlineVariant: const Color(0xFF243044),
    );

    return _base(
      context: context,
      brightness: Brightness.dark,
      scheme: scheme,
      primary: primary,
      onPrimary: onPrimary,
      scaffold: AppColors.darkBg,
      surface: AppColors.darkBgBottomNav,
      text: AppColors.darkText,
      border: const Color(0xFF243044),
      tooltipBg: const Color(0xFF1E293B),
    );
  }

  static ThemeData _base({
    required BuildContext context,
    required Brightness brightness,
    required ColorScheme scheme,
    required Color primary,
    required Color onPrimary,
    required Color scaffold,
    required Color surface,
    required Color text,
    required Color border,
    required Color tooltipBg,
  }) {
    final isDark = brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppSizes.radiusSmall);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      canvasColor: surface,
      cardColor: surface,
      dividerColor: border,
      fontFamily: 'Poppins',
      colorScheme: scheme,
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
        iconTheme: IconThemeData(color: text),
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(borderRadius: radius),
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? surface : Colors.white,
          foregroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: primary),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 2,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
        ),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: tooltipBg,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        waitDuration: const Duration(milliseconds: 400),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: tooltipBg,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(primary.withValues(alpha: 0.08)),
        headingTextStyle: TextStyle(
          color: text,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        dividerThickness: 0.6,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : null,
        ),
        checkColor: WidgetStateProperty.all(onPrimary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? onPrimary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : null,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : null,
        ),
      ),
    );
  }
}
