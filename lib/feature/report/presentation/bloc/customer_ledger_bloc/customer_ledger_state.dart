// lib/feature/report/presentation/bloc/customer_ledger_bloc/customer_ledger_state.dart
part of 'customer_ledger_bloc.dart';

@immutable
sealed class CustomerLedgerState {}

final class CustomerLedgerInitial extends CustomerLedgerState {}

final class CustomerLedgerLoading extends CustomerLedgerState {}

final class CustomerLedgerSuccess extends CustomerLedgerState {
  final CustomerLedgerResponse response;

  CustomerLedgerSuccess({required this.response});
}

final class CustomerLedgerFailed extends CustomerLedgerState {
  final String title, content;

  CustomerLedgerFailed({required this.title, required this.content});
}