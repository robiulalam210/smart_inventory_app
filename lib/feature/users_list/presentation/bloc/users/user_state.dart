part of 'user_bloc.dart';

sealed class UserState {}

final class UserInitial extends UserState {}




final class UserListLoading extends UserState {}

final class UserListSuccess extends UserState {
  String selectedState = "";

  final List<UsersListModel> list;
  final int totalPages;
  final int currentPage;

  UserListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
  });
}


final class UserListFailed extends UserState {
  final String title, content;

  UserListFailed({required this.title, required this.content});
}


final class UserAddInitial extends UserState {}

final class UserAddLoading extends UserState {}

final class UserAddSuccess extends UserState {

  UserAddSuccess();
}



final class UserAddFailed extends UserState {
  final String title, content;

  UserAddFailed({required this.title, required this.content});
}



final class UserSwitchInitial extends UserState {}

final class UserSwitchLoading extends UserState {}

final class UserSwitchSuccess extends UserState {
  UserSwitchSuccess();
}



final class UserSwitchFailed extends UserState {
  final String title, content;

  UserSwitchFailed({required this.title, required this.content});
}
