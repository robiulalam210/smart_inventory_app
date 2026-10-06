import '../../../../core/core.dart';

import '../../../splash/presentation/bloc/connectivity_bloc/connectivity_bloc.dart';
import '../../../splash/presentation/bloc/connectivity_bloc/connectivity_state.dart';
import '../../data/models/login_mod.dart';
import '../../data/repositories/auth_service.dart';
import '../../data/repositories/login_ser.dart';
import '../../../../core/offline/offline_auth.dart';
import '../../../../core/offline/offline_config.dart';
import 'auth_event.dart';
import 'auth_state.dart';
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ConnectivityBloc connectivityBloc;
  final AuthService authService;

  AuthBloc({required this.connectivityBloc, required this.authService})
      : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
      LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    final connectivityState = connectivityBloc.state;

    try {
      // Check internet connectivity
      if (connectivityState is ConnectivityOffline) {
        // Desktop: আগে এই কম্পিউটারে online login করা থাকলে offline login
        if (OfflineConfig.enabled) {
          final cached = await OfflineAuth.verify(event.username.trim(), event.password);
          if (cached != null) {
            emit(AuthAuthenticated(cached));
            return;
          }
          emit(AuthError("Offline login হয়নি: এই কম্পিউটারে আগে online এ login করা নেই, অথবা password মেলেনি।"));
          return;
        }
        emit(AuthError("No internet connection. Please try again later."));
        return;
      }

      // Determine if the input is email or username
      final String loginIdentifier = event.username.trim();
      final bool isEmail = loginIdentifier.contains('@');

      // Create payload based on input type
      final Map<String, dynamic> payload = {
        "password": event.password,
      };

      // Add either email or username to payload based on input
      if (isEmail) {
        payload["email"] = loginIdentifier;
      } else {
        payload["username"] = loginIdentifier;
      }

      final response = await loginService(payload: payload);

      print("object${response.success}");
      print("object${response.message}");
      print("object${response.message}");
      if (response.success == true && response.user != null) {
        // Validate company status with complete data
        final validationResult = _validateCompany(response);
        if (!validationResult.isValid) {
          emit(AuthError(validationResult.errorMessage));
          return;
        }

        // Save user locally and emit success
        await authService.saveUserLocally(event.password, response);
        await OfflineAuth.remember(event.username.trim(), event.password, response);
        emit(AuthAuthenticated(response));
      } else if (OfflineConfig.enabled &&
          (response.message ?? '').toLowerCase().contains(RegExp('connect|timed out'))) {
        // Wi-Fi আছে কিন্তু server পাওয়া যাচ্ছে না
        final cached = await OfflineAuth.verify(event.username.trim(), event.password);
        if (cached != null) {
          emit(AuthAuthenticated(cached));
        } else {
          emit(AuthError(response.message ?? "Cannot connect to server"));
        }
      } else {
        emit(AuthError(response.message ?? "Login failed. Check credentials."));
      }
    } catch (e, stack) {
      debugPrint("Login Error: $e\n$stack");
      emit(AuthError("Login failed. Please try again."));
    }
  }

  CompanyValidationResult _validateCompany(LoginModel user) {
    final company = user.company;

    // If no company data, allow login (some users might not have company)
    if (company == null) {
      return CompanyValidationResult(isValid: true);
    }

    // Check if company is active
    if (company.isActive == false) {
      return CompanyValidationResult(
        isValid: false,
        errorMessage: "Your company account is inactive. Please contact support.",
      );
    }

    // Check expiry date if available
    if (company.expiryDate != null ) {
      try {
        final expiryDate = DateTime.parse(company.expiryDate.toString());
        final currentDate = DateTime.now();

        // Add one day to expiry date to include the entire day
        final expiryEndOfDay = DateTime(expiryDate.year, expiryDate.month, expiryDate.day, 23, 59, 59);

        if (currentDate.isAfter(expiryEndOfDay)) {
          final formattedDate = "${expiryDate.day}/${expiryDate.month}/${expiryDate.year}";
          return CompanyValidationResult(
            isValid: false,
            errorMessage: "Your company subscription expired on $formattedDate. Please contact support.",
          );
        }
      } catch (e) {
        debugPrint("Error parsing expiry date: $e");
        // If date parsing fails, continue with login
      }
    }

    return CompanyValidationResult(isValid: true);
  }
}

class CompanyValidationResult {
  final bool isValid;
  final String errorMessage;

  CompanyValidationResult({
    required this.isValid,
    this.errorMessage = '',
  });
}