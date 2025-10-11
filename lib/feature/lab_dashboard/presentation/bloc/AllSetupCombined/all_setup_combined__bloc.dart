import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../all_invoice_setup/all_invoice_setup_bloc.dart';
import '../all_setup_bloc/all_setup_bloc.dart';
import 'all_setup_combined__state.dart';

part 'all_setup_combined__event.dart';


class AllSetupCombinedCubit extends Cubit<AllSetupCombinedState> {
  AllSetupCombinedCubit()
      : super(AllSetupCombinedState(
    setupState: AllSetupInitial(),
    invoiceState: AllInvoiceSetupInitial(),
  ));

  void updateSetup(AllSetupState newSetupState) {
    emit(state.copyWith(setupState: newSetupState));
  }

  void updateInvoice(AllInvoiceSetupState newInvoiceState) {
    emit(state.copyWith(invoiceState: newInvoiceState));
  }
}
