part of 'income_expense_head_bloc.dart';

@immutable
sealed class IncomeHeadState {}


class IncomeHeadInitial extends IncomeHeadState {}

// List Fetch States
class IncomeHeadListLoading extends IncomeHeadState {}

class IncomeHeadListSuccess extends IncomeHeadState {
  final List<IncomeHeadModel> list;
  final int totalPages;
  final int currentPage;

  IncomeHeadListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
  });
}

class IncomeHeadListFailed extends IncomeHeadState {
  final String title;
  final String content;

  IncomeHeadListFailed({required this.title, required this.content});
}

// Add, Update, Delete States
class IncomeHeadAddLoading extends IncomeHeadState {}

class IncomeHeadAddSuccess extends IncomeHeadState {}

class IncomeHeadAddFailed extends IncomeHeadState {
  final String title;
  final String content;

  IncomeHeadAddFailed({required this.title, required this.content});
}