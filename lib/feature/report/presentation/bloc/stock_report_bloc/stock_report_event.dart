// lib/feature/report/presentation/bloc/stock_report_bloc/stock_report_event.dart
part of 'stock_report_bloc.dart';

@immutable
sealed class StockReportEvent {}

class FetchStockReport extends StockReportEvent {
  final BuildContext context;
  final DateTime? from;
  final DateTime? to;

  FetchStockReport({
    required this.context,
    this.from,
    this.to,
  });
}

class ClearStockReportFilters extends StockReportEvent {}