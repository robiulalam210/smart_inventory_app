part of 'sales_report_bloc.dart';

@immutable
sealed class SalesReportState {}

final class SalesReportInitial extends SalesReportState {}

final class SalesReportLoading extends SalesReportState {}

final class SalesReportSuccess extends SalesReportState {
  final SalesReportResponse response;

  SalesReportSuccess({required this.response});
}

final class SalesReportFailed extends SalesReportState {
  final String title, content;

  SalesReportFailed({required this.title, required this.content});
}

