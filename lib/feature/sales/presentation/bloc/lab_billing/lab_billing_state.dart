part of 'lab_billing_bloc.dart';

@immutable
abstract class LabBillingState extends Equatable {
  const LabBillingState();

  @override
  List<Object?> get props => [];
}

class LabBillingInitial extends LabBillingState {
  const LabBillingInitial();
}


class LabBillingUpdated extends LabBillingState with EquatableMixin {
  final List<Map<String, dynamic>> testItems;

  LabBillingUpdated({required this.testItems});

  @override
  List<Object?> get props => [testItems];
}

class InvoicesLoading extends LabBillingState {}

class InvoicesOnlineOfflineLoading extends LabBillingState {}

class InvoicesDetailsLoading extends LabBillingState {}

class InvoicesLoaded extends LabBillingState {
  final InvoiceServerSyncResponseModel invoices;

  const InvoicesLoaded(this.invoices);


}

class InvoicesDetailsLoaded extends LabBillingState {
  final List<Map<String, dynamic>> invoices;

  const InvoicesDetailsLoaded(this.invoices);

  @override
  List<Object?> get props => [invoices];
}

class InvoiceDetailsLoaded extends LabBillingState {
  final bool isSyncing;
  final InvoiceLocalModel invoiceDetails;

  const InvoiceDetailsLoaded(this.invoiceDetails, {this.isSyncing = false});

  @override
  List<Object?> get props => [invoiceDetails, isSyncing];
}


class InvoiceSaved extends LabBillingState {
  final String invoiceId;

  const InvoiceSaved(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class InvoicesError extends LabBillingState {
  final String error;

  const InvoicesError(this.error);

  @override
  List<Object?> get props => [error];
}

class InvoicesDetailsError extends LabBillingState {
  final String error;

  const InvoicesDetailsError(this.error);

  @override
  List<Object?> get props => [error];
}
