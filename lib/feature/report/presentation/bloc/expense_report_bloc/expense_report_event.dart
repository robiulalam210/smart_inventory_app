// lib/feature/report/presentation/bloc/expense_report_bloc/expense_report_event.dart
part of 'expense_report_bloc.dart';

@immutable
sealed class ExpenseReportEvent {}

class FetchExpenseReport extends ExpenseReportEvent {
  final BuildContext context;
  final DateTime? from;
  final DateTime? to;
  final String? head;
  final String? subHead;
  final String? paymentMethod;

  FetchExpenseReport({
    required this.context,
    this.from,
    this.to,
    this.head,
    this.subHead,
    this.paymentMethod,
  });
}

class ClearExpenseReportFilters extends ExpenseReportEvent {}