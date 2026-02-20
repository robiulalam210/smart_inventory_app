part of 'income_bloc.dart';

@immutable
sealed class IncomeState {}


class IncomeInitial extends IncomeState {}

class IncomeListLoading extends IncomeState {}

class IncomeListSuccess extends IncomeState {
  final List<IncomeModel> list;
  final int totalPages;
  final int currentPage;
  final int count;
  final int pageSize;
  final int from;
  final int to;

  IncomeListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
    required this.count,
    required this.pageSize,
    required this.from,
    required this.to,
  });
}

class IncomeListFailed extends IncomeState {
  final String title;
  final String content;
  IncomeListFailed({this.title = '', required this.content});
}

class IncomeAddLoading extends IncomeState {}

class IncomeAddSuccess extends IncomeState {}

class IncomeAddFailed extends IncomeState {
  final String title;
  final String content;
  IncomeAddFailed({this.title = '', required this.content});
}

class IncomeDeleteLoading extends IncomeState {}

class IncomeDeleteSuccess extends IncomeState {}

class IncomeDeleteFailed extends IncomeState {
  final String title;
  final String content;
  IncomeDeleteFailed({this.title = '', required this.content});
}