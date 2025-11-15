part of 'expense_bloc.dart';

sealed class ExpenseEvent {}


// In expense_event.dart

class FetchExpenseList extends ExpenseEvent {
  final BuildContext context;
  final int pageNumber;
  final int pageSize;
  final String filterText;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? headId;
  final String? subHeadId; // Add this missing field

  FetchExpenseList(
      this.context, {
        this.pageNumber = 1,
        this.pageSize = 10,
        this.filterText = "",
        this.startDate,
        this.endDate,
        this.headId,
        this.subHeadId, // Add this parameter
      });

  List<Object?> get props => [
    context,
    pageNumber,
    pageSize,
    filterText,
    startDate,
    endDate,
    headId,
    subHeadId, // Add to props
  ];
}


class AddExpense extends ExpenseEvent {
  final Map<String,dynamic>? body;

  AddExpense({this.body});
}

class UpdateExpense extends ExpenseEvent {
  final Map<String,dynamic>? body;
  final String? id;


  UpdateExpense({this.body,this.id});
}

class DeleteExpense  extends ExpenseEvent {
  final String id;

  DeleteExpense({this.id=""});
}

