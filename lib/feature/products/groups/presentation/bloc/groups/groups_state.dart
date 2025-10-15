part of 'groups_bloc.dart';

sealed class GroupsState {}

final class GroupsInitial extends GroupsState {}




final class GroupsListLoading extends GroupsState {}

final class GroupsListSuccess extends GroupsState {
  String selectedState = "";

  final List<GroupsModel> list;
  final int totalPages;
  final int currentPage;

  GroupsListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
  });
}
final class GroupsListFailed extends GroupsState {
  final String title, content;

  GroupsListFailed({required this.title, required this.content});
}



final class GroupsAddInitial extends GroupsState {}

final class GroupsAddLoading extends GroupsState {}

final class GroupsAddSuccess extends GroupsState {
  GroupsAddSuccess();
}



final class GroupsAddFailed extends GroupsState {
  final String title, content;

  GroupsAddFailed({required this.title, required this.content});
}



final class GroupsSwitchInitial extends GroupsState {}

final class GroupsSwitchLoading extends GroupsState {}

final class GroupsSwitchSuccess extends GroupsState {
  GroupsSwitchSuccess();
}



final class GroupSwitchFailed extends GroupsState {
  final String title, content;

  GroupSwitchFailed({required this.title, required this.content});
}
