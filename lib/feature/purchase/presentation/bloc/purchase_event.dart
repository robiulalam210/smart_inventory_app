part of 'purchase_bloc.dart';

sealed class PurchaseEvent {}

class FetchPurchaseList extends PurchaseEvent {
  BuildContext context;
  final String filterText;
  final String filterApiURL;
  final String supplier;
  final String paymentStatus;
  DateTime? startDate;
  DateTime? endDate;
  final int pageNumber;
  final int pageSize; // Add pageSize

  FetchPurchaseList(
      this.context, {
        this.filterText = '',
        this.filterApiURL = '',
        this.supplier = '',
        this.paymentStatus = '',
        this.startDate,
        this.endDate,
        this.pageNumber = 1, // Change from 0 to 1
        this.pageSize = 10, // Add default page size
      });
}

class UpdatePurchase extends PurchaseEvent {
  final Map<String, String>? body;
  final String? id;

  UpdatePurchase({this.body, this.id});
}



sealed class PurchaseDetailsEvent {}

class PurchaseDetailsList extends PurchaseDetailsEvent{
  BuildContext context;

  final String id;

  PurchaseDetailsList(this.context,{required this.id});

}

class DeletePurchase extends PurchaseDetailsEvent {
  final String id;

  DeletePurchase(this.id);
}
