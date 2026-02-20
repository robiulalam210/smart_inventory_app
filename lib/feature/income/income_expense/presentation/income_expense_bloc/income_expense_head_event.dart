part of 'income_expense_head_bloc.dart';

@immutable
sealed class IncomeHeadEvent {}

class FetchIncomeHeadList extends IncomeHeadEvent {
  final BuildContext context;
  final String filterText;
  final int pageNumber;

  FetchIncomeHeadList({required this.context, this.filterText = "", this.pageNumber = 0});
}

class AddIncomeHead extends IncomeHeadEvent {
  final Map<String, dynamic> body;

  AddIncomeHead({required this.body});
}

class UpdateIncomeHead extends IncomeHeadEvent {
  final int id;
  final Map<String, dynamic>? body;

  UpdateIncomeHead({required this.id, this.body});
}

class DeleteIncomeHead extends IncomeHeadEvent {
  final int id;

  DeleteIncomeHead({required this.id});
}