part of 'purchase_return_bloc.dart';

abstract class PurchaseReturnEvent extends Equatable {
  const PurchaseReturnEvent();

  @override
  List<Object> get props => [];
}

class FetchPurchaseReturn extends PurchaseReturnEvent {
  final BuildContext context;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? filterText;
  final int? supplierId;
  final int pageNumber;

  const FetchPurchaseReturn(
      this.context, {
        this.startDate,
        this.endDate,
        this.filterText,
        this.supplierId,
        this.pageNumber = 0,
      });

  @override
  List<Object> get props => [context, pageNumber];
}

class CreatePurchaseReturn extends PurchaseReturnEvent {
  final BuildContext context;
  final Map<String, dynamic> body;

  const CreatePurchaseReturn(this.context, {required this.body});

  @override
  List<Object> get props => [context, body];
}

class ViewPurchaseReturnDetails extends PurchaseReturnEvent {
  final BuildContext context;
  final String id;

  const ViewPurchaseReturnDetails(this.context, {required this.id});

  @override
  List<Object> get props => [context, id];
}

class DeletePurchaseReturn extends PurchaseReturnEvent {
  final BuildContext context;
  final String id;

  const DeletePurchaseReturn(this.context, {required this.id});

  @override
  List<Object> get props => [context, id];
}

class FetchPurchaseInvoiceList extends PurchaseReturnEvent {
  final BuildContext context;
  final String id;

  const FetchPurchaseInvoiceList(this.context,this.id);

  @override
  List<Object> get props => [context];
}