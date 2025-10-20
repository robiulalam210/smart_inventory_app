part of 'account_bloc.dart';

sealed class AccountEvent {}




class FetchAccountList extends AccountEvent{
  BuildContext context;

  final String filterText;
  final String filterApiURL;
  final String accountType;
  final int pageNumber;

  FetchAccountList(

      this.context,
      {this.filterText = ''
    ,
    this.accountType='',
    this.filterApiURL='',
    this.pageNumber = 0});

}



class AddAccount extends AccountEvent {
  final Map<String,dynamic>? body;

  AddAccount({this.body});
}

class UpdateAccount extends AccountEvent {
  final Map<String,String>? body;
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