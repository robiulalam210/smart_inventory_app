part of 'income_bloc.dart';

@immutable
sealed class IncomeEvent {}

class FetchIncomeList extends IncomeEvent {
  final BuildContext context;
  final String filterText;
  final DateTime? startDate;
  final DateTime? endDate;
  final int pageNumber;
  final int pageSize;
  final String? headId;
  final String? accountId;

  FetchIncomeList({
    required this.context,
    this.filterText = '',
    this.startDate,
    this.endDate,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.headId,
    this.accountId,
  });
}

class AddIncome extends IncomeEvent {
  final Map<String, dynamic> body;
  AddIncome({required this.body});
}

class UpdateIncome extends IncomeEvent {
  final int id;
  final Map<String, dynamic>? body;
  UpdateIncome({required this.id, this.body});
}

class DeleteIncome extends IncomeEvent {
  final String id;
  DeleteIncome({required this.id});
}