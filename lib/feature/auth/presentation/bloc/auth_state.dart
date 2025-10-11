

import '../../data/models/login_mod.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final LoginModel user;

  AuthAuthenticated(this.user);
}
class AuthAuthenticatedOffline extends AuthState {
  final Map<String, Object?> user;
  AuthAuthenticatedOffline(this.user);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
