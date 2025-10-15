import '../../../../core/core.dart';

import '../../../splash/presentation/bloc/connectivity_bloc/connectivity_bloc.dart';
import '../../../splash/presentation/bloc/connectivity_bloc/connectivity_state.dart';
import '../../data/repositories/auth_service.dart';
import '../../data/repositories/login_ser.dart';
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
    final connectivityState = connectivityBloc.state;

    try {


      final now = DateTime.now();

        // No local user
        if (connectivityState is ConnectivityOffline) {
          emit(AuthError("No internet connection. Please try again later."));
        } else {

          final response =
          await   loginService(payload: {
            "username": event.username,
            "password": event.password,
          });

          print(response.success);
          print(response.user);
          if (response.success == true) {
            await authService.saveUserLocally( event.password,response);
            emit(AuthAuthenticated(response));
          } else {
            emit(AuthError(response.message ?? "Login failed. Check credentials."));
          }

      }

      // Local user exists



    } catch (e, stack) {
      debugPrint("Login Error: $e\n$stack");
      emit(AuthError(e.toString()));
    }
  }


}
