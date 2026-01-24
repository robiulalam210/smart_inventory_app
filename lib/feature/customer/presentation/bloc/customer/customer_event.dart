part of 'customer_bloc.dart';

sealed class CustomerEvent {}

class FetchCustomerList extends CustomerEvent {
  final BuildContext context;
  final String filterText;
  final String status; // active/inactive
  final String customerType; // special/regular
  final String amountType; // advance/due/paid
  final String startDate;
  final String endDate;
  final String dropdownFilter;
  final int pageNumber;
  final int pageSize;

   FetchCustomerList(
      this.context, {
        this.filterText = '',
        this.status = '',
        this.customerType = '',
        this.amountType = '',
        this.startDate = '',
        this.endDate = '',
        this.dropdownFilter = '',
        this.pageNumber = 1,
        this.pageSize = 10,
      });

  @override
  List<Object> get props => [
    context,
    filterText,
    status,
    customerType,
    amountType,
    startDate,
    endDate,
    dropdownFilter,
    pageNumber,
    pageSize,
  ];
}

class ToggleSpecialCustomer extends CustomerEvent {
  final BuildContext context;
  final String customerId;
  final String action; // 'toggle', 'set_true', 'set_false'

   ToggleSpecialCustomer({
    required this.context,
    required this.customerId,
    required this.action,
  });

  @override
  List<Object> get props => [context, customerId, action];
}
class FetchCustomerActiveList extends CustomerEvent {
  BuildContext context;

  FetchCustomerActiveList(
    this.context

  );
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
