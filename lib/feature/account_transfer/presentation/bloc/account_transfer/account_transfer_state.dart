// lib/account_transfer/presentation/bloc/account_transfer/account_transfer_state.dart
part of 'account_transfer_bloc.dart';

@immutable
abstract class AccountTransferState {}

class AccountTransferInitial extends AccountTransferState {}

class AccountTransferListLoading extends AccountTransferState {}
class AccountTransferListSuccess extends AccountTransferState {
  final List<AccountTransferModel> list;
  final int count;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final int from;
  final int to;

  AccountTransferListSuccess({
    required this.list,
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.from,
    required this.to,
  });
}
class AccountTransferListFailed extends AccountTransferState {
  final String title;
  final String content;

  AccountTransferListFailed({required this.title, required this.content});
}

class AvailableAccountsLoading extends AccountTransferState {}
class AvailableAccountsSuccess extends AccountTransferState {
  final List<AccountActiveModel> list;

  AvailableAccountsSuccess({required this.list});
}
class AvailableAccountsFailed extends AccountTransferState {
  final String title;
  final String content;

  AvailableAccountsFailed({required this.title, required this.content});
}

class AccountTransferAddLoading extends AccountTransferState {}
class AccountTransferAddSuccess extends AccountTransferState {}
class AccountTransferAddFailed extends AccountTransferState {
  final String title;
  final String content;

  AccountTransferAddFailed({required this.title, required this.content});
}

class ExecuteTransferLoading extends AccountTransferState {}
class ExecuteTransferSuccess extends AccountTransferState {}
class ExecuteTransferFailed extends AccountTransferState {
  final String title;
  final String content;

  ExecuteTransferFailed({required this.title, required this.content});
}

class QuickTransferLoading extends AccountTransferState {}
class QuickTransferSuccess extends AccountTransferState {
  final AccountTransferModel transfer;

  QuickTransferSuccess({required this.transfer});
}
class QuickTransferFailed extends AccountTransferState {
  final String title;
  final String content;

  QuickTransferFailed({required this.title, required this.content});
}

class ReverseTransferLoading extends AccountTransferState {}
class ReverseTransferSuccess extends AccountTransferState {}
class ReverseTransferFailed extends AccountTransferState {
  final String title;
  final String content;

  ReverseTransferFailed({required this.title, required this.content});
}

class CancelTransferLoading extends AccountTransferState {}
class CancelTransferSuccess extends AccountTransferState {}
class CancelTransferFailed extends AccountTransferState {
  final String title;
  final String content;

  CancelTransferFailed({required this.title, required this.content});
}

class AccountTransferFormReset extends AccountTransferState {}