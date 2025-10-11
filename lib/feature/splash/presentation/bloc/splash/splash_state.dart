part of 'splash_bloc.dart';

sealed class SplashState {}

final class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashLoaded extends SplashState {}

class SplashNavigateToLogin extends SplashState {}

class SplashNavigateToHome extends SplashState {}

class VisibilityChanged extends SplashState {
  final bool isVisible;
  VisibilityChanged(this.isVisible);
}