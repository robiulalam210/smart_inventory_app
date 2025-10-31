part of 'sales_return_bloc.dart';

@immutable
sealed class SalesReturnEvent {}
class FetchSalesReturn extends SalesReturnEvent {
  final BuildContext context;
  final DateTime? startDate;
  final DateTime? endDate;
  final String filterText;
  final int? customerId; // Add customerId parameter
  final int pageNumber;

  FetchSalesReturn(
      this.context, {
        this.startDate,
        this.endDate,
        this.filterText = '',
        this.customerId,
        this.pageNumber = 0,
      });
}


class SalesReturnCreate extends SalesReturnEvent {
  final BuildContext context;
  final Map<String, dynamic> body;

  SalesReturnCreate({required this.context, required this.body});
}

class ViewSalesReturnDetails extends SalesReturnEvent {
  final BuildContext context;
  final String id;

  ViewSalesReturnDetails(this.context, this.id);
}

class DeleteSalesReturn extends SalesReturnEvent {
  final BuildContext context;
  final String id;

  DeleteSalesReturn(this.context, this.id);
}

class FetchInvoiceList extends SalesReturnEvent {
  final BuildContext context;
  final String dropdownFilter;

  FetchInvoiceList(this.context, {this.dropdownFilter = ''});
}

class SelectInvoice extends SalesReturnEvent {
  final SalesInvoiceModel invoice;

  SelectInvoice(this.invoice);
}