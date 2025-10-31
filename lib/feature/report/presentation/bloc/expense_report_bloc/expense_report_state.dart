// lib/feature/report/presentation/bloc/expense_report_bloc/expense_report_state.dart
part of 'expense_report_bloc.dart';

@immutable
sealed class ExpenseReportState {}

final class ExpenseReportInitial extends ExpenseReportState {}

final class ExpenseReportLoading extends ExpenseReportState {}

final class ExpenseReportSuccess extends ExpenseReportState {
  final ExpenseReportResponse response;

  ExpenseReportSuccess({required this.response});
}

final class ExpenseReportFailed extends ExpenseReportState {
  final String title, content;

  ExpenseReportFailed({required this.title, required this.content});
}