part of 'finder_bloc.dart';

@immutable
sealed class FinderState {}


// Initial state before any action
class FinderInitial extends FinderState {}

// Loading state during fetch
class FinderLoading extends FinderState {}

// Loaded state with fetched invoices and summary
class FinderLoaded extends FinderState {
  final InvoiceSyncResponseModel invoiceData;

  FinderLoaded(this.invoiceData);

  List<Object?> get props => [invoiceData];
}

// Error state with error message
class FinderError extends FinderState {
  final String message;

  FinderError(this.message);

  List<Object?> get props => [message];
}// Loading state during fetch
class FinderInvoiceUserLoading extends FinderState {}

// Loaded state with fetched invoices and summary
class FinderInvoiceUserLoaded extends FinderState {
  final InvoiceSyncResponseModel invoiceData;

  FinderInvoiceUserLoaded(this.invoiceData);

  List<Object?> get props => [invoiceData];
}

// Error state with error message
class FinderInvoiceUserError extends FinderState {
  final String message;

  FinderInvoiceUserError(this.message);

  List<Object?> get props => [message];
}class FinderInvoiceLoading extends FinderState {}

// Loaded state with fetched invoices and summary
class FinderInvoiceLoaded extends FinderState {
  final InvoiceSyncResponseModel invoiceData;

  FinderInvoiceLoaded(this.invoiceData);

  List<Object?> get props => [invoiceData];
}

// Error state with error message
class FinderInvoiceError extends FinderState {
  final String message;

  FinderInvoiceError(this.message);

  List<Object?> get props => [message];
}