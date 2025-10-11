import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/database/login.dart';
import '../../../../feature.dart';


part 'splash_event.dart';
part 'splash_state.dart';

// BLoC
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthBloc authBloc;

  SplashBloc({required this.authBloc}) : super(SplashInitial()) {
    on<GetLoginData>(_onGetLoginData);
    on<ToggleVisibilityEvent>(_onToggleVisibility);
  }

  Future<void> _onGetLoginData(GetLoginData event, Emitter<SplashState> emit) async {
    emit(SplashLoading());
    final token = await LocalDB.getLoginInfo();

    await Future.delayed(Duration(seconds: 1));


    if (token?['token'] == null) {
      // No token, navigate to Login
      emit(SplashNavigateToLogin());
    } else {
      // Token exists, navigate to Home
      emit(SplashNavigateToHome());
    }
  }

  void _onToggleVisibility(ToggleVisibilityEvent event, Emitter<SplashState> emit) {
    emit(VisibilityChanged(false));
  }
}
