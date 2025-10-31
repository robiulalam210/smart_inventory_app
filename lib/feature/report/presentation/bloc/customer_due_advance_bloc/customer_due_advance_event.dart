// lib/feature/report/presentation/bloc/customer_due_advance_bloc/customer_due_advance_event.dart
part of 'customer_due_advance_bloc.dart';

@immutable
sealed class CustomerDueAdvanceEvent {}

class FetchCustomerDueAdvanceReport extends CustomerDueAdvanceEvent {
  final BuildContext context;
  final DateTime? from;
  final DateTime? to;
  final int? customerId;
  final String? status;

  FetchCustomerDueAdvanceReport({
    required this.context,
    this.from,
    this.to,
    this.customerId,
    this.status,
  });
}

class ClearCustomerDueAdvanceFilters extends CustomerDueAdvanceEvent {}