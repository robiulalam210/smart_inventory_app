part of 'theme_cubit.dart';

class ThemeState {
  final ThemeMode themeMode;
  final Color primaryColor;

  ThemeState({required this.themeMode, required this.primaryColor});

  ThemeState copyWith({ThemeMode? themeMode, Color? primaryColor}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }
}