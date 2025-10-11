part of 'payment_bloc.dart';

@immutable
sealed class PaymentState {}

final class PaymentInitial extends PaymentState {}


class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final Map<String, dynamic> response;

  PaymentSuccess(this.response);
}

class PaymentError extends PaymentState {
  final String error;

  PaymentError(this.error);
}