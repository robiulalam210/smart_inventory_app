part of 'user_bloc.dart';

// @immutable
sealed class UserEvent {}




class FetchUserList extends UserEvent {
  BuildContext context;

  final String filterText;
  final String dropdownFilter;
  final String location;

  final int pageNumber;

  FetchUserList(
      this.context,
      {this.filterText = '',
    this.dropdownFilter='',
    this.location='',
    this.pageNumber = 0});
}

class AddUser extends UserEvent {
  final Map<String, String>? body;

  String? photoPath;
  String? id;


  AddUser({this.body,this.photoPath});
}

class UpdateUser extends UserEvent {
  final Map<String, dynamic>? body;String? photoPath;String? id;


  UpdateUser({this.body,this.photoPath,this.id=""});
}

class UpdateSwitchUser extends UserEvent {
  final Map<String, String>? branch;
  final String? branchId;

  UpdateSwitchUser({this.branch, this.branchId});
}
class DeleteUser  extends UserEvent {
  final String id;

  DeleteUser({this.id=""});
}



