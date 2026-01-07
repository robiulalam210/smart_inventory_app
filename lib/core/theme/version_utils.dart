import 'dart:io';
import '../../feature/splash/data/models/version_response_model.dart';

String? getPlatformVersion(VersionResponseModel appVersionModel) {
    if (Platform.isAndroid) {

      return appVersionModel.data?.playStoreVersion?.split("+").first.trim();
    } else if (Platform.isIOS) {
      return appVersionModel.data?.appStoreVersion?.split("+").first.trim();
    } else {
      return null;
    }
  }

  bool? getIsPause(VersionResponseModel appVersionModel) {
    if (Platform.isAndroid) {
      return appVersionModel.data?.isPausePlayStore;
    } else if (Platform.isIOS) {
      return appVersionModel.data?.isPauseAppStore;
    } else {
      return null;
    }
  }

  bool? getForceUpdate(VersionResponseModel appVersionModel) {
    if (Platform.isAndroid) {
      return appVersionModel.data?.forceUpdatePlayStore;
    } else if (Platform.isIOS) {
      return appVersionModel.data?.forceUpdateAppStore;
    } else {
      return null;
    }
  }