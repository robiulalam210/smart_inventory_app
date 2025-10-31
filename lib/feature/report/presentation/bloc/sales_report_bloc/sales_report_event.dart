part of 'sales_report_bloc.dart';

@immutable
sealed class SalesReportEvent {}

class FetchSalesReport extends SalesReportEvent {
  final BuildContext context;
  final String? customer;
  final String? seller;
  final DateTime? from;
  final DateTime? to;
  final int pageNumber;

  FetchSalesReport({
    required this.context,
    this.customer,
    this.seller,
    this.from,
    this.to,
    this.pageNumber = 1,
  });
}

class ClearSalesReportFilters extends SalesReportEvent {}