import 'package:equatable/equatable.dart';

import '../all_invoice_setup/all_invoice_setup_bloc.dart';
import '../all_setup_bloc/all_setup_bloc.dart';

class AllSetupCombinedState extends Equatable {
  final AllSetupState setupState;
  final AllInvoiceSetupState invoiceState;

  const AllSetupCombinedState({
    required this.setupState,
    required this.invoiceState,
  });

  AllSetupCombinedState copyWith({
    AllSetupState? setupState,
    AllInvoiceSetupState? invoiceState,
  }) {
    return AllSetupCombinedState(
      setupState: setupState ?? this.setupState,
      invoiceState: invoiceState ?? this.invoiceState,
    );
  }

  @override
  List<Object> get props => [setupState, invoiceState];
}
