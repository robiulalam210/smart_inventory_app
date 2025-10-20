part of 'supplier_list_bloc.dart';

sealed class SupplierListEvent {}



class FetchSupplierList extends SupplierListEvent {
  BuildContext context;

  final String filterText;
  final String location;
  final String state;
  final int pageNumber;

  FetchSupplierList(this.context,{this.filterText = '',
    this.state = '',
    this.location = '',
    this.pageNumber = 0});
}

class AddSupplierList extends SupplierListEvent {
  final Map<String, dynamic>? body;

  AddSupplierList({this.body});
}

class UpdateSupplierList extends SupplierListEvent {
  final Map<String, dynamic>? body;
  final String? branchId;

  UpdateSupplierList({this.body, this.branchId});
}

class UpdateSwitchSupplierList extends SupplierListEvent {
  final Map<String, String>? branch;
  final String? branchId;

  UpdateSwitchSupplierList({this.branch, this.branchId});
}

class DeleteSupplierList extends SupplierListEvent {
  final String branchId;

  DeleteSupplierList(this.branchId);
}


class FetchSupplierDetailsList extends SupplierListEvent {
  final String id;  BuildContext context;


  FetchSupplierDetailsList(this.context,{this.id = ''});
}