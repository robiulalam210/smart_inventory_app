part of 'account_bloc.dart';

sealed class AccountState {}

final class AccountInitial extends AccountState {}

final class AccountListLoading extends AccountState {}

final class AccountListSuccess extends AccountState {
  String selectedState = "";

  final List<AccountModel> list;
  final int totalPages;
  final int currentPage;

  AccountListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
  });
}


final class AccountListFailed extends AccountState {
  final String title, content;

  AccountListFailed({required this.title, required this.content});
}


final class AccountAddInitial extends AccountState {}

final class AccountAddLoading extends AccountState {}

final class AccountAddSuccess extends AccountState {

  AccountAddSuccess();
}



final class AccountAddFailed extends AccountState {
  final String title, content;

  AccountAddFailed({required this.title, required this.content});
}




sealed class AccountDetailsState {}

final class AccountDetailsInitial extends AccountDetailsState {}

final class AccountDetailsLoading extends AccountDetailsState {}


final class AccountDetailsFailed extends AccountDetailsState {
  final String title, content;

  AccountDetailsFailed({required this.title, required this.content});
}