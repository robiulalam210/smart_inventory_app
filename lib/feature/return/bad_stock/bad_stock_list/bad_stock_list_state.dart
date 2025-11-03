part of 'bad_stock_list_bloc.dart';

sealed class BadStockListState {}

final class BadStockListInitial extends BadStockListState {}
final class BadStockListLoading extends BadStockListState {}


final class BadStockListSuccess extends BadStockListState {
  final List<BadStockReturnModel> list;
  final int count;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final int from;
  final int to;

  BadStockListSuccess({
    required this.list,
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.from,
    required this.to,
  });
}
final class BadStockListFailed extends BadStockListState {
  final String title, content;

  BadStockListFailed({required this.title, required this.content});
}
