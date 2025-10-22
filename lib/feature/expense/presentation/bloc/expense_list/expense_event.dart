part of 'expense_bloc.dart';

sealed class ExpenseEvent {}


class FetchExpenseList extends ExpenseEvent{
  BuildContext context;

  final String filterText;
  final String filterApiURL;
  final DateTime? startDate;
  final DateTime? endDate;
  final int pageNumber;

  FetchExpenseList(this.context,{this.filterText = '',this.filterApiURL='',this.startDate,this.endDate, this.pageNumber = 0});

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

