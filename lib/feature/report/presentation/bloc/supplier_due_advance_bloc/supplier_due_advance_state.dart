// lib/feature/report/presentation/bloc/supplier_due_advance_bloc/supplier_due_advance_state.dart
part of 'supplier_due_advance_bloc.dart';

@immutable
sealed class SupplierDueAdvanceState {}

final class SupplierDueAdvanceInitial extends SupplierDueAdvanceState {}

final class SupplierDueAdvanceLoading extends SupplierDueAdvanceState {}

final class SupplierDueAdvanceSuccess extends SupplierDueAdvanceState {
  final SupplierDueAdvanceResponse response;

  SupplierDueAdvanceSuccess({required this.response});
}

final class SupplierDueAdvanceFailed extends SupplierDueAdvanceState {
  final String title, content;

  SupplierDueAdvanceFailed({required this.title, required this.content});
}