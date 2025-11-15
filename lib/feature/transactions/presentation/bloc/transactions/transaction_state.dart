part of 'transaction_bloc.dart';

@immutable
sealed class TransactionState {}

final class TransactionInitial extends TransactionState {}

final class TransactionListLoading extends TransactionState {}
class TransactionListSuccess extends TransactionState {
  final List<TransactionsModel> list;
  final int count;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final int from;
  final int to;

   TransactionListSuccess({
    required this.list,
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.from,
    required this.to,
  });

  List<Object> get props => [
    list,
    count,
    totalPages,
    currentPage,
    pageSize,
    from,
    to,
  ];
}


final class TransactionListFailed extends TransactionState {
  final String title, content;

  TransactionListFailed({required this.title, required this.content});
}
