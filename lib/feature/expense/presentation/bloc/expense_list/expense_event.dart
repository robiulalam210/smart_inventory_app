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

  FetchExpenseList(
      this.context, {
        this.pageNumber = 1, // Change to 1-based for API
        this.pageSize = 10,
        this.filterText = "",
        this.startDate,
        this.endDate,
        this.headId,
      });
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

