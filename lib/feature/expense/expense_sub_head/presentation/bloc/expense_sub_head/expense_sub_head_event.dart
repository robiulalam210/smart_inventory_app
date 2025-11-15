part of 'expense_sub_head_bloc.dart';

sealed class ExpenseSubHeadEvent {}

class FetchSubExpenseHeadList extends ExpenseSubHeadEvent {
  BuildContext context;

  final String filterText;
  final int pageNumber;

  FetchSubExpenseHeadList(
      this.context, {
        this.filterText = '',
        this.pageNumber = 0,
      });
}

class AddSubExpenseHead extends ExpenseSubHeadEvent {
  final Map<String, dynamic>? body;

  AddSubExpenseHead({this.body});
}

class UpdateSubExpenseHead extends ExpenseSubHeadEvent {
  final Map<String, dynamic>? body;
  final String? id;

  UpdateSubExpenseHead({this.body, this.id});
}

class DeleteSubExpenseHead extends ExpenseSubHeadEvent {
  final String id;

  DeleteSubExpenseHead({this.id = ""});
}
