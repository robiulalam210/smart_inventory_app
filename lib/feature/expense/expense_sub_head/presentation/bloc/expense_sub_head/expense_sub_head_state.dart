part of 'expense_sub_head_bloc.dart';

@immutable
sealed class ExpenseSubHeadState {}

final class ExpenseSubHeadInitial extends ExpenseSubHeadState {}


final class ExpenseSubHeadListLoading extends ExpenseSubHeadState {}

final class ExpenseSubHeadListSuccess extends ExpenseSubHeadState {

  final List<ExpenseSubHeadModel> list;
  final int totalPages;
  final int currentPage;

  ExpenseSubHeadListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
  });
}


final class ExpenseSubHeadListFailed extends ExpenseSubHeadState {
  final String title, content;

  ExpenseSubHeadListFailed({required this.title, required this.content});
}


final class ExpenseSubHeadAddLoading extends ExpenseSubHeadState {}

final class ExpenseSubHeadAddSuccess extends ExpenseSubHeadState {
  ExpenseSubHeadAddSuccess();
}



final class ExpenseSubHeadAddFailed extends ExpenseSubHeadState {
  final String title, content;

  ExpenseSubHeadAddFailed({required this.title, required this.content});
}
