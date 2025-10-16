part of 'expense_head_bloc.dart';

sealed class ExpenseHeadEvent {}

class FetchExpenseHeadList extends ExpenseHeadEvent{
  BuildContext context;

  final String filterText;
  final int pageNumber;

  FetchExpenseHeadList(this.context,{this.filterText = '',this.pageNumber = 0});

}



class AddExpenseHead extends ExpenseHeadEvent {
  final Map<String,String>? body;

  AddExpenseHead({this.body});
}

class UpdateExpenseHead extends ExpenseHeadEvent {
  final Map<String,String>? body;
  final String? id;


  UpdateExpenseHead({this.body,this.id});
}

class DeleteExpenseHead  extends ExpenseHeadEvent {
  final String id;

  DeleteExpenseHead({this.id=""});
}
