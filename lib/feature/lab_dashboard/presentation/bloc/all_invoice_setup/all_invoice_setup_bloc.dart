import 'package:flutter/foundation.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../data/models/all_setup_model/all_invoice_setup_model.dart';



part 'all_invoice_setup_event.dart';

part 'all_invoice_setup_state.dart';

class AllInvoiceSetupBloc
    extends Bloc<AllInvoiceSetupEvent, AllInvoiceSetupState> {
  AllInvoiceSetupBloc() : super(AllInvoiceSetupInitial()) {
    on<FetchAllInvoiceSetupEvent>(_fetchAllInvoiceSetupData);
  }

  Future<void> _fetchAllInvoiceSetupData(
    FetchAllInvoiceSetupEvent event,
    Emitter<AllInvoiceSetupState> emit,
  ) async {
    emit(AllInvoiceSetupLoading());

    try {
      final response = await getResponse(
        context: event.context,
        url: AppUrls.getInvoice,
      );

      final allInvoiceModel = allInvoiceSetupModelFromJson(response);

      if (allInvoiceModel.statusCode == 200) {
        emit(AllInvoiceSetupLoaded(allInvoiceModel));
      } else {
        emit(AllInvoiceSetupError(allInvoiceModel.message ?? ""));
      }
    } catch (e, s) {

      emit(AllInvoiceSetupError("Error parsing invoice setup: $e"));

      if (kDebugMode) {
        print('Error in AllSetupBloc: $e $s');
      }
    }
  }
}
