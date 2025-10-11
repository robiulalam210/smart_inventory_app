import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import '../../../../sales/data/repositories/lab_billing_db_repo.dart';

part 'payment_event.dart';

part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final LabBillingRepository labBillingRepository = LabBillingRepository();

  PaymentBloc() : super(PaymentInitial()) {
    on<CollectPartialPaymentEvent>(_onCollectPartialPayment);
  }

  Future<void> _onCollectPartialPayment(
    CollectPartialPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final response = await labBillingRepository.collectPartialPayment(
          invoiceId: event.invoiceId.toString(),
          collectedAmount: event.collectedAmount,
          paymentMethod: event.paymentMethod,
          discount: event.additionalDiscount,
          totalTestPrice: event.totalTestPrice);
      if (response['status'] == 'success') {
        emit(PaymentSuccess(response));
      } else {
        emit(PaymentError(response['message'] ?? 'Failed to collect payment'));
      }
    } catch (e, stack) {
      debugPrint("Error $e  stack $stack");
      emit(PaymentError(e.toString()));
    }
  }
}
