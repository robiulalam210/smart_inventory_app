// lib/feature/report/presentation/bloc/supplier_ledger_bloc/supplier_ledger_event.dart
part of 'supplier_ledger_bloc.dart';

@immutable
sealed class SupplierLedgerEvent {}

class FetchSupplierLedgerReport extends SupplierLedgerEvent {
  final BuildContext context;
  final DateTime? from;
  final DateTime? to;
  final int? supplierId;

  FetchSupplierLedgerReport({
    required this.context,
    this.from,
    this.to,
    this.supplierId,
  });
}

class ClearSupplierLedgerFilters extends SupplierLedgerEvent {}