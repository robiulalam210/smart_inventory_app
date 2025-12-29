part of 'sales_return_bloc.dart';

@immutable
sealed class SalesReturnEvent {}

class FetchSalesReturn extends SalesReturnEvent {
  final BuildContext context;
  final String filterText;
  final int? customerId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int pageNumber;
  final int? pageSize;

   FetchSalesReturn({
    required this.context,
    this.filterText = '',
    this.customerId,
    this.startDate,
    this.endDate,
    this.pageNumber = 0,
    this.pageSize,
  });

  @override
  List<Object?> get props => [
    context,
    filterText,
    customerId,
    startDate,
    endDate,
    pageNumber,
    pageSize,
  ];
}

class SalesReturnCreate extends SalesReturnEvent {
  final BuildContext? context;
   SalesReturnCreateModel body;

   SalesReturnCreate({
    this.context,
    required this.body,
  });

  @override
  List<Object?> get props => [context, body];
}

class SalesReturnApprove extends SalesReturnEvent {
  final BuildContext? context;
  final int id;

   SalesReturnApprove({
    this.context,
    required this.id,
  });

  @override
  List<Object?> get props => [context, id];
}

class SalesReturnReject extends SalesReturnEvent {
  final BuildContext? context;
  final int id;

   SalesReturnReject({
    this.context,
    required this.id,
  });

  @override
  List<Object?> get props => [context, id];
}

class SalesReturnComplete extends SalesReturnEvent {
  final BuildContext? context;
  final int id;

   SalesReturnComplete({
    this.context,
    required this.id,
  });

  @override
  List<Object?> get props => [context, id];
}

class ViewSalesReturnDetails extends SalesReturnEvent {
  final BuildContext context;
  final int id;

   ViewSalesReturnDetails({
    required this.context,
    required this.id,
  });

  @override
  List<Object?> get props => [context, id];
}

class DeleteSalesReturn extends SalesReturnEvent {
  final BuildContext? context;
  final int id;

   DeleteSalesReturn({
    this.context,
    required this.id,
  });

  @override
  List<Object?> get props => [context, id];
}

class FetchInvoiceList extends SalesReturnEvent {
  final BuildContext context;

   FetchInvoiceList(this.context);

  @override
  List<Object?> get props => [context];
}



class SelectInvoice extends SalesReturnEvent {
  final SalesInvoiceModel invoice;

  SelectInvoice(this.invoice);
}