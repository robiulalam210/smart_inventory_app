part of 'refund_bloc.dart';

sealed class RefundEvent {}

class TestItemRefund extends RefundEvent{
  String invoiceNumber;  bool isFullRefund;

  TestItemRefund(this.invoiceNumber,this.isFullRefund);
}
class FullInvoiceRefund extends RefundEvent{
  String invoiceNumber;
  bool isFullRefund;
  FullInvoiceRefund(this.invoiceNumber,this.isFullRefund);

}