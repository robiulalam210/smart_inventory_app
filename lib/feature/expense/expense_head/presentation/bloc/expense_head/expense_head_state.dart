part of 'expense_head_bloc.dart';

// @immutable
sealed class ExpenseHeadState {}

final class ExpenseHeadInitial extends ExpenseHeadState {}



final class ExpenseHeadListLoading extends ExpenseHeadState {}

final class ExpenseHeadListSuccess extends ExpenseHeadState {
  String selectedState = "";

  final List<ExpenseHeadModel> list;
  final int totalPages;
  final int currentPage;

  ExpenseHeadListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
  });
}


final class ExpenseHeadListFailed extends ExpenseHeadState {
  final String title, content;

  ExpenseHeadListFailed({required this.title, required this.content});
}




final class ExpenseHeadAddInitial extends ExpenseHeadState {}

final class ExpenseHeadAddLoading extends ExpenseHeadState {}

final class ExpenseHeadAddSuccess extends ExpenseHeadState {
  ExpenseHeadAddSuccess();
}



final class ExpenseHeadAddFailed extends ExpenseHeadState {
  final String title, content;

  ExpenseHeadAddFailed({required this.title, required this.content});
}


