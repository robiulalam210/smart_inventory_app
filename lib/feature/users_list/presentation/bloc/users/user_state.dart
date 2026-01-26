part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

// Existing states
class UserListLoading extends UserState {}

class UserListSuccess extends UserState {
  final List<UsersListModel> list;
  final int totalPages;
  final int currentPage;

  const UserListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  List<Object> get props => [list, totalPages, currentPage];
}

class UserListFailed extends UserState {
  final String title;
  final String content;

  const UserListFailed({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}

class UserAddLoading extends UserState {}

class UserAddSuccess extends UserState {}

class UserAddFailed extends UserState {
  final String title;
  final String content;

  const UserAddFailed({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}

class UserSwitchLoading extends UserState {}

class UserSwitchSuccess extends UserState {}

class UserSwitchFailed extends UserState {
  final String title;
  final String content;

  const UserSwitchFailed({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}

// New Permission States
class UserPermissionsLoading extends UserState {}

class UserPermissionsSuccess extends UserState {
  final Map<String, dynamic> permissions;
  final List<UserPermissionModel> customPermissions;
  final UserModel user;

  const UserPermissionsSuccess({
    required this.permissions,
    required this.customPermissions,
    required this.user,
  });

  @override
  List<Object> get props => [permissions, customPermissions, user];
}

class UserPermissionsFailed extends UserState {
  final String title;
  final String content;

  const UserPermissionsFailed({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}

class PermissionUpdateLoading extends UserState {}

class PermissionUpdateSuccess extends UserState {
  final UserModel user;

  const PermissionUpdateSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class PermissionUpdateFailed extends UserState {
  final String title;
  final String content;

  const PermissionUpdateFailed({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}

class PermissionResetLoading extends UserState {}

class PermissionResetSuccess extends UserState {
  final UserModel user;

  const PermissionResetSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class PermissionResetFailed extends UserState {
  final String title;
  final String content;

  const PermissionResetFailed({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}

class PermissionCheckSuccess extends UserState {
  final bool hasPermission;

  const PermissionCheckSuccess({required this.hasPermission});

  @override
  List<Object> get props => [hasPermission];
}

class PermissionCheckFailed extends UserState {
  final String title;
  final String content;

  const PermissionCheckFailed({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}