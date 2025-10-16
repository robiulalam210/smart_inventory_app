part of 'expense_bloc.dart';

// @immutable
sealed class ExpenseState {}

final class ExpenseInitial extends ExpenseState {}


final class ExpenseListLoading extends ExpenseState {}

final class ExpenseListSuccess extends ExpenseState {
  String selectedState = "";

  final List<ExpenseModel> list;
  final int totalPages;
  final int currentPage;

  ExpenseListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
  });
}


final class ExpenseListFailed extends ExpenseState {
  final String title, content;

  ExpenseListFailed({required this.title, required this.content});
}




final class ExpenseAddInitial extends ExpenseState {}

final class ExpenseAddLoading extends ExpenseState {}

final class ExpenseAddSuccess extends ExpenseState {
  ExpenseAddSuccess();
}



final class ExpenseAddFailed extends ExpenseState {
  final String title, content;

  ExpenseAddFailed({required this.title, required this.content});
}

