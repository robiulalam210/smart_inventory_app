part of 'account_bloc.dart';

sealed class AccountEvent {}



class FetchAccountList extends AccountEvent {
  BuildContext context;
  final String filterText;
  final String filterApiURL;
  final String accountType;
  final int pageNumber;
  final int pageSize; // Add pageSize

  FetchAccountList(
      this.context, {
        this.filterText = '',
        this.accountType = '',
        this.filterApiURL = '',
        this.pageNumber = 1, // Change from 0 to 1
        this.pageSize = 10, // Add default page size
      });
}
class FetchAccountActiveList extends AccountEvent {
  BuildContext context;


  FetchAccountActiveList(
      this.context,);
}


class AddAccount extends AccountEvent {
  final Map<String,dynamic>? body;

  AddAccount({this.body});
}

class UpdateAccount extends AccountEvent {
  final Map<String,dynamic>? body;
  final String? id;


  UpdateAccount({this.body,this.id});
}

class DeleteAccount  extends AccountEvent {
  final String id;

  DeleteAccount(this.id);
}



sealed class AccountDetailsEvent {}

class AccountDetailsList extends AccountDetailsEvent{
  BuildContext context;

  final String staffId;

  AccountDetailsList(this.context,{required this.staffId});

}