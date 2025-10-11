part of 'transaction_bloc.dart';

sealed class TransactionEvent {}


class LoadTransactionInvoices extends TransactionEvent {
  final String query;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? pageNumber;
  final int? pageSize;

  LoadTransactionInvoices({
    this.query = '',
    this.fromDate,
    this.toDate,
    this.pageNumber,  // Default first page
    this.pageSize ,   // Default page size
  });
}


class LoadInvoiceTransactionDetails extends TransactionEvent {
  final String invoiceId;
  final bool isPrinting;
  BuildContext context;

  LoadInvoiceTransactionDetails(this.invoiceId, this.context, this.isPrinting);

  List<Object?> get props => [invoiceId, isPrinting];
}

class LoadMoneyReceiptDetails extends TransactionEvent {
  final String invoiceId;
  final bool isRefund;
  BuildContext context;

  LoadMoneyReceiptDetails({required this.invoiceId,required this.isRefund, required this.context});

  List<Object?> get props => [invoiceId,isRefund];
}

