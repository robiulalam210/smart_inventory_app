part of 'possale_bloc.dart';

// @immutable
sealed class PosSaleState {}

final class PosSaleInitial extends PosSaleState {}

final class PosSaleListLoading extends PosSaleState {}

class PosSaleListSuccess extends PosSaleState {
  final List<PosSaleModel> list;
  final int count;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final int from;
  final int to;

   PosSaleListSuccess({
    required this.list,
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.from,
    required this.to,
  });

  List<Object> get props => [list, count, totalPages, currentPage, pageSize, from, to];
}
class CartUpdateInProgress extends PosSaleState {}





final class PosSaleListFailed extends PosSaleState {
  final String title, content;

  PosSaleListFailed({required this.title, required this.content});
}

final class PosSaleDeleteInitial extends PosSaleState {}

final class PosSaleDeleteLoading extends PosSaleState {}

final class PosSaleDeleteSuccess extends PosSaleState {
  PosSaleDeleteSuccess();
}

final class PosSaleDeleteFailed extends PosSaleState {
  final String title, content;

  PosSaleDeleteFailed({required this.title, required this.content});
}


