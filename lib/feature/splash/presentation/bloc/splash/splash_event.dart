part of 'splash_bloc.dart';

sealed class SplashEvent {}
class GetLoginData extends SplashEvent {}

class NavigateToLogin extends SplashEvent {}

class NavigateToHome extends SplashEvent {}

class ToggleVisibilityEvent extends SplashEvent {}
