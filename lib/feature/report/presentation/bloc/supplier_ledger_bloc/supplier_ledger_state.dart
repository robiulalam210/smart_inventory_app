// lib/feature/report/presentation/bloc/supplier_ledger_bloc/supplier_ledger_state.dart
part of 'supplier_ledger_bloc.dart';

@immutable
sealed class SupplierLedgerState {}

final class SupplierLedgerInitial extends SupplierLedgerState {}

final class SupplierLedgerLoading extends SupplierLedgerState {}

final class SupplierLedgerSuccess extends SupplierLedgerState {
  final SupplierLedgerResponse response;

  SupplierLedgerSuccess({required this.response});
}

final class SupplierLedgerFailed extends SupplierLedgerState {
  final String title, content;

  SupplierLedgerFailed({required this.title, required this.content});
}