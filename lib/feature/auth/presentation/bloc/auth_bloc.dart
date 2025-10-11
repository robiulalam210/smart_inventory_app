import '../../../../core/core.dart';

import '../../../splash/presentation/bloc/connectivity_bloc/connectivity_bloc.dart';
import '../../../splash/presentation/bloc/connectivity_bloc/connectivity_state.dart';
import '../../data/repositories/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ConnectivityBloc connectivityBloc;
  final AuthService authService;

  AuthBloc({
    required this.connectivityBloc,
    required this.authService,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final db = await DatabaseHelper().database;
    final connectivityState = connectivityBloc.state;

    try {
      final localUsers = db.select(
        'SELECT * FROM users WHERE email = ?',
        [event.username],
      );

      final passwordHash = authService.hashPassword(event.password);
      final now = DateTime.now();

      if (localUsers.isEmpty) {
        // No local user
        if (connectivityState is ConnectivityOffline) {
          emit(AuthError("No internet connection. Please try again later."));
        } else {
          await _attemptOnlineLogin(db, event, emit);
        }
        return;
      }

      // Local user exists
      final validOfflineUsers = localUsers.where((user) {
        final expiry = DateTime.tryParse(user['offline_login_expiry'] ?? '');
        return user['password'] == passwordHash &&
            expiry != null &&
            expiry.isAfter(now);
      }).toList();

      if (validOfflineUsers.isNotEmpty) {
        final user = validOfflineUsers.first;

        await LocalDB.postLoginInfo(
          email: user['email'],
          password: event.password,
          token: user['token'] ?? '',
          branchId: user['branch_id'],
          branchName: user['branch_name'] ?? '',
          bsType: user['bs_type'] ?? '',
          userId: user['s_uid'],
          userType: user['user_type'] ?? '',
          userName: user['name'] ?? '',
          isSupperAdmin: (user['is_supper_admin'] ?? 0) == 1,
          tokenExpiry: AppConstants.sessionExpire,
        );

        emit(AuthAuthenticatedOffline(user));
      } else {
        if (connectivityState is ConnectivityOffline) {
          emit(AuthError(
              'Offline login expired or incorrect password. No internet connection.'));
        } else {
          await _attemptOnlineLogin(db, event, emit);
        }
      }
    } catch (e, stack) {
      debugPrint("Login Error: $e\n$stack");
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _attemptOnlineLogin(
      dynamic db, LoginRequested event, Emitter<AuthState> emit) async {
    final response =
        await authService.tryOnlineLogin(event.username, event.password);

    if (response.success == true) {
      await authService.saveUserLocally(db, event.password, response);
      emit(AuthAuthenticated(response));
    } else {
      emit(AuthError(response.message ?? "Login failed. Check credentials."));
    }
  }
}
