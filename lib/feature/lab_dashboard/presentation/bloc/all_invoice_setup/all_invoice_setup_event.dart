part of 'all_invoice_setup_bloc.dart';

sealed class AllInvoiceSetupEvent {}
class FetchAllInvoiceSetupEvent extends AllInvoiceSetupEvent {
  BuildContext context;

  FetchAllInvoiceSetupEvent(this.context);
}
