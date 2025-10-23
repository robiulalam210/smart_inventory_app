// money_receipt_state.dart



// @immutable
import '../../../data/model/money_receipt_model/money_receipt_invoice_model.dart';
import '../../../data/model/money_receipt_model/money_receipt_model.dart';

sealed class MoneyReceiptState {}

final class MoneyReceiptInitial extends MoneyReceiptState {}

final class MoneyReceiptListLoading extends MoneyReceiptState {}

final class MoneyReceiptListSuccess extends MoneyReceiptState {
  final List<MoneyreceiptModel> list;
  final int count;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final int from;
  final int to;

  MoneyReceiptListSuccess({
    required this.list,
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.from,
    required this.to,
  });
}

final class MoneyReceiptListFailed extends MoneyReceiptState {
  final String title, content;

  MoneyReceiptListFailed({required this.title, required this.content});
}

final class MoneyReceiptAddInitial extends MoneyReceiptState {}

final class MoneyReceiptAddLoading extends MoneyReceiptState {}

final class MoneyReceiptAddSuccess extends MoneyReceiptState {
  MoneyReceiptAddSuccess();
}

final class MoneyReceiptAddFailed extends MoneyReceiptState {
  final String title, content;

  MoneyReceiptAddFailed({required this.title, required this.content});
}

final class MoneyReceiptUpdated extends MoneyReceiptState {
  final String selectedPaymentToState;

  MoneyReceiptUpdated({required this.selectedPaymentToState});

  List<Object?> get props => [selectedPaymentToState];
}




final class MoneyReceiptDeleteInitial extends MoneyReceiptState {}

final class MoneyReceiptDeleteLoading extends MoneyReceiptState {}

final class MoneyReceiptDeleteSuccess extends MoneyReceiptState {
  MoneyReceiptDeleteSuccess();
}

final class MoneyReceiptDeleteFailed extends MoneyReceiptState {
  final String title, content;

  MoneyReceiptDeleteFailed({required this.title, required this.content});
}



final class MoneyReceiptDetailsInitial extends MoneyReceiptState {}

final class MoneyReceiptDetailsLoading extends MoneyReceiptState {}

final class MoneyReceiptDetailsSuccess extends MoneyReceiptState {
  MoneyReceiptInvoiceModel details;

  MoneyReceiptDetailsSuccess({required this.details});
}

final class MoneyReceiptDetailsFailed extends MoneyReceiptState {
  final String title, content;

  MoneyReceiptDetailsFailed({required this.title, required this.content});
}
