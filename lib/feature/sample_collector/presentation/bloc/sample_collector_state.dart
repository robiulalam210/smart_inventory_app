part of 'sample_collector_bloc.dart';

@immutable
sealed class SampleCollectorState {}

final class SampleCollectorInitial extends SampleCollectorState {}

class SampleCollectorInvoicesLoading extends SampleCollectorState {}

class SampleCollectorInvoicesLoaded extends SampleCollectorState {
  final SampleCollectorInvoiceList invoices;

  SampleCollectorInvoicesLoaded(this.invoices);
}

class SampleCollectorInvoicesError extends SampleCollectorState {
  final String error;

  SampleCollectorInvoicesError(this.error);

  List<Object?> get props => [error];
}

class SampleCollectorLoading extends SampleCollectorState {}

class SampleCollectorLoaded extends SampleCollectorState {
  SampleCollectorLoaded();
}

class SampleCollectorError extends SampleCollectorState {
  final String error;

  SampleCollectorError(this.error);

  List<Object?> get props => [error];
}
