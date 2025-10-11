part of 'all_invoice_setup_bloc.dart';

sealed class AllInvoiceSetupState {}

final class AllInvoiceSetupInitial extends AllInvoiceSetupState {}
final class AllInvoiceSetupLoading extends AllInvoiceSetupState {}

final class AllInvoiceSetupLoaded extends AllInvoiceSetupState {
  AllInvoiceSetupModel allSetupModel;

  AllInvoiceSetupLoaded(this.allSetupModel);
}

final class AllInvoiceSetupError extends AllInvoiceSetupState {
  final String message;

  AllInvoiceSetupError(this.message);
}
