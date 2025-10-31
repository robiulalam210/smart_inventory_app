part of 'purchase_report_bloc.dart';

@immutable
sealed class PurchaseReportState {}

final class PurchaseReportInitial extends PurchaseReportState {}
final class PurchaseReportLoading extends PurchaseReportState {}

final class PurchaseReportSuccess extends PurchaseReportState {
  final PurchaseReportResponse response;

  PurchaseReportSuccess({required this.response});
}

final class PurchaseReportFailed extends PurchaseReportState {
  final String title, content;

  PurchaseReportFailed({required this.title, required this.content});
}