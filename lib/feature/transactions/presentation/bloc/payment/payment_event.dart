part of 'payment_bloc.dart';

@immutable
sealed class PaymentEvent {}

class CollectPartialPaymentEvent extends PaymentEvent {
  final String invoiceId;
  final double collectedAmount;
  final double additionalDiscount;
  final double totalTestPrice;
  final String paymentMethod;

  CollectPartialPaymentEvent({
    required this.invoiceId,
    required this.collectedAmount,
    required this.additionalDiscount,
    required this.totalTestPrice,
    required this.paymentMethod,
  });
}