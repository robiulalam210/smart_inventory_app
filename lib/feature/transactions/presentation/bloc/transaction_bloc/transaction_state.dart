part of 'transaction_bloc.dart';

@immutable
sealed class TransactionState {}

final class TransactionInitial extends TransactionState {}
class TransactionInvoicesLoading extends TransactionState {}
class TransactionInvoicesLoaded extends TransactionState {
  final InvoiceSyncResponseModel invoices;

   TransactionInvoicesLoaded(this.invoices);



}


class TransactionInvoicesError extends TransactionState {
  final String error;

   TransactionInvoicesError(this.error);

  List<Object?> get props => [error];
}

class TransactionInvoicesDetailsLoading extends TransactionState {}

class TransactionInvoiceDetailsLoaded extends TransactionState {
  final InvoiceLocalModel invoiceDetails;

   TransactionInvoiceDetailsLoaded(this.invoiceDetails);

  List<Object?> get props => [invoiceDetails];
}

class TransactionInvoicesDetailsError extends TransactionState {
  final String error;

   TransactionInvoicesDetailsError(this.error);

  List<Object?> get props => [error];
}


class MoneyReceiptDetailsLoading extends TransactionState {}
class MoneyReceiptDetailsLoaded extends TransactionState {
  final InvoiceLocalModel moneyReceiptDetails;

   MoneyReceiptDetailsLoaded(this.moneyReceiptDetails);

  List<Object?> get props => [moneyReceiptDetails];
}         

class MoneyReceiptDetailsError extends TransactionState   {
  final String error;

   MoneyReceiptDetailsError(this.error);

  List<Object?> get props => [error];
}