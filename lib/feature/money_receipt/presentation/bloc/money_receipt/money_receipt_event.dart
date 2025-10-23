part of 'money_receipt_bloc.dart';

sealed class MoneyReceiptEvent {}

class FetchMoneyReceiptList extends MoneyReceiptEvent {
  BuildContext context;
  final String filterText;
  final String customer;
  final String seller;
  final String paymentMethod;
  final DateTime? startDate;
  final DateTime? endDate;
  final int pageNumber;
  final int pageSize; // Add pageSize

  FetchMoneyReceiptList(
      this.context, {
        this.filterText = '',
        this.customer = '',
        this.seller = '',
        this.paymentMethod = '',
        this.startDate,
        this.endDate,
        this.pageNumber = 1, // Change default to 1
        this.pageSize = 10, // Add default page size
      });
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
