part of 'profile_bloc.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

// Permission States
class ProfilePermissionLoading extends ProfileState {}
class ProfilePermissionSuccess extends ProfileState {
  final ProfilePermissionModel permissionData;

  ProfilePermissionSuccess({required this.permissionData});
}
class ProfilePermissionFailed extends ProfileState {
  final String title;
  final String content;

  ProfilePermissionFailed({required this.title, required this.content});
}

// Profile States
class ProfileLoading extends ProfileState {}
class ProfileSuccess extends ProfileState {
  final UserProfileModel profileData;

  ProfileSuccess({required this.profileData});
}
class ProfileFailed extends ProfileState {
  final String title;
  final String content;

  ProfileFailed({required this.title, required this.content});
}

class ProfileUpdating extends ProfileState {}
class ProfileUpdateSuccess extends ProfileState {
  final UserProfileModel profileData;

  ProfileUpdateSuccess({required this.profileData});
}
class ProfileUpdateFailed extends ProfileState {
  final String title;
  final String content;

  ProfileUpdateFailed({required this.title, required this.content});
}

class PasswordChanging extends ProfileState {}
class PasswordChangeSuccess extends ProfileState {}
class PasswordChangeFailed extends ProfileState {
  final String title;
  final String content;

  PasswordChangeFailed({required this.title, required this.content});
}