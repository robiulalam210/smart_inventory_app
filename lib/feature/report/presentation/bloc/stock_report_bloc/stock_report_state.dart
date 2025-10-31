// lib/feature/report/presentation/bloc/stock_report_bloc/stock_report_state.dart
part of 'stock_report_bloc.dart';

@immutable
sealed class StockReportState {}

final class StockReportInitial extends StockReportState {}

final class StockReportLoading extends StockReportState {}

final class StockReportSuccess extends StockReportState {
  final StockReportResponse response;

  StockReportSuccess({required this.response});
}

final class StockReportFailed extends StockReportState {
  final String title, content;

  StockReportFailed({required this.title, required this.content});
}