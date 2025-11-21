import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../../core/configs/app_urls.dart';
import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../../core/repositories/patch_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../data/model/profile_perrmission_model.dart';
import '../../../data/model/user_profile_model.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<FetchProfilePermission>(_onFetchProfilePermission);
    on<FetchUserProfile>(_onFetchUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<ChangePassword>(_onChangePassword);
  }
  Future<void> _onFetchProfilePermission(
      FetchProfilePermission event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfilePermissionLoading());

    try {
      final response = await getResponse(
        url: AppUrls.userProfile,
        context: event.context,
      );

      // Print the raw response to see the actual structure
      print("Raw API Response: $response");

      // Parse the JSON string to Map first
      final Map<String, dynamic> responseData = json.decode(response);

      // Comprehensive debugging of the response structure
      print("=== RESPONSE STRUCTURE DEBUG ===");
      print("Top-level keys: ${responseData.keys}");
      print("Status: ${responseData['status']}");
      print("Message: ${responseData['message']}");

      // Check the data field
      print("Data field exists: ${responseData.containsKey('data')}");
      print("Data field value: ${responseData['data']}");
      print("Data field type: ${responseData['data']?.runtimeType}");

      if (responseData['data'] != null && responseData['data'] is Map) {
        final data = responseData['data'] as Map<String, dynamic>;
        print("Data keys: ${data.keys}");

        // Check all possible user locations
        print("User in data: ${data['user']}");
        print("User field exists in data: ${data.containsKey('user')}");

        // Also check if user might be at root level
        print("User at root level: ${responseData['user']}");
        print("User exists at root: ${responseData.containsKey('user')}");

        // Print all fields in data to see what's available
        data.forEach((key, value) {
          print("Data field '$key': $value (type: ${value.runtimeType})");
        });
      }

      print("=== END DEBUG ===");

      // Now use the parsed map with ProfilePermissionModel.fromJson
      final ProfilePermissionModel permissionData = ProfilePermissionModel.fromJson(responseData);

      print("Response message: ${permissionData.message}");
      print("Response status: ${permissionData.status}");
      print("Permission data: ${permissionData.data}");
      print("Permission data user: ${permissionData.data?.user}");

      if (permissionData.status == true) {
        emit(ProfilePermissionSuccess(permissionData: permissionData));
      } else {
        emit(
          ProfilePermissionFailed(
            title: "Error",
            content: permissionData.message ?? "Failed to load permissions",
          ),
        );
      }
    } catch (error) {
      print("Error in _onFetchProfilePermission: $error");
      emit(ProfilePermissionFailed(
          title: "Error",
          content: error.toString()
      ));
    }
  }



  Future<void> _onFetchUserProfile(
      FetchUserProfile event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileLoading());

    try {
      final res = await getResponse(
        url: AppUrls.userProfile,
        context: event.context,
      );

      ApiResponse response = appParseJson(
        res,
            (data) => UserProfileModel.fromJson(data),
      );

      if (response.success == true) {
        final UserProfileModel profileData = response.data;
        emit(ProfileSuccess(profileData: profileData));
      } else {
        emit(
          ProfileFailed(
            title: "Error",
            content: response.message ?? "Failed to load profile",
          ),
        );
      }
    } catch (error) {
      emit(ProfileFailed(
          title: "Error",
          content: error.toString()
      ));
    }
  }

  Future<void> _onUpdateUserProfile(
      UpdateUserProfile event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileUpdating());

    try {
      final res = await patchResponse(
        url: AppUrls.userProfile,
        payload: event.profileData,
      );
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => UserProfileModel.fromJson(data),
      );

      if (response.success == true) {
        final UserProfileModel profileData = response.data;
        emit(ProfileUpdateSuccess(profileData: profileData));
      } else {
        emit(
          ProfileUpdateFailed(
            title: "Update Failed",
            content: response.message ?? "Failed to update profile",
          ),
        );
      }
    } catch (error) {
      emit(ProfileUpdateFailed(
          title: "Update Failed",
          content: error.toString()
      ));
    }
  }

  Future<void> _onChangePassword(
      ChangePassword event,
      Emitter<ProfileState> emit,
      ) async {
    emit(PasswordChanging());

    try {
      final res = await patchResponse(
        url: AppUrls.changePassword,
        payload: {
          'current_password': event.currentPassword,
          'new_password': event.newPassword,
        },
      );
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(jsonString, (data) => data);

      if (response.success == true) {
        emit(PasswordChangeSuccess());
      } else {
        emit(
          PasswordChangeFailed(
            title: "Password Change Failed",
            content: response.message ?? "Failed to change password",
          ),
        );
      }
    } catch (error) {
      emit(PasswordChangeFailed(
          title: "Password Change Failed",
          content: error.toString()
      ));
    }
  }
}