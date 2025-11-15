part of 'groups_bloc.dart';

sealed class GroupsEvent {}

class FetchGroupsList extends GroupsEvent {
  BuildContext context;

  final String filterText;
  final String state;
  final int pageNumber;

  FetchGroupsList(this.context,{this.filterText = '', this.state = '', this.pageNumber = 0});
}

class AddGroups extends GroupsEvent {
  final Map<String, dynamic>? body;

  AddGroups({this.body});
}

class UpdateGroups extends GroupsEvent {
  final Map<String, dynamic>? body;
  final String? id;

  UpdateGroups({this.body, this.id});
}

class UpdateSwitchGroups extends GroupsEvent {
  final Map<String, String>? body;
  final String? id;

  UpdateSwitchGroups({this.body, this.id});
}

class DeleteGroups extends GroupsEvent {
  final String id;

  DeleteGroups(this.id);
}
