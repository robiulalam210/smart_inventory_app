part of 'account_bloc.dart';

sealed class AccountState {}

final class AccountInitial extends AccountState {}

final class AccountListLoading extends AccountState {}

final class AccountListSuccess extends AccountState {
  final List<AccountModel> list;
  final int count;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final int from;
  final int to;

  AccountListSuccess({
    required this.list,
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.from,
    required this.to,
  });
}


final class AccountListFailed extends AccountState {
  final String title, content;

  AccountListFailed({required this.title, required this.content});
}


final class AccountActiveListLoading extends AccountState {}

final class AccountActiveListSuccess extends AccountState {
  final List<AccountActiveModel> list;


  AccountActiveListSuccess({
    required this.list,

  });
}


final class AccountActiveListFailed extends AccountState {
  final String title, content;

  AccountActiveListFailed({required this.title, required this.content});
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