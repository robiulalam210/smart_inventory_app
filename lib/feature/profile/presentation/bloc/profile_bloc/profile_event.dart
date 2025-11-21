part of 'profile_bloc.dart';


@immutable
abstract class ProfileEvent {}

class FetchProfilePermission extends ProfileEvent {
  final BuildContext context;

  FetchProfilePermission({required this.context});
}

class FetchUserProfile extends ProfileEvent {
  final BuildContext context;

  FetchUserProfile({required this.context});
}

class UpdateUserProfile extends ProfileEvent {
  final Map<String, dynamic> profileData;
  final BuildContext context;

  UpdateUserProfile({required this.profileData, required this.context});
}

class ChangePassword extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  final BuildContext context;

  ChangePassword({
    required this.currentPassword,
    required this.newPassword,
    required this.context,
  });
}