part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

// Existing events
class FetchUserList extends UserEvent {
  final BuildContext context;
  final String filterText;
  final int pageNumber;
  final String dropdownFilter;

  const FetchUserList(
      this.context, {
        this.filterText = '',
        this.pageNumber = 0,
        this.dropdownFilter = '',
      });

  @override
  List<Object> get props => [context, filterText, pageNumber, dropdownFilter];
}

class UserAdd extends UserEvent {
  final BuildContext context;
  final Map<String, dynamic> data;

  const UserAdd(this.context, this.data);

  @override
  List<Object> get props => [context, data];
}

class UserSwitch extends UserEvent {
  final BuildContext context;
  final int userId;
  final bool status;

  const UserSwitch(this.context, this.userId, this.status);

  @override
  List<Object> get props => [context, userId, status];
}

// New Permission Events
class FetchUserPermissions extends UserEvent {
  final BuildContext context;
  final String userId;

  const FetchUserPermissions(this.context, this.userId);

  @override
  List<Object> get props => [context, userId];
}

class UpdateUserPermissions extends UserEvent {
  final BuildContext context;
  final String userId;
  final Map<String, PermissionActionUser> permissions;

  const UpdateUserPermissions(
      this.context,
      this.userId,
      this.permissions,
      );

  @override
  List<Object> get props => [context, userId, permissions];
}

class ResetUserPermissions extends UserEvent {
  final BuildContext context;
  final String userId;

  const ResetUserPermissions(this.context, this.userId);

  @override
  List<Object> get props => [context, userId];
}

class CheckPermission extends UserEvent {
  final BuildContext context;
  final String module;
  final String? action;

  const CheckPermission(this.context, this.module, {this.action});

  @override
  List<Object> get props => [context, module, action ?? ''];
}