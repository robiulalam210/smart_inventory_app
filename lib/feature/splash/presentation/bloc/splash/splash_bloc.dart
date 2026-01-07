import 'dart:io';
import '../../../../../core/configs/configs.dart';
import '../../../../../core/theme/version_utils.dart';
import '../../../data/datasource/version_remote_data_source.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<CheckAppVersionEvent>(_onCheckAppVersion);
    on<CheckLoginStatusEvent>(_onCheckLoginStatus);
  }

  /// STEP 1: Version / Maintenance Check (mobile)
  Future<void> _onCheckAppVersion(
      CheckAppVersionEvent event,
      Emitter<SplashState> emit,
      ) async {
    emit(SplashLoading());

    final result = await VersionRemoteDataSource.getVersion(event.context);

    result.fold(
          (failure) {
        emit(VersionFailure(failure.message));
      },
          (versionResponse) {
        final platformVersion = getPlatformVersion(versionResponse);

        final url = Platform.isIOS
            ? versionResponse.data?.appStoreLink?.trim()
            : versionResponse.data?.playStoreLink?.trim();

        if (getIsPause(versionResponse) == true) {
          emit(AppPausedState());
          return;
        }

        if (AppUrls.currentVersion != platformVersion) {
          if (getForceUpdate(versionResponse) == true) {
            emit(AppForceUpdateState(url: url ?? '', message: versionResponse.data?.updateMessage));
          } else {
            emit(UpdateAvailableState(url: url ?? '', message: versionResponse.data?.updateMessage));
          }
          return;
        }

        // App is up-to-date -> proceed to login check
        add(CheckLoginStatusEvent());
      },
    );
  }

  /// STEP 2: Login Check (both mobile & desktop flows eventually land here)
  Future<void> _onCheckLoginStatus(
      CheckLoginStatusEvent event,
      Emitter<SplashState> emit,
      ) async {
    emit(SplashLoading());

    // small delay so splash animation is visible
    await Future.delayed(const Duration(milliseconds: 800));

    final token = await LocalDB.getLoginInfo();

    if (token?['token'] == null) {
      emit(SplashNavigateToLogin());
    } else {
      emit(SplashNavigateToHome());
    }
  }
}