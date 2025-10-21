part of 'supplier_payment_bloc.dart';

sealed class SupplierPaymentEvent {}

class FetchSupplierPaymentList extends SupplierPaymentEvent {
  BuildContext context;

  final String filterText;
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;
  final int pageNumber;

  FetchSupplierPaymentList(
      this.context,
      {this.filterText = '',
      this.location = '',
      this.startDate,
      this.endDate,
      this.pageNumber = 0});
}

class AddSupplierPayment extends SupplierPaymentEvent {
  final Map<String, dynamic>? body;

  AddSupplierPayment({this.body});
}
class SupplierPaymentDelete extends SupplierPaymentEvent {
  final String id;

  SupplierPaymentDelete({required this.id});
}

class SupplierPaymentDetailsList extends SupplierPaymentEvent {
  final String id;  BuildContext context;


  SupplierPaymentDetailsList(this.context,{required this.id});
}
