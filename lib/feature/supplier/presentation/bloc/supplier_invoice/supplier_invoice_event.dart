part of 'supplier_invoice_bloc.dart';

sealed class SupplierInvoiceEvent {}



class FetchSupplierInvoiceList extends SupplierInvoiceEvent {
  BuildContext context;

  final String filterText;
  final String dropdownFilter;
  final String state;
  final int pageNumber;

  FetchSupplierInvoiceList(this.context,{this.filterText = '',this.dropdownFilter='', this.state = '', this.pageNumber = 0});
}


class FetchSupplierActiveList extends SupplierInvoiceEvent {
  BuildContext context;

  FetchSupplierActiveList(this.context);
}

class AddSupplierInvoiceList extends SupplierInvoiceEvent {
  final Map<String, String>? branch;

  AddSupplierInvoiceList({this.branch});
}

class UpdateSupplierInvoiceList extends SupplierInvoiceEvent {
  final Map<String, String>? branch;
  final String? branchId;

  UpdateSupplierInvoiceList({this.branch, this.branchId});
}




sealed class SupplierInvoiceDetailsEvent {}

class SupplierInvoiceDetails extends SupplierInvoiceDetailsEvent{
  BuildContext context;

  final String id;

  SupplierInvoiceDetails(this.context,{required this.id});

}