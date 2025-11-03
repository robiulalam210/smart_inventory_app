part of 'bad_stock_list_bloc.dart';

sealed class BadStockListEvent {}


class FetchBadStockList extends BadStockListEvent {
  final BuildContext context;
  final int? location;
  final int pageNumber;
  final String filterText;
  final DateTime? from;
  final DateTime? to;

  FetchBadStockList(
      this.context, {
        this.location,
        this.pageNumber = 0,
        this.filterText = '',
        this.from,
        this.to,
      });
}