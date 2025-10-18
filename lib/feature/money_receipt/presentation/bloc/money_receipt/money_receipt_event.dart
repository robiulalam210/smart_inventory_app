part of 'money_receipt_bloc.dart';

sealed class MoneyReceiptEvent {}

class FetchMoneyReceiptList extends MoneyReceiptEvent {
  BuildContext context;

  final String filterText;
  final String location;
  final String customer;
  final String seller;
  final String paymentMethod;
  final DateTime? startDate;
  final DateTime? endDate;
  final int pageNumber;

  FetchMoneyReceiptList(this.context,
      {this.filterText = '',
      this.location = '',
      this.customer = '',
      this.seller = '',
      this.paymentMethod = '',
      this.startDate,
      this.endDate,
      this.pageNumber = 0});
}

class AddMoneyReceipt extends MoneyReceiptEvent {
  final Map<String, dynamic>? body;

  AddMoneyReceipt({this.body});
}

class UpdateMoneyReceipt extends MoneyReceiptEvent {
  final Map<String, String>? body;
  final String? id;

  UpdateMoneyReceipt({this.body, this.id}); // Include it in the constructor
  List<Object?> get props => [body, id];
}

class DeleteMoneyReceipt extends MoneyReceiptEvent {
  final String id;

  DeleteMoneyReceipt(this.id);
}

class UpdatePaymentMoneyReceipt extends MoneyReceiptEvent {
  final String? selectedPaymentToState; // Add this line

  UpdatePaymentMoneyReceipt(
      {this.selectedPaymentToState}); // Include it in the constructor
  List<Object?> get props => [selectedPaymentToState];
}

class MoneyReceiptDetailsList extends MoneyReceiptEvent {
  BuildContext context;

  final String id;

  MoneyReceiptDetailsList(this.context, {required this.id});
}
