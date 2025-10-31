// lib/feature/report/presentation/bloc/customer_due_advance_bloc/customer_due_advance_state.dart
part of 'customer_due_advance_bloc.dart';

@immutable
sealed class CustomerDueAdvanceState {}

final class CustomerDueAdvanceInitial extends CustomerDueAdvanceState {}

final class CustomerDueAdvanceLoading extends CustomerDueAdvanceState {}

final class CustomerDueAdvanceSuccess extends CustomerDueAdvanceState {
  final CustomerDueAdvanceResponse response;

  CustomerDueAdvanceSuccess({required this.response});
}

final class CustomerDueAdvanceFailed extends CustomerDueAdvanceState {
  final String title, content;

  CustomerDueAdvanceFailed({required this.title, required this.content});
}