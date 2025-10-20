part of 'customer_bloc.dart';

sealed class CustomerEvent {}

class FetchCustomerList extends CustomerEvent {
  BuildContext context;

  final String dropdownFilter;
  final String filterText;
  final String filterApiURL;
  final String status;
  final int pageNumber;

  FetchCustomerList(this.context,
      {this.dropdownFilter = '',
      this.filterText = '',
      this.filterApiURL = '',
      this.status = '',
      this.pageNumber = 0});
}

class AddCustomer extends CustomerEvent {
  final Map<String, dynamic>? body;

  AddCustomer({this.body});
}

class UpdateCustomer extends CustomerEvent {
  final Map<String, dynamic>? body;
  final String? id;

  UpdateCustomer({this.body, this.id});
}

class UpdateSwitchCustomer extends CustomerEvent {
  final Map<String, String>? body;
  final String? id;

  UpdateSwitchCustomer({this.body, this.id});
}

class DeleteCustomer extends CustomerEvent {
  final String id;

  DeleteCustomer(this.id);
}

class FetchCustomerDetailsList extends CustomerEvent {
  BuildContext context;

  final String id;

  FetchCustomerDetailsList(this.context, {this.id = ''});
}
