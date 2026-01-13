import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../../core/configs/app_colors.dart';
import '../../../../core/database/auth_db.dart';



part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(ThemeState(themeMode: ThemeMode.light, primaryColor: AppColors.defaultPrimary)) {
    _updateSystemUi(state.primaryColor, state.themeMode);
  }


  Future<void> loadFromStorage() async {
    try {

      final modeStr = await AuthLocalDB.getThemeMode();
      if (modeStr != null && modeStr.isNotEmpty) {
        ThemeMode mode = ThemeMode.system;
        if (modeStr == 'light') mode = ThemeMode.light;
        if (modeStr == 'dark') mode = ThemeMode.dark;
        emit(state.copyWith(themeMode: mode));


        final colorStr = await AuthLocalDB.getPrimaryColor();
        if (colorStr != null && colorStr.isNotEmpty) {
          final val = int.tryParse(colorStr);
          if (val != null) {
            final color = Color(val);
            emit(state.copyWith(primaryColor: color));
          }
        }
      }

      // after emitting loaded values, update system UI once
      _updateSystemUi(state.primaryColor, state.themeMode);
    } catch (_) {
      // ignore errors - keep defaults
    }
  }

  void setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    _updateSystemUi(state.primaryColor, mode);

    final modeStr = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
        ? 'dark'
        : 'system';

    await AuthLocalDB.saveThemeMode(modeStr); // <-- await here
  }


  void setPrimaryColor(Color color) {
    emit(state.copyWith(primaryColor: color));
    _updateSystemUi(color, state.themeMode);
    // persist color as integer string
    AuthLocalDB.savePrimaryColor(color.value.toString());
  }


  void _updateSystemUi(Color color, ThemeMode mode) {
    // Platform brightness if system mode
    Brightness brightness;
    switch (mode) {
      case ThemeMode.dark:
        brightness = Brightness.dark;
        break;
      case ThemeMode.light:
        brightness = Brightness.light;
        break;
      case ThemeMode.system:
        brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        break;
    }
    final iconBrightness = brightness == Brightness.dark ? Brightness.light : Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: color,
      systemNavigationBarColor: color,
      statusBarIconBrightness: iconBrightness,
      systemNavigationBarIconBrightness: iconBrightness,
    ));
  }
}