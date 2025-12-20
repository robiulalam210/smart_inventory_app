// lib/account_transfer/presentation/bloc/account_transfer/account_transfer_event.dart
part of 'account_transfer_bloc.dart';

@immutable
abstract class AccountTransferEvent {}

class FetchAccountTransferList extends AccountTransferEvent {
  final BuildContext context;
  final String? fromAccountId;
  final String? toAccountId;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? transferType;
  final bool? isReversal;
  final int pageNumber;
  final int pageSize;

  FetchAccountTransferList({
    required this.context,
    this.fromAccountId,
    this.toAccountId,
    this.status,
    this.startDate,
    this.endDate,
    this.transferType,
    this.isReversal,
    this.pageNumber = 1,
    this.pageSize = 10,
  });
}

class FetchAvailableAccounts extends AccountTransferEvent {
  final BuildContext context;

  FetchAvailableAccounts({required this.context});
}

class CreateAccountTransfer extends AccountTransferEvent {
  final BuildContext context;
  final Map<String, dynamic> body;

  CreateAccountTransfer({required this.context, required this.body});
}

class ExecuteTransfer extends AccountTransferEvent {
  final BuildContext context;
  final String transferId;

  ExecuteTransfer({required this.context, required this.transferId});
}

class ReverseTransfer extends AccountTransferEvent {
  final BuildContext context;
  final int transferId;
  final String? reason;

  ReverseTransfer({
    required this.context,
    required this.transferId,
    this.reason,
  });
}

class CancelTransfer extends AccountTransferEvent {
  final BuildContext context;
  final int transferId;
  final String? reason;

  CancelTransfer({
    required this.context,
    required this.transferId,
    this.reason,
  });
}

class QuickTransfer extends AccountTransferEvent {
  final BuildContext context;
  final Map<String, dynamic> body;

  QuickTransfer({required this.context, required this.body});
}

class ResetForm extends AccountTransferEvent {}

class LoadMoreTransfers extends AccountTransferEvent {
  final BuildContext context;
  final int pageSize;

  LoadMoreTransfers({required this.context, this.pageSize = 10});
}