part of 'refund_bloc.dart';

sealed class RefundState {}

final class RefundInitial extends RefundState {}
class RefundInvoicesLoading extends RefundState {}
class RefundInvoicesLoaded extends RefundState {
  final FullRefundInvoiceModel fullRefundInvoiceModel;
 bool isFullRefund;
   RefundInvoicesLoaded(this.fullRefundInvoiceModel,this.isFullRefund );

  List<Object?> get props => [fullRefundInvoiceModel];
}

class RefundInvoicesError extends RefundState {
  final String error;

   RefundInvoicesError(this.error);

  List<Object?> get props => [error];
}
