part of 'splash_bloc.dart';

sealed class SplashState {}

final class SplashInitial extends SplashState {}


class SplashLoading extends SplashState {}

class VersionFailure extends SplashState {
  final String message;
  VersionFailure(this.message);
}

/// 🔒 App paused by admin
class AppPausedState extends SplashState {}

/// 🚨 Force update required
class AppForceUpdateState extends SplashState {
  final String url;
  final String? message;
  AppForceUpdateState({required this.url, this.message});
}

/// 🔔 Optional update
class UpdateAvailableState extends SplashState {
  final String url;
  final String? message;
  UpdateAvailableState({required this.url, this.message});
}

/// 🔑 Navigation
class SplashNavigateToLogin extends SplashState {}

class SplashNavigateToHome extends SplashState {}