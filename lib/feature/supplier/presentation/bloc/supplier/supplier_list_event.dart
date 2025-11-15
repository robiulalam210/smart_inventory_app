part of 'supplier_list_bloc.dart';

sealed class SupplierListEvent {}



class FetchSupplierList extends SupplierListEvent {
  final BuildContext context;
  final String filterText;
  final String location;
  final String state;
  final int pageNumber;
  final int pageSize;

  FetchSupplierList(
      this.context, {
        this.filterText = '',
        this.state = '',
        this.location = '',
        this.pageNumber = 1, // Changed from 0 to 1
        this.pageSize = 10, // Added pageSize
      });

  List<Object> get props => [context, filterText, state, location, pageNumber, pageSize];
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
  final String id;

  DeleteSupplierList(this.id);
}


class FetchSupplierDetailsList extends SupplierListEvent {
  final String id;  BuildContext context;


  FetchSupplierDetailsList(this.context,{this.id = ''});
}