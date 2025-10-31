// lib/feature/report/presentation/bloc/customer_ledger_bloc/customer_ledger_event.dart
part of 'customer_ledger_bloc.dart';

@immutable
sealed class CustomerLedgerEvent {}

class FetchCustomerLedger extends CustomerLedgerEvent {
  final BuildContext context;
  final String? customer;
  final DateTime? from;
  final DateTime? to;

  FetchCustomerLedger({
    required this.context,
    this.customer,
    this.from,
    this.to,
  });
}

class ClearCustomerLedgerFilters extends CustomerLedgerEvent {}