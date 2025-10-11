import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../../../../core/configs/app_urls.dart';
import '../../../../../core/repositories/post_response.dart';
import '../../../data/models/full_invoice_refund_model.dart';

part 'refund_event.dart';
part 'refund_state.dart';

class RefundBloc extends Bloc<RefundEvent, RefundState> {
  RefundBloc() : super(RefundInitial()) {
    on<FullInvoiceRefund>(_postRefundInvoiceData);

  }


  /// Post unsynced invoices to the server
  Future<void> _postRefundInvoiceData(
      FullInvoiceRefund event,
      Emitter<RefundState> emit,
      ) async {
    emit(RefundInvoicesLoading());
    try {

      final response = await postResponse(
        url: "${AppUrls.fullInvoiceRefund}${event.invoiceNumber}",
      );

      final allSetupModel = fullRefundInvoiceModelFromJson(response);


      if (allSetupModel.status == 400) {
        emit(RefundInvoicesLoaded(allSetupModel,event.isFullRefund
            ));
      } else {
        emit(RefundInvoicesError(allSetupModel.message ?? "Unknown error"));
      }
    } catch (e, s) {
      emit(RefundInvoicesError(e.toString()));
      if (kDebugMode) {
        print('Error in refund: $e\n$s');
      }
    }
  }
  // /// Post unsynced invoices to the server
  // Future<void> _postTestRefundInvoiceData(
  //     TestItemRefund event,
  //     Emitter<RefundState> emit,
  //     ) async {
  //   emit(RefundInvoicesLoading());
  //   try {

  //     final response = await postResponse(
  //       url: "${AppUrls.fullInvoiceRefund}${event.invoiceNumber}",
  //       // payload: {discount: "100", totalBill: 1600, percentage: 6.25}
  //     );

  //     final allSetupModel = fullRefundInvoiceModelFromJson(response);


  //     if (allSetupModel.status == 400) {
  //       emit(RefundInvoicesLoaded(allSetupModel,event.isFullRefund
  //           ));
  //     } else {
  //       emit(RefundInvoicesError(allSetupModel.message ?? "Unknown error"));
  //     }
  //   } catch (e, s) {
  //     emit(RefundInvoicesError(e.toString()));
  //     if (kDebugMode) {
  //       print('Error in refund: $e\n$s');
  //     }
  //   }
  // }
}
