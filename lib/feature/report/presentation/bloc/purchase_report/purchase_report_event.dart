part of 'purchase_report_bloc.dart';

@immutable
sealed class PurchaseReportEvent {}
class FetchPurchaseReport extends PurchaseReportEvent {
  final BuildContext context;
  final String? supplier;
  final DateTime? from;
  final DateTime? to;

  FetchPurchaseReport({
    required this.context,
    this.supplier,
    this.from,
    this.to,
  });
}

class ClearPurchaseReportFilters extends PurchaseReportEvent {}