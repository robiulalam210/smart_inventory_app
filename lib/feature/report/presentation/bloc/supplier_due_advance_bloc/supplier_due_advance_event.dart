// lib/feature/report/presentation/bloc/supplier_due_advance_bloc/supplier_due_advance_event.dart
part of 'supplier_due_advance_bloc.dart';

@immutable
sealed class SupplierDueAdvanceEvent {}

class FetchSupplierDueAdvanceReport extends SupplierDueAdvanceEvent {
  final BuildContext context;
  final DateTime? from;
  final DateTime? to;

  FetchSupplierDueAdvanceReport({
    required this.context,
    this.from,
    this.to,
  });
}

class ClearSupplierDueAdvanceFilters extends SupplierDueAdvanceEvent {}