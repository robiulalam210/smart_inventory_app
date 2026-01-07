part of 'splash_bloc.dart';

sealed class SplashEvent {}

class CheckAppVersionEvent extends SplashEvent {
  final BuildContext context;
  CheckAppVersionEvent(this.context);
}

class CheckLoginStatusEvent extends SplashEvent {}