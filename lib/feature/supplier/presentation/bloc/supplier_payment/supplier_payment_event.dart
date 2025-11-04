part of 'supplier_payment_bloc.dart';

sealed class SupplierPaymentEvent {}

class FetchSupplierPaymentList extends SupplierPaymentEvent {
  final BuildContext context;
  final String filterText;
  final DateTime? startDate;
  final DateTime? endDate;
  final int pageNumber;

   FetchSupplierPaymentList({
    required this.context,
    this.filterText = '',
    this.startDate,
    this.endDate,
    this.pageNumber = 0,
  });

  @override
  List<Object?> get props => [context, filterText, startDate, endDate, pageNumber];
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
